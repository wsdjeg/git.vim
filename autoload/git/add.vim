let s:JOB = SpaceVim#api#import('job')


function! git#add#run(files)

    if len(a:files) == 1 && a:files[0] ==# '%'
        let cmd = ['git', 'add', expand('%')] 
    else
        let cmd = ['git', 'add'] + a:files
    endif
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

function! git#add#complete(ArgLead, CmdLine, CursorPos)

    return "%\n" . join(getcompletion(a:ArgLead, 'file'), "\n")

endfunction
