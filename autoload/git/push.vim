let s:JOB = SpaceVim#api#import('job')
let s:NOTI =SpaceVim#api#import('notification')

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
        call s:NOTI.notification(line, 'Normal')
    endfor
endfunction

function! s:on_stderr(id, data, event) abort
    for line in filter(a:data, '!empty(v:val)')
        call s:NOTI.notification(line, 'WarningMsg')
    endfor
endfunction

function! git#push#complete(ArgLead, CmdLine, CursorPos)
    let str = a:CmdLine[:a:CursorPos-1]
    if str =~# '^Git\s\+push\s\+[^ ]*$'
        return join(s:remotes(), "\n")
    else
        let remote = matchstr(str, '\(Git\s\+push\s\+\)\@<=[^ ]*')
        return s:remote_branch(remote)
    endif
endfunction

function! s:remotes() abort
    return map(systemlist('git remote'), 'trim(v:val)')
endfunction

function! s:remote_branch(remote) abort
    let branchs = systemlist('git branch -a')
    if v:shell_error
        return ''
    else
        let branchs = join(map(filter(branchs, 'v:val =~ "\s*remotes/" . a:remote . "/[^ ]*$"'), 'trim(v:val)[len(a:remote) + 9:]'), "\n")
        return branchs
    endif
endfunction
