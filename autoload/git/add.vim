let s:JOB = SpaceVim#api#import('job')


function! git#add#run(files)

    let cmd = ['git', 'add'] + a:files
    call s:JOB.start(cmd,
                \ {
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


