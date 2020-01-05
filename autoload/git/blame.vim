let s:JOB = SpaceVim#api#import('job')
let s:BUFFER = SpaceVim#api#import('vim#buffer')

function! git#blame#run(...)
    if len(a:1) == 0
        let cmd = ['git', 'blame', expand('%')] 
    else
        let cmd = ['git', 'blame'] + a:1
    endif
    let s:blame_buffer_nr = s:openBlameWindow()
    let s:lines = []
    call git#logger#info('git-blame cmd:' . string(cmd))
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
        call git#logger#info('git-diff stdout:' . data)
    endfor
    let s:lines += a:data
endfunction
function! s:on_stderr(id, data, event) abort
    for data in a:data
        call git#logger#info('git-diff stderr:' . data)
    endfor
    let s:lines += a:data
endfunction
function! s:on_exit(id, data, event) abort
    call git#logger#info('git-diff exit data:' . string(a:data))
    call s:BUFFER.buf_set_lines(s:blame_buffer_nr, 0 , -1, 0, s:lines)
endfunction


function! s:openBlameWindow() abort
    tabedit git://blame
    normal! "_dd
    setl nobuflisted
    setl nomodifiable
    setl nonumber norelativenumber
    setl buftype=nofile
    setf git-diff
    setl syntax=diff
    nnoremap <buffer><silent> q :bd!<CR>
    return bufnr()
endfunction

function! git#blame#complete(ArgLead, CmdLine, CursorPos)

    return "%\n" . join(getcompletion(a:ArgLead, 'file'), "\n")

endfunction

