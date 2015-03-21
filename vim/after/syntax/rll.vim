" Vim Syntax configuration for ruby-ll grammar files.
"
" Language:   ruby-ll
" Maintainer: Yorick Peterse <yorickpeterse@gmail.com>
"
syntax clear

syn include @rubyTop syntax/ruby.vim

syn match rllKeyword "%[a-zA-Z]\+"
syn match rllComment "#.*$"
syn match rllOperator "?|+|\*"
syn match rllDelimiter '[=|]'

syn region rllRuby transparent matchgroup=rllDelimiter
                   \ start="{" end="}"
                   \ contains=@rubyTop

hi link rllKeyword  Keyword
hi link rllComment  Comment
hi link rllOperator Operator

let b:current_syntax = "rll"
