let s:JOB = SpaceVim#api#import('job')
let s:BUFFER = SpaceVim#api#import('vim#buffer')

let g:git_log_pretty = "tformat:%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%an %ad)%Creset"

function! git#log#run(...)
    if len(a:1) == 1 && a:1[0] ==# '%'
        let cmd = ['git', 'log', '--graph', '--date=relative', '--pretty=' . g:git_log_pretty, expand('%')] 
    else
        let cmd = ['git', 'log', '--graph', '--date=relative', '--pretty=' . g:git_log_pretty] + a:1
    endif
    let s:bufnr = s:openLogBuffer()
    let s:lines = []
    call git#logger#info('git-log cmd:' . string(cmd))
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
        call git#logger#info('git-log stdout:' . data)
    endfor
    let s:lines += filter(a:data, '!empty(v:val)')
endfunction
function! s:on_stderr(id, data, event) abort
    for data in a:data
        call git#logger#info('git-log stderr:' . data)
    endfor
    let s:lines += a:data
endfunction
function! s:on_exit(id, data, event) abort
    call git#logger#info('git-log exit data:' . string(a:data))
    call s:BUFFER.buf_set_lines(s:bufnr, 0 , -1, 0, s:lines)
endfunction


function! s:openLogBuffer() abort
    edit git://log
    normal! "_dd
    setl nobuflisted
    setl nomodifiable
    setl nonumber norelativenumber
    setl buftype=nofile
    setl bufhidden=wipe
    setf git-log
    nnoremap <buffer><silent> q :b#<CR>
    return bufnr()
endfunction

function! git#log#complete(ArgLead, CmdLine, CursorPos)

    return "%\n" . join(getcompletion(a:ArgLead, 'file'), "\n")

endfunction

