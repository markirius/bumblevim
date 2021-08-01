#!/bin/bash
# bumblevim.sh
#
# Install a vim environment for better usage as a text code
#
# Version 1: Install vim files and venvs to make vim a python code editor
# Version 2: The script now write needed files without copy from any source
#
# Marcos, March 2021
#

# set destination folder for venvs
DESTINATION=.venvs

# set script path
export SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"
export DIR="$(dirname "$SCRIPT")"

packages() {
    echo black
    echo flake8
    echo isort
    echo jedi
    echo pylint
}

validate() {
    if [[ ! $(node --version) ]]
    then
        echo "[!] Please install nodejs."
        exit
    fi

    if [[ ! $(npm --version) ]]
    then
        echo "[!] Please install npm."
        exit
    fi

    if [[ ! $(python --version) ]]
    then
        echo "[!] Please install python 3."
        exit
    fi

    if [[ ! $(pip --version) ]]
    then
        echo "[!] Please install python pip."
        exit
    fi
}

helptext() {
    echo "
    -i --install     install vim files and some venvs
    -u --update      update vim files, installed components and venvs
    -v --vimupdate   update and upgrade vim plugins
    --venv           install only necessary venvs
    -h --help        show this help
    "
}

install_venvs() {
    if [[ $(python --version) ]] && [[ $(pip --version) ]]
    then
	if [[ ! -d $HOME/$DESTINATION ]]
	then
          mkdir $HOME/$DESTINATION
	fi
        for package in $( packages )
        do
            $(python -m venv $HOME/$DESTINATION/$package)
            cd $HOME/$DESTINATION/$package
            echo $(pwd)
            . bin/activate
            pip install -U pip
            pip install $package
            deactivate
        done
    else
        echo "[!] There's no python interpreter or pip on system!"
        exit
    fi
}

update_venvs() {
    if [[ $(python --version) ]] && [[ $(pip --version) ]]
    then
        for package in $( packages )
        do
            cd $HOME/$DESTINATION/$package
            . bin/activate
            pip install -U pip
            pip install -U $package
            deactivate
	    cd $DIR
        done
    else
        echo "[!] There's no python interpreter on system!"
        exit
    fi
}

write_vimrc() {
cat << EOF > $HOME/.vimrc
syntax on
set term=xterm
set mouse=a
set cursorline
set encoding=utf-8
set nocompatible
set t_Co=256

colorscheme codedark
let g:airline_theme = 'codedark'

call plug#begin('~/.vim/plugged')

" Make sure you use single quotes

" https://github.com/neoclide/coc.nvim
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" https://github.com/preservim/nerdtree
Plug 'preservim/nerdtree'

" https://github.com/mattn/emmet-vim
Plug 'mattn/emmet-vim'

" https://github.com/junegunn/fzf.vim
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" https://github.com/tpope/vim-fugitive.git
Plug 'https://github.com/tpope/vim-fugitive.git'

" https://github.com/OmniSharp/omnisharp-vim
Plug 'OmniSharp/omnisharp-vim'

call plug#end()

" General configuration
" setting horizontal and vertical splits
set splitbelow
set splitright

" Use external vimrc files for plugin sources
source $HOME/.vim/vimrc/coc.vimrc
source $HOME/.vim/vimrc/python.vimrc
source $HOME/.vim/vimrc/nerdtree.vimrc
source $HOME/.vim/vimrc/web.vimrc
source $HOME/.vim/vimrc/bash.vimrc
source $HOME/.vim/vimrc/csharp.vimrc
source $HOME/.vim/vimrc/autoclose.vimrc
EOF
}

write_coc_settings() {
cat << EOF > $HOME/.vim/coc-settings.json
{
  // python
  "python.pythonPath": "python",
  "python.venvPath": "$HOME/.venvs/",

  // jedi
  "python.jediPath": "$HOME/.venvs/jedi/lib/python3.9/site-packages/",
  "python.jediEnabled": true,
  "suggest.timeout": 5000,

  // formatting
  "python.formatting.provider": "black",
  "python.formatting.blackPath":"$HOME/.venvs/black/bin/black",

  // pylint
  "python.linting.pylintEnabled": false,
  "python.linting.pylintPath": "$HOME/.venvs/pylint/bin/pylint",

  // flake8
  "python.linting.flake8Enabled": true,
  "python.linting.flake8Path": "$HOME/.venvs/flake8/bin/flake8",

  // isort
  "python.sortImports.path": "$HOME/.venvs/isort/bin/isort"
}
EOF
}

