let s:JOB = SpaceVim#api#import('job')
let s:BUFFER = SpaceVim#api#import('vim#buffer')

function! git#commit#run(...)
    let s:bufnr = s:openCommitBuffer()
    let s:lines = []
    if empty(a:1)
        let cmd = ['git', '--no-pager', '-c',
                    \ 'core.editor=cat', '-c',
                    \ 'color.status=always',
                    \ '-C', 
                    \ expand(getcwd(), ':p'),
                    \ 'commit', '--edit']
    else
    endif
    call s:JOB.start(cmd,
                \ {
                \ 'on_stderr' : function('s:on_stderr'),
                \ 'on_stdout' : function('s:on_stdout'),
                \ 'on_exit' : function('s:on_exit'),
                \ }
                \ )
endfunction

function! s:on_stdout(id, data, event) abort
    for data in a:data
        call git#logger#info('git-commit stdout:' . data)
    endfor
    let s:lines += a:data
endfunction
function! s:on_stderr(id, data, event) abort
    for data in a:data
        call git#logger#info('git-commit stderr:' . data)
    endfor
    " stderr should not be added to commit buffer
    " let s:lines += a:data
endfunction
function! s:on_exit(id, data, event) abort
    call git#logger#info('git-exit exit data:' . string(a:data))
    call s:BUFFER.buf_set_lines(s:bufnr, 0 , -1, 0, s:lines)
endfunction

function! s:openCommitBuffer() abort
    10split git://commit
    normal! "_dd
    setlocal nobuflisted
    setlocal buftype=acwrite
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal modifiable
    setf git-commit
    nnoremap <buffer><silent> q :bd!<CR>

    augroup git_commit_buffer
        autocmd! * <buffer>
        autocmd BufWriteCmd <buffer> call s:BufWriteCmd()
        autocmd QuitPre  <buffer> call s:QuitPre()
        autocmd WinLeave <buffer> call s:WinLeave()
        autocmd WinEnter <buffer> silent! unlet! b:git_commit_quitpre
    augroup END
    return bufnr()
endfunction

" NOTE:
" :w      -- BufWriteCmd
" <C-w>p  -- WinLeave
" :wq     -- QuitPre -> BufWriteCmd -> WinLeave
" :q      -- QuitPre -> WinLeave
function! s:BufWriteCmd() abort
    let commit_file = '.git\COMMIT_EDITMSG'
    call writefile(getline(1, '$'), commit_file)
endfunction

function! s:QuitPre() abort
    let b:git_commit_quitpre = 1
endfunction

function! s:WinLeave() abort
    if get(b:, 'git_commit_quitpre', 0)
        let cmd = ['git', 'commit', '-F', '-']
        let id = s:JOB.start(cmd,
                    \ {
                    \ 'on_exit' : function('s:on_commit_exit'),
                    \ }
                    \ )
        quit
        " line start with # should be ignored
        call s:JOB.send(id, filter(getline(1, '$'), 'v:val !~ "^\s*#"'))
        call s:JOB.chanclose(id, 'stdin')
    endif
endfunction

function! s:on_commit_exit(id, data, event) abort
    call git#logger#info('git-commit exit data:' . string(a:data))
    if a:data ==# 0
        echo 'done!'
    else
        echo 'failed!'
    endif
endfunction
