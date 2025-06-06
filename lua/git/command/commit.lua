local M = {}

local job = require('spacevim.api.job')
local nt = require('spacevim.api.notify')
local log = require('git.log')

local commit_bufnr = -1

local commit_output = {}
local commitmsg = {}
local isamend = false

local commit_jobid = -1
local commit_buf_jobid = -1

local function on_stdout(id, data)
  if id ~= commit_jobid then
    return
  end
  for _, d in ipairs(data) do
    log.debug('git-commit stdout:' .. d)
    table.insert(commit_output, d)
  end
end

local function on_stderr(id, data)
  if id ~= commit_jobid then
    return
  end
  for _, d in ipairs(data) do
    log.debug('git-commit stderr:' .. d)
    table.insert(commit_output, d)
  end
end

local function BufWriteCmd()
  commitmsg = vim.fn.getline(1, '$')
  vim.bo.modified = false
end

local function QuitPre()
  vim.b.git_commit_quitpre = true
end

local function on_commit_exit(id, code, single)
  if id ~= commit_buf_jobid then
    return
  end
  log.debug('git-commit exit code:' .. code .. ' single:' .. single)
  if code == 0 and single == 0 then
    nt.notify('commit done!')
  else
    nt.notify('commit failed!', 'WarningMsg')
  end
end

local function filter(t, f)
  local rst = {}

  for _, v in ipairs(t) do
    if f(v) then
      table.insert(rst, v)
    end
  end
  return rst
end

local function WinLeave()
  if vim.b.git_commit_quitpre then
    local cmd = {
      'git',
      'commit',
      '-m',
      table.concat(
        filter(commitmsg, function(var)
          return not string.find(var, '^%s*#')
        end),
        '\n'
      ),
    }
    if isamend then
      table.insert(cmd, '--amend')
    end
    log.debug('git-commit cmd:' .. vim.inspect(cmd))
    commit_buf_jobid = job.start(cmd, {
      on_exit = on_commit_exit,
    })
  end
end
local function openCommitBuffer()
  vim.cmd([[
  10split git://commit
  normal! "_dd
  setlocal nobuflisted
  setlocal buftype=acwrite
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal modifiable
  setf git-commit
  set syntax=gitcommit
  nnoremap <buffer><silent> q :bd!<CR>
  let b:git_commit_quitpre = 0
  ]])
  local bufid = vim.fn.bufnr('%')
  local id = vim.api.nvim_create_augroup('git_commit_buffer', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufWriteCmd' }, {
    group = id,
    buffer = bufid,
    callback = BufWriteCmd,
  })
  vim.api.nvim_create_autocmd({ 'QuitPre' }, {
    group = id,
    buffer = bufid,
    callback = QuitPre,
  })
  vim.api.nvim_create_autocmd({ 'WinLeave' }, {
    group = id,
    buffer = bufid,
    callback = WinLeave,
  })
  vim.api.nvim_create_autocmd({ 'WinEnter' }, {
    group = id,
    buffer = bufid,
    callback = function()
      vim.b.git_commit_quitpre = false
    end,
  })
  return bufid
end
local function on_exit(id, code, single)
  log.debug(string.format('code %d, single %d', code, single))
  if id ~= commit_jobid then
    return
  end
  if code == 0 and single == 0 then
    nt.notify('commit done!')
    return
  end
  local iscommitmsg = false
  for _, line in ipairs(commit_output) do
    if not iscommitmsg and vim.startswith(line, '1111111111111111111111') then
      iscommitmsg = true
    else
      if vim.startswith(line, '22222222222222222222') then
        break
      end
      if iscommitmsg then
        table.insert(commitmsg, line)
      end
    end
  end
  if #commitmsg > 0 then
    if
      vim.api.nvim_buf_is_valid(commit_bufnr)
      and vim.fn.index(vim.fn.tabpagebuflist(), commit_bufnr) ~= -1
    then
      local winnr = vim.fn.bufwinnr(commit_bufnr)
      vim.cmd(winnr .. 'wincmd w')
    else
      commit_bufnr = openCommitBuffer()
    end
    vim.api.nvim_buf_set_lines(commit_bufnr, 0, -1, false, commitmsg)
    vim.bo.modified = false
  else
    nt.notify(table.concat(commit_output, "\n"), 'WarningMsg')
  end
end

local function index(t, v)
  if not t then
    return -1
  end

  return vim.fn.index(t, v)
end

function M.run(argv)
  local cmd
  commit_output = {}
  commitmsg = {}

  if index(argv, '--amend') ~= -1 then
    isamend = true
  else
    isamend = false
  end
  cmd = {
    'git',
    '--no-pager',
    '-c',
    [[core.editor=nvim -u NONE --headless -n --cmd "set shada=" --cmd "call chansend(v:stderr, ['1111111111111111111111', ''])" --cmd "call chansend(v:stderr, readfile(bufname()))" --cmd "call chansend(v:stderr, ['', '22222222222222222222'])" --cmd "cq 1"]],
    '-c',
    'color.status=always',
    '-C',
    vim.fn.expand(vim.fn.getcwd(), ':p'),
    'commit',
  }
  for _, v in ipairs(argv) do
    table.insert(cmd, v)
  end
  log.debug('git-commit cmd:' .. vim.inspect(cmd))
  commit_jobid = job.start(cmd, {
    on_stdout = on_stdout,
    on_exit = on_exit,
    on_stderr = on_stderr,
  })
end

return M