write_autoclose_rc() {
cat << EOF > $HOME/.vim/vimrc/autoclose.vimrc
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" AutoClose.vim - Automatically close pair of characters: ( with ), [ with ], { with }, etc.
" Version: 1.1
" Author: Thiago Alves <thiago.salves@gmail.com>
" Maintainer: Thiago Alves <thiago.salves@gmail.com>
" URL: http://thiagoalves.org
" Licence: This script is released under the Vim License.
" Last modified: 08/25/2008
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:debug = 1

" check if script is already loaded
if s:debug == 0 && exists("g:loaded_AutoClose")
    finish "stop loading the script"
endif
let g:loaded_AutoClose = 1

let s:global_cpo = &cpo " store compatible-mode in local variable
set cpo&vim             " go into nocompatible-mode

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:GetNextChar()
    if col('$') == col('.')
        return "\0"
    endif
    return strpart(getline('.'), col('.')-1, 1)
endfunction

function! s:GetPrevChar()
    if col('.') == 1
        return "\0"
    endif
    return strpart(getline('.'), col('.')-2, 1)
endfunction

function! s:IsEmptyPair()
    let l:prev = s:GetPrevChar()
    let l:next = s:GetNextChar()
    if l:prev == "\0" || l:next == "\0"
        return 0
    endif
    return get(s:charsToClose, l:prev, "\0") == l:next
endfunction

function! s:GetCurrentSyntaxRegion()
    return synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
endfunction

function! s:GetCurrentSyntaxRegionIf(char)
    let l:origin_line = getline('.')
    let l:changed_line = strpart(l:origin_line, 0, col('.')-1) . a:char . strpart(l:origin_line, col('.')-1)
    call setline('.', l:changed_line)
    let l:region = synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
    call setline('.', l:origin_line)
    return l:region
endfunction

function! s:IsForbidden(char)
    let l:result = index(s:protectedRegions, s:GetCurrentSyntaxRegion()) >= 0
    if l:result
        return l:result
    endif
    let l:region = s:GetCurrentSyntaxRegionIf(a:char)
    let l:result = index(s:protectedRegions, l:region) >= 0
    return l:result && l:region == 'Comment'
endfunction

function! s:InsertPair(char)
    let l:next = s:GetNextChar()
    let l:result = a:char
    if s:running && !s:IsForbidden(a:char) && (l:next == "\0" || l:next !~ '\w')
        let l:result .= s:charsToClose[a:char] . "\<Left>"
    endif
    return l:result
endfunction

function! s:ClosePair(char)
    if s:running && s:GetNextChar() == a:char
        let l:result = "\<Right>"
    else
        let l:result = a:char
    endif
    return l:result
endfunction

function! s:CheckPair(char)
    let l:lastpos = 0
    let l:occur = stridx(getline('.'), a:char, l:lastpos) == 0 ? 1 : 0

    while l:lastpos > -1
        let l:lastpos = stridx(getline('.'), a:char, l:lastpos+1)
        if l:lastpos > col('.')-2
            break
        endif
        if l:lastpos >= 0
            let l:occur += 1
        endif
    endwhile

    if l:occur == 0 || l:occur%2 == 0
        " Opening char
        return s:InsertPair(a:char)
    else
        " Closing char
        return s:ClosePair(a:char)
    endif
endfunction

function! s:Backspace()
    if s:running && s:IsEmptyPair()
        return "\<BS>\<Del>"
    endif
    return "\<BS>"
endfunction

function! s:ToggleAutoClose()
    let s:running = !s:running
    if s:running
        echo "AutoClose ON"
    else
        echo "AutoClose OFF"
    endif
endfunction

function! s:SetVEAll()
    let s:save_ve = &ve
    set ve=all
    return ""
endfunction

function! s:RestoreVE()
    exec "set ve=" . s:save_ve
    unlet s:save_ve
    return ""
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Configuration
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let user define which character he/she wants to autocomplete
if exists("g:AutoClosePairs") && type(g:AutoClosePairs) == type({})
    let s:charsToClose = g:AutoClosePairs
    unlet g:AutoClosePairs
else
    let s:charsToClose = {'(': ')', '{': '}', '[': ']', '"': '"', "'": "'"}
endif

" let user define in which regions the autocomplete feature should not occur
if exists("g:AutoCloseProtectedRegions") && type(g:AutoCloseProtectedRegions) == type([])
    let s:protectedRegions = g:AutoCloseProtectedRegions
    unlet g:AutoCloseProtectedRegions
else
    let s:protectedRegions = ["Comment", "String", "Character"]
endif

" let user define if he/she wants the plugin turned on when vim start. Defaul is YES
if exists("g:AutoCloseOn") && type(g:AutoCloseOn) == type(0)
    let s:running = g:AutoCloseOn
    unlet g:AutoCloseOn
else
    let s:running = 1
endif

" create appropriate maps to defined open/close characters
for key in keys(s:charsToClose)
    if key == '"'
        let open_func_arg = '"\""'
        let close_func_arg = '"\""'
    else
        let open_func_arg = '"' . key . '"'
        let close_func_arg = '"' . s:charsToClose[key] . '"'
    endif

    if key == s:charsToClose[key]
        exec "inoremap <silent> " . key . " <C-R>=<SID>SetVEAll()<CR><C-R>=<SID>CheckPair(" . open_func_arg . ")<CR><C-R>=<SID>RestoreVE()<CR>"
    else
        exec "inoremap <silent> " . s:charsToClose[key] . " <C-R>=<SID>SetVEAll()<CR><C-R>=<SID>ClosePair(" . close_func_arg . ")<CR><C-R>=<SID>RestoreVE()<CR>"
        exec "inoremap <silent> " . key . " <C-R>=<SID>SetVEAll()<CR><C-R>=<SID>InsertPair(" . open_func_arg . ")<CR><C-R>=<SID>RestoreVE()<CR>"
    endif
endfor
exec "inoremap <silent> <BS> <C-R>=<SID>SetVEAll()<CR><C-R>=<SID>Backspace()<CR><C-R>=<SID>RestoreVE()<CR>"

" Define convenient commands
command! AutoCloseOn :let s:running = 1
command! AutoCloseOff :let s:running = 0
command! AutoCloseToggle :call s:ToggleAutoClose()
EOF
}

