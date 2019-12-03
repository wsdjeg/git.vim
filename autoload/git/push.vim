let s:JOB = SpaceVim#api#import('job')

function! git#push#run(...)

    let g:wsd = a:000
    let cmd = ['git', 'push']
    if len(a:1) > 0
        let cmd += a:1
    endif
    call s:JOB.start(cmd,
                \ {
                \ 'on_stdout' : function('s:on_stdout'),
                \ 'on_stderr' : function('s:on_stderr'),
                \ 'on_exit' : function('s:on_exit'),
                \ }
                \ )

endfunction

function! s:on_exit(...) abort
    let data = get(a:000, 2)
    if data != 0
        echo 'failed!'
    else
        echo 'done!'
    endif
endfunction


function! s:on_stdout(id, data, event) abort
    for line in filter(a:data, '!empty(v:val)')
        exe 'Echo ' . line
    endfor
endfunction

function! s:on_stderr(id, data, event) abort
    for line in filter(a:data, '!empty(v:val)')
        exe 'Echoerr ' . line
    endfor
endfunction
