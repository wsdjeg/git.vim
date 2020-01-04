let s:JOB = SpaceVim#api#import('job')
let s:BUFFER = SpaceVim#api#import('vim#buffer')

function! git#config#run(argvs)

    if empty(a:argvs)
        let cmd = ['git', 'config', '--list'] 
    else
        let cmd = ['git', 'config'] + a:argvs
    endif
    let s:bufnr = s:openConfigBuffer()
    let s:lines = []
    call git#logger#info('git-config cmd:' . string(cmd))
    call s:JOB.start(cmd,
                \ {
                \ 'on_exit' : function('s:on_exit'),
                \ 'on_stdout' : function('s:on_stdout'),
                \ }
                \ )

endfunction

function! s:on_stdout(id, data, event) abort
    for data in a:data
        call git#logger#info('git-config stdout:' . data)
    endfor
    let s:lines += a:data
endfunction

function! s:on_exit(id, data, event) abort
    call git#logger#info('git-config exit data:' . string(a:data))
    if a:data ==# 0
        call s:BUFFER.buf_set_lines(s:bufnr, 0 , -1, 0, s:lines)
        echo 'done!'
    else
        echo 'failed!'
    endif
endfunction

function! s:openConfigBuffer() abort
    10split git://config
    normal! "_dd
    setl nobuflisted
    setl nomodifiable
    setl nonumber norelativenumber
    setl buftype=nofile
    setf git-config
    nnoremap <buffer><silent> q :bd!<CR>
    return bufnr()
endfunction

function! git#config#complete(ArgLead, CmdLine, CursorPos)

    return "%\n" . join(getcompletion(a:ArgLead, 'file'), "\n")

endfunction

