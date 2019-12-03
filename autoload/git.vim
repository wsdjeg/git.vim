"=============================================================================
" git.vim
" Copyright (c) 2016-2019 Wang Shidong & Contributors
" Author: Wang Shidong < wsdjeg@outlook.com >
" URL: https://spacevim.org
" License: GPLv3
"=============================================================================


function! git#run(...)
    let cmd = get(a:000, 0, '')
    if cmd ==# 'add'
        call git#add#run(a:000[1:])
    elseif cmd ==# 'push'
        call git#push#run(a:000[1:])
    else
    endif
endfunction
