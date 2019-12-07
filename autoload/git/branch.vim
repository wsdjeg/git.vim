let s:JOB = SpaceVim#api#import('job')

function! git#branch#run(args)

    if len(a:args) == 0
        let cmd = ['git', 'branch'] 
    else
        let cmd = ['git', 'branch'] + a:args
    endif
    call git#logger#info('git-branch cmd:' . string(cmd))
    call s:JOB.start(cmd,
                \ {
                \ 'on_stderr' : function('s:on_stderr'),
                \ 'on_stdout' : function('s:on_stdout'),
                \ 'on_exit' : function('s:on_exit'),
                \ }
                \ )

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
function! s:on_exit(id, data, event) abort
    call git#logger#info('git-branch exit data:' . string(a:data))
    if a:data ==# 0
        echo 'done!'
    else
        echo 'failed!'
    endif
endfunction

function! git#branch#complete(ArgLead, CmdLine, CursorPos)

    return "%\n" . join(getcompletion(a:ArgLead, 'file'), "\n")

endfunction

function! git#branch#current()
    let head = system('git branch --show-current')
    if !v:shell_error
        return trim(head)
    else
        return ''
    endif
endfunction
