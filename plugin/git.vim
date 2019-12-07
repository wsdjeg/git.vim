"=============================================================================
" git.vim --- git plugin for spacevim
" Copyright (c) 2016-2019 Wang Shidong & Contributors
" Author: Wang Shidong < wsdjeg@outlook.com >
" URL: https://spacevim.org
" License: GPLv3
"=============================================================================


""
" Run git command asynchronously
command! -nargs=+ -complete=custom,git#complete Git call git#run(<f-args>)
