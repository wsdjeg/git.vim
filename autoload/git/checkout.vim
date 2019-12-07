let s:JOB = SpaceVim#api#import('job')

function! git#checkout#run(args)

    let cmd = ['git', 'checkout'] + a:args
    call git#logger#info('git-checkout cmd:' . string(cmd))
    call s:JOB.start(cmd,
                \ {
                \ 'on_exit' : function('s:on_exit'),
                \ }
                \ )

endfunction

function! s:on_exit(id, data, event) abort
    call git#logger#info('git-checkout exit data:' . string(a:data))
    if a:data ==# 0
        echo 'done!'
    else
        echo 'failed!'
    endif
endfunction

function! git#checkout#complete(ArgLead, CmdLine, CursorPos)

    return "%\n" . join(getcompletion(a:ArgLead, 'file'), "\n")

endfunction

