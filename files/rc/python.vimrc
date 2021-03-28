highlight BadWhitespace ctermbg=red guibg=darkred
au BufRead,BufNewFile *.py,*.pyw
    \ set nu |
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=79 |
    \ set expandtab |
    \ set autoindent |
    " setting horizontal and vertical splits
    \ set splitbelow |
    \ set splitright |
    " end setting
    \ set fileformat=unix |
    \ match BadWhitespace /\s\+$/ |
    \ set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\" |
    \ set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m |
    \ nmap <F5> :term python %<CR> |

au BufWritePre *.py
    \ execute ':CocCommand python.sortImports'

