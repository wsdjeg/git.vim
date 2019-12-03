let s:JOB = SpaceVim#api#import('job')
function! git#push#run(...)

    let cmd = ['git', 'push']
    if a:0 > 0
        let cmd += a:000
    endif
    call s:JOB.start(cmd,
                \ {
                \ 'on_stdout' : function('s:on_stdout'),
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
    for line in a:data
        exe 'Echo ' . line
    endfor
    
endfunction
