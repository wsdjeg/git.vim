let s:JOB = SpaceVim#api#import('job')
let s:BUFFER = SpaceVim#api#import('vim#buffer')

function! git#reflog#run(args)
    let cmd = ['git', 'reflog'] + a:args
    let s:bufnr = s:openRefLogBuffer()
    let s:lines = []
    call git#logger#info('git-reflog cmd:' . string(cmd))
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
        call git#logger#info('git-reflog stdout:' . data)
    endfor
    let s:lines += filter(a:data, '!empty(v:val)')
endfunction
function! s:on_stderr(id, data, event) abort
    for data in a:data
        call git#logger#info('git-reflog stderr:' . data)
    endfor
    let s:lines += a:data
endfunction
function! s:on_exit(id, data, event) abort
    call git#logger#info('git-reflog exit data:' . string(a:data))
    call s:BUFFER.buf_set_lines(s:bufnr, 0 , -1, 0, s:lines)
endfunction

function! s:openRefLogBuffer() abort
    let bp = bufnr()
    edit git://reflog
    normal! "_dd
    setl nobuflisted
    setl nomodifiable
    setl nonumber norelativenumber
    setl buftype=nofile
    setl bufhidden=wipe
    setf git-reflog
    exe 'nnoremap <buffer><silent> q :b' . bp . '<Cr>'
    return bufnr()
endfunction

function! git#reflog#complete(ArgLead, CmdLine, CursorPos)

    return "%\n" . join(getcompletion(a:ArgLead, 'file'), "\n")

endfunction

function! s:show_commit() abort
    let commit = matchstr(getline('.'), '\(^*\s\+\)\@<=[a-z0-9A-Z]*')
    if empty(commit)
        return
    endif
    let s:show_commit_buffer = s:openShowCommitBuffer()
    let cmd = ['git', 'show', commit]
    let s:show_lines = []
    call s:JOB.start(cmd,
                \ {
                \ 'on_stderr' : function('s:on_show_stderr'),
                \ 'on_stdout' : function('s:on_show_stdout'),
                \ 'on_exit' : function('s:on_show_exit'),
                \ }
                \ )
endfunction

function! s:on_show_stdout(id, data, event) abort
    for data in a:data
        call git#logger#info('git-show stdout:' . data)
    endfor
    let s:show_lines += filter(a:data, '!empty(v:val)')
endfunction
function! s:on_show_stderr(id, data, event) abort
    for data in a:data
        call git#logger#info('git-show stderr:' . data)
    endfor
    let s:show_lines += filter(a:data, '!empty(v:val)')
endfunction
function! s:on_show_exit(id, data, event) abort
    call git#logger#info('git-show exit data:' . string(a:data))
    call s:BUFFER.buf_set_lines(s:show_commit_buffer, 0 , -1, 0, s:show_lines)
endfunction
function! s:openShowCommitBuffer() abort
    rightbelow vsplit git://show_commit
    normal! "_dd
    setl nobuflisted
    setl nomodifiable
    setl nonumber norelativenumber
    setl buftype=nofile
    setl bufhidden=wipe
    setf git-diff
    setl syntax=diff
    nnoremap <buffer><silent> q :q<CR>
    return bufnr()
endfunction

