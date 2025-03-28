""
" @section git-rm, rm
" @parentsection commands
" This commands is to rm file contents to the index. For example, rm current
" file to the index.
" >
"   :Git rm %
" <

if has('nvim-0.9.0')
  function! git#rm#complete(ArgLead, CmdLine, CursorPos) abort
    return luaeval('require("git.command.rm").complete(vim.api.nvim_eval("a:ArgLead"), vim.api.nvim_eval("a:CmdLine"), vim.api.nvim_eval("a:CursorPos"))')
  endfunction
else
  let s:JOB = SpaceVim#api#import('job')

  function! git#rm#run(files) abort

    if len(a:files) == 1 && a:files[0] ==# '%'
      let cmd = ['git', 'rm', expand('%')] 
    else
      let cmd = ['git', 'rm'] + a:files
    endif
    call git#logger#debug('git-rm cmd:' . string(cmd))
    call s:JOB.start(cmd,
          \ {
          \ 'on_exit' : function('s:on_exit'),
          \ }
          \ )

  endfunction

  function! s:on_exit(id, data, event) abort
    call git#logger#debug('git-rm exit data:' . string(a:data))
    if a:data ==# 0
      if exists(':GitGutter')
        GitGutter
      endif
      echo 'done!'
    else
      echo 'failed!'
    endif
  endfunction

  function! git#rm#complete(ArgLead, CmdLine, CursorPos) abort

    return "%\n" . join(getcompletion(a:ArgLead, 'file'), "\n")

  endfunction
endif
