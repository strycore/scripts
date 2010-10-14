"
"
"
" Inspirations:
" How I boosted my Vim (nvie)
" http://nvie.com/posts/how-i-boosted-my-vim/
" http://github.com/nvie/vimrc/blob/master/vimrc
"
"
"
" Plugins
" -------
" For automatic plugin installation, see the vim-setup script
"
" NERDTree
" taglist
" command-t: https://wincent.com/products/command-t
" ack-grep
"


" Function keys:
" F1: Help
" F2: Close buffer
" F3: Toggle NERDTree
" F4: Toggle TagList
" F5: Previous buffer
" F6: Next buffer
" F7: Toggle paste mode
" F8: Toggle between action and template in symfony
" F9: Available
" F10: Available
" F11: Reserved for fullscreen switching by WM or Terminal emulator
" F12: Available

" Other shortcuts:
"
" ,/ Remove search highlight
" ,l Toggle invisible characters
" ,t open command-t filesearch
" :w!! save file with sudo
"
set nocompatible
set showcmd
set showmode
set showmatch
syntax on

set autoindent
set smartindent

set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround
set expandtab

set backspace=indent,eol,start
set copyindent
set linespace=4
set ruler
set hidden     "dont't whine when trying to move away from an unsave buffer
set ignorecase "ignore case when searching
set smartcase  " ignore case if search pattern is all lowercase,
               " case-sensitive otherwise
set hlsearch   " highlight search terms
nmap <silent> ,/ :nohlsearch<CR>
set incsearch

set foldenable
set nowrap
set gdefault
set history=1000
set undolevels=1000
set wildignore=*.swp,*.bak,*.pyc,*.class
set title
set noerrorbells
set nobackup
set noswapfile
set lazyredraw
set statusline=%<%f\ (%{&encoding})\ %h%m%r%=%-14.(%l,%c%V%)\ %P
set laststatus=2          " always show status line
set viminfo='1000,f1,:1000,/1000  " big viminfo :)

set mouse=a
set cursorline
set number
set encoding=utf8
set foldmethod=syntax
set t_Co=256
"colorscheme desert256
colorscheme railscasts
let mapleader=","
let showmarks_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
let g:showmarks_enable = 1

" Quickly edit/reload the vimrcfile
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

highlight OverLength ctermbg=red ctermfg=white guibg=#592929

match OverLength /\%81v.\+/

filetype on
filetype plugin on
filetype indent on
if has('autocmd')
    autocmd filetype python set expandtab
    autocmd FileType make setlocal ts=8 sts=8 sw=8 noexpandtab
    autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType python set omnifunc=pythoncomplete#Complete
    autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
    autocmd FileType css set omnifunc=csscomplete#CompleteCSS
    autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
    autocmd FileType php set omnifunc=phpcomplete#CompletePHP
    autocmd FileType c set omnifunc=ccomplete#Complete

    autocmd BufNewFile,BufRead *.rss setfiletype xml
    autocmd BufNewFile,BufRead *.less setfiletype css
    "Open NERDTree when Vim starts
    "Commented out until a solution is found to close NERDTree
    "when it's the only opened buffer.
    "autocmd VimEnter * NERDTree
    "autocmd VimEnter * wincmd p

    " run file with PHP CLI (CTRL-M)
    autocmd FileType php noremap <C-M> :w!<CR>:!php %<CR>

    " PHP parser check (CTRL-L)
    autocmd FileType php noremap <C-L> :!php -l %<CR>


    autocmd FileType php noremap <C-P> :!phpcs %<CR>
endif
if has("gui_running")
    highlight SpellBad term=underline gui=undercurl guisp=Orange
endif
" note: leader is backslash
nmap <leader>l :set list!<CR>
set listchars=tab:▸\ ,trail:.,extends:#,nbsp:.,eol:¬

autocmd BufRead * silent! %s/[\r \t]\+$//
autocmd BufEnter *.php :%s/[ \t\r]\+$//e

"let php_folding = 2


"Invisible character colors
highlight NonText ctermfg=DarkGray
highlight SpecialKey ctermfg=DarkGrey

"Map C-s to save
noremap <C-s> :update<CR>
inoremap <C-s> <C-o>:update<CR>
vnoremap <C-s> <C-c>:update<CR>

map <silent><A-Right> :tabnext<CR>
map <silent><A-Left> :tabprevious<CR>
noremap <silent><C-Left> <C-T>
noremap <silent><C-Right> <C-]>

noremap <C-S-PageUp> gt
noremap <C-S-pageDown> gT

inoremap <Nul> <C-x><C-o>

cmap w!! w !sudo tee % > /dev/null

"MiniBufExplorer configuration
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1
"TagList configuration
map <silent> <F4> :TlistToggle<CR>
let Tlist_Exit_OnlyWindow = 1
let Tlist_Use_Right_Window = 1 " split to the right side of the screen
let Tlist_Sort_Type = "order" " sort by order or name
let Tlist_Compart_Format = 1 " Remove extra information and blank lines from the taglist window.
let Tlist_GainFocus_On_ToggleOpen =  0" Jump to taglist window on open.
let Tlist_Display_Tag_Scope = 1 " Show tag scope next to the tag name.
let Tlist_WinWidth = 40

set tags=.vimtags
set tags+=$HOME/.vim/tags/python.ctags
set tags+=$HOME/.vim/tags/django.ctags

"Toggle NerdTree
map <silent> <F3> :NERDTreeToggle<CR>
map <silent> <F2> :bd<CR>:vsp<CR>
"Move between buffers
map <silent> <F6> :bnext<CR>
map <silent> <F5> :bprevious<CR>
set pastetoggle=<F7>
"symfony plugin configuration
map <silent> <F8> :SfSwitchView<CR>

"Refactor variable names
nnoremap <C-r> gd[{V%:s/<C-R>///gc<left><left><left>
set path=$PWD/**

python << EOF
import os
import sys
import vim
for p in sys.path:
    if os.path.isdir(p):
        vim.command(r"set path+=%s" % (p.replace(" ", r"\ ")))
EOF
