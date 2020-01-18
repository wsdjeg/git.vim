""
" @section git-stash, stash
" @parentsection commands
" This commands is to manage git stash.
" >
"   :Git stash list
" <

let s:JOB = SpaceVim#api#import('job')
let s:NOTI =SpaceVim#api#import('notification')

function! git#stash#run(args)

    let cmd = ['git', 'stash'] + a:args
    let subcmd = get(a:args, 0, '')
    if !empty(subcmd) && index(['drop'], subcmd) > -1
        let subcmd = subcmd . '_'
    else
        let subcmd = ''
    endif

    call git#logger#info('git-stash cmd:' . string(cmd))
    call s:JOB.start(cmd,
                \ {
                \ 'on_stderr' : function('s:on_' . subcmd . 'stderr'),
                \ 'on_stdout' : function('s:on_' . subcmd . 'stdout'),
                \ 'on_exit'   : function('s:on_' . subcmd . 'exit'),
                \ }
                \ )
endfunction

function! s:on_stdout(id, data, event) abort
    for line in filter(a:data, '!empty(v:val)')
        call git#logger#info('git-stash stdout:' . line)
        call s:NOTI.notification(line, 'Normal')
    endfor
endfunction

function! s:on_stderr(id, data, event) abort
    for data in a:data
        call git#logger#info('git-stash stderr:' . data)
    endfor
endfunction

function! s:on_exit(id, data, event) abort
    call git#logger#info('git-stash exit data:' . string(a:data))
    if a:data ==# 0
        " echo 'done!'
    else
        " echo 'failed!'
    endif
endfunction

function! s:on_drop_stdout(id, data, event) abort
    for line in filter(a:data, '!empty(v:val)')
        call git#logger#info('git-stash stdout:' . line)
        call s:NOTI.notification(line, 'Normal')
    endfor
endfunction

function! s:on_drop_stderr(id, data, event) abort
    for line in filter(a:data, '!empty(v:val)')
        call git#logger#info('git-stash stdout:' . line)
        call s:NOTI.notification(line, 'WarningMsg')
    endfor
endfunction

function! s:on_drop_exit(id, data, event) abort
    call git#logger#info('git-stash exit data:' . string(a:data))
    if a:data ==# 0
        " echo 'done!'
    else
        " echo 'failed!'
    endif
endfunction

function! s:sub_commands() abort
    return join([
                \ 'list',
                \ 'show',
                \ 'drop',
                \ 'pop', 'apply',
                \ 'branch',
                \ 'clear',
                \ 'save',
                \ 'push',
                \ ],
                \ "\n")
endfunction

function! git#stash#complete(ArgLead, CmdLine, CursorPos)

    let str = a:CmdLine[:a:CursorPos-1]
    if str =~# '^Git\s\+stash\s\+[a-z]\=$'
        return s:sub_commands()
    else
        return ''
    endif

endfunction

