let s:JOB = SpaceVim#api#import('job')

function! git#merge#run(args)
    if len(a:args) == 0
        finish
    else
        let cmd = ['git', 'merge'] + a:args
    endif
    call git#logger#info('git-merge cmd:' . string(cmd))
    call s:JOB.start(cmd,
                \ {
                \ 'on_stderr' : function('s:on_stderr'),
                \ 'on_stdout' : function('s:on_stdout'),
                \ 'on_exit' : function('s:on_exit'),
                \ }
                \ )

endfunction

function! s:on_exit(id, data, event) abort
    call git#logger#info('git-merge exit data:' . string(a:data))
    if a:data ==# 0
        echo 'done!'
    else
        echo 'failed!'
    endif
endfunction

function! s:on_stdout(id, data, event) abort
    for data in a:data
        call git#logger#info('git-merge stdout:' . data)
    endfor
endfunction
function! s:on_stderr(id, data, event) abort
    for data in a:data
        call git#logger#info('git-merge stderr:' . data)
    endfor
    " stderr should not be added to commit buffer
    " let s:lines += a:data
endfunction

function! git#merge#complete(ArgLead, CmdLine, CursorPos)

    return "%\n" . join(getcompletion(a:ArgLead, 'file'), "\n")

endfunction

