let s:JOB = SpaceVim#api#import('job')
let s:BUFFER = SpaceVim#api#import('vim#buffer')

function! git#blame#run(...)
    if len(a:1) == 0
        let cmd = ['git', 'blame', '--line-porcelain', expand('%')] 
    else
        let cmd = ['git', 'blame', '--line-porcelain'] + a:1
    endif
    let s:lines = []
    call git#logger#info('git-blame cmd:' . string(cmd))
    call s:JOB.start(cmd,
                \ {
                \ 'on_stderr' : function('s:on_stderr'),
                \ 'on_stdout' : function('s:on_stdout'),
                \ 'on_exit' : function('s:on_exit'),
                \ }
                \ )
endfunction

function! s:on_stdout(id, data, event) abort
    for data in a:data
        call git#logger#info('git-blame stdout:' . data)
    endfor
    let s:lines += a:data
endfunction
function! s:on_stderr(id, data, event) abort
    for data in a:data
        call git#logger#info('git-blame stderr:' . data)
    endfor
endfunction
function! s:on_exit(id, data, event) abort
    call git#logger#info('git-blame exit data:' . string(a:data))
    let rst = s:parser(s:lines)
    if !empty(rst)
        let s:blame_buffer_nr = s:openBlameWindow()
        call s:BUFFER.buf_set_lines(s:blame_buffer_nr, 0 , -1, 0, map(deepcopy(rst), 'v:val.summary'))
        let fname = rst[0].filename
        let s:blame_show_buffer_nr = s:openBlameShowWindow(fname)
        call s:BUFFER.buf_set_lines(s:blame_show_buffer_nr, 0 , -1, 0, map(deepcopy(rst), 'v:val.line'))
    endif
endfunction


function! s:openBlameWindow() abort
    tabedit git://blame
    normal! "_dd
    setl nobuflisted
    setl nomodifiable
    setl scrollbind
    setl nonumber norelativenumber
    setl buftype=nofile
    setf git-blame
    setlocal bufhidden=wipe
    nnoremap <buffer><silent> q :bd!<CR>
    return bufnr()
endfunction

function! s:openBlameShowWindow(fname) abort
    exe 'rightbelow vsplit git://blame:show/' . a:fname
    normal! "_dd
    setl nobuflisted
    setl nomodifiable
    setl buftype=nofile
    setlocal bufhidden=wipe
    nnoremap <buffer><silent> q :bd!<CR>
    return bufnr()
endfunction

" 1cca0b8676d664d2ea2f9b0756d41967fc8481fb 1 1 5
" author Shidong Wang
" author-mail <wsdjeg@outlook.com>
" author-time 1578202864
" author-tz +0800
" committer Shidong Wang
" committer-mail <wsdjeg@outlook.com>
" committer-time 1578202864
" committer-tz +0800
" summary Add git blame support
" filename autoload/git/blame.vim
" let s:JOB = SpaceVim#api#import('job')
function! s:parser(lines) abort
    let rst = []
    let obj = {}
    for line in a:lines
        if line =~# '^summary'
            call extend(obj, {'summary' : line[8:]})
        elseif line =~# '^filename'
            call extend(obj, {'filename' : line[9:]})
        elseif line =~# '^\t'
            call extend(obj, {'line' : line[1:]})
        else
            if !empty(obj) && has_key(obj, 'summary') && has_key(obj, 'line')
                call add(rst, obj)
            endif
            let obj = {}
        endif
    endfor
    return rst
endfunction

function! git#blame#complete(ArgLead, CmdLine, CursorPos)

    return "%\n" . join(getcompletion(a:ArgLead, 'file'), "\n")

endfunction

