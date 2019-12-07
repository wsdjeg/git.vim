"=============================================================================
" git.vim
" Copyright (c) 2016-2019 Wang Shidong & Contributors
" Author: Wang Shidong < wsdjeg@outlook.com >
" URL: https://spacevim.org
" License: GPLv3
"=============================================================================

""
" @section Introduction, intro
" @library
" @order intro options config layers api faq changelog
" git.vim is a simple plugin for using git in vim and neovim.
" This plugin requires SpaceVim API and |job| support.

function! git#run(...)
    let cmd = get(a:000, 0, '')
    if cmd ==# 'add'
        call git#add#run(a:000[1:])
    elseif cmd ==# 'push'
        call git#push#run(a:000[1:])
    elseif cmd ==# 'status'
        call git#status#run(a:000[1:])
    elseif cmd ==# 'diff'
        call git#diff#run(a:000[1:])
    elseif cmd ==# 'reset'
        call git#reset#run(a:000[1:])
    elseif cmd ==# 'merge'
        call git#merge#run(a:000[1:])
    elseif cmd ==# 'rebase'
        call git#rebase#run(a:000[1:])
    elseif cmd ==# 'commit'
        call git#commit#run(a:000[1:])
    elseif cmd ==# '--log'
        call git#logger#view()
    else
        echohl WarningMsg
        echo 'Git ' . cmd . ' has not been implemented!'
        echohl None
    endif
endfunction


function! git#complete(ArgLead, CmdLine, CursorPos) abort
    let str = a:CmdLine[:a:CursorPos-1]
    if str =~# '^Git\s\+[a-zA-Z]*$'
        return join(['add', 'push', 'status', 'commit', 'diff', 'merge', 'rebase'],
                    \ "\n")
    elseif str =~# '^Git\s\+add\s\+.*$'
        return git#add#complete(a:ArgLead, a:CmdLine, a:CursorPos)
    elseif str =~# '^Git\s\+push\s\+.*$'
        return git#push#complete(a:ArgLead, a:CmdLine, a:CursorPos)
    elseif str =~# '^Git\s\+diff\s\+.*$'
        return git#diff#complete(a:ArgLead, a:CmdLine, a:CursorPos)
    elseif str =~# '^Git\s\+merge\s\+.*$'
        return git#merge#complete(a:ArgLead, a:CmdLine, a:CursorPos)
    endif
endfunction