write_bash_rc() {
cat << EOF > $HOME/.vim/vimrc/bash.vimrc
au BufRead,BufNewFile *.sh
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
EOF
}

write_coc_rc() {
cat << EOF > $HOME/.vim/vimrc/coc.vimrc
" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
EOF
}

write_nerdtree_rc() {
cat << EOF > $HOME/.vim/vimrc/nerdtree.vimrc
" ----- NERDTree settings -----
let g:NERDTreeQuitOnOpen = 1
let NERDTreeMapActivateNode='<space>'

nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

" Open the existing NERDTree on each new tab.
autocmd BufWinEnter * silent NERDTreeMirror


" If more than one window and previous buffer was NERDTree, go back to it.
autocmd BufEnter * if bufname('#') =~# "^NERD_tree_" && winnr('$') > 1 | b# | endif
EOF
}

write_python_rc() {
cat << EOF > $HOME/.vim/vimrc/python.vimrc
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
EOF
}

write_web_rc() {
cat << EOF > $HOME/.vim/vimrc/web.vimrc
" ----- Web development -----
au BufNewFile,BufRead *.js,*.html,*.css
    \ set nu |
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2 |
EOF
}

write_csharp_rc() {
cat << EOF > $HOME/.vim/vimrc/csharp.vimrc
au BufRead,BufNewFile *.cs
    \ set nu |
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set expandtab |
    \ set autoindent |
    " setting horizontal and vertical splits
    \ set splitbelow |
    \ set splitright |
    " end setting
    \ set fileformat=unix |
    \ set retab |
EOF
}

write_all_rc() {
    write_autoclose_rc
    write_bash_rc
    write_coc_rc
    write_nerdtree_rc
    write_python_rc
    write_web_rc
    write_csharp_rc
}

vim_powerup() {
    if [[ $(vim --version ) ]]
    then
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        write_vimrc
    if [[ ! -d $HOME/.vim/vimrc ]]
	then
	    mkdir -p $HOME/.vim/vimrc
	fi
        if [[ ! $(node --help) || ! $(npm --help) ]]
        then
            write_vimrc
            write_coc_settings
            write_all_rc
            vim -c ":PlugInstall" -c sleep 5 -c :qa!
            vim -c ":CocInstall coc-python" -c "sleep 5" -c qa!
            vim -c ":CocInstall coc-css" -c "sleep 5" -c qa!
            vim -c ":CocInstall coc-html" -c "sleep 5" -c :qa!
            clear
            echo "[!] Plugins install complete."
	fi
    fi
}

vim_update() {
    vim -c :PluginUpdate -c sleep 5 -c :qa!
    vim -c :PluginUpgrade -c sleep 5 -c :qa!
}

vim_backup() {
    BACKUP=backup-$(date +%d-%m-%Y)
    if [[ ! -d $BACKUP ]]
    then
        mkdir $DIR/$BACKUP
        if [[ -f $HOME/.vimrc ]]
        then
            cp $HOME/.vimrc $DIR/$BACKUP
        fi
        if [[ -d $HOME/.vim ]]
        then
            cp -r $HOME/.vim $DIR/$BACKUP
        fi
    else
        echo "[!] Backup has already been made."
    fi
}

case "$1" in

    -i | --install)
        validate
        vim_backup
        install_venvs
        vim_powerup
    ;;

    -u | --update)
        update_venvs
        vim_update
    ;;

    --venv)
        install_venvs
    ;;

    -h | --help)
        helptext
    ;;

    *)
        validate
        vim_backup
        install_venvs
        vim_powerup
    ;;

esac
