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
    setl nobuflisted
    setl buftype=nofile
    setf git-commit
    nnoremap <buffer><silent> q :bd!<CR>
" https://github.com/lambdalisue/gina.vim/blob/2e9de27914c3765c87dc28626af772ef6207375e/autoload/gina/command/commit.vim
    return bufnr()
endfunction

function! s:finishCommit() abort
    
endfunction
