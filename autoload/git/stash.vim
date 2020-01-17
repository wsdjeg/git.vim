""
" @section git-stash, stash
" @parentsection commands
" This commands is to manage git stash.
" >
"   :Git stash list
" <

let s:JOB = SpaceVim#api#import('job')

function! git#stash#run(args)

    let cmd = ['git', 'stash'] + a:args
    call git#logger#info('git-stash cmd:' . string(cmd))
    call s:JOB.start(cmd,
                \ {
                \ 'on_exit' : function('s:on_exit'),
                \ }
                \ )

endfunction

function! s:on_exit(id, data, event) abort
    call git#logger#info('git-stash exit data:' . string(a:data))
    if a:data ==# 0
        echo 'done!'
    else
        echo 'failed!'
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

