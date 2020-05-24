function! git#branch#manager#open()
 call s:open_win()   
endfunction

let s:bufnr = 0
function! s:open_win() abort
  if s:bufnr != 0 && bufexists(s:bufnr)
    exe 'bd ' . s:bufnr
  endif
  topleft vsplit __git_branch_manager__
  " @todo add win_getid api
  let s:winid = win_getid(winnr('#'))
  let lines = &columns * 30 / 100
  exe 'vertical resize ' . lines
  setlocal buftype=nofile bufhidden=wipe nobuflisted nolist noswapfile nowrap cursorline nospell nonu norelativenumber winfixheight nomodifiable
  set filetype=SpaceVimGitBranchManager
  let s:bufnr = bufnr('%')
  call s:update_branch_content()
  augroup git_branch_manager
    autocmd! * <buffer>
    autocmd WinEnter <buffer> call s:WinEnter()
  augroup END
  nnoremap <buffer><silent> <Enter> :call <SID>checkout_branch()<cr>
endfunction
function! s:WinEnter() abort
  let s:winid = win_getid(winnr('#'))
endfunction
function! s:checkout_branch() abort
endfunction

function! s:update_branch_content() abort
    
endfunction
