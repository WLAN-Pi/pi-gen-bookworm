" Basic settings
set nocompatible                   " Use Vim settings, rather than Vi settings
syntax enable                      " Enable syntax highlighting
set encoding=utf-8                 " Use UTF-8 encoding
set fileencoding=utf-8             " Use UTF-8 encoding for written files

" UI configuration
colorscheme industry               " Theme
set number                         " Show line numbers
set relativenumber                 " Show relative line numbers
set wildmenu                       " Visual autocomplete for command menu
set showmatch                      " Highlight matching brackets
set laststatus=2                   " Always show status line
set ruler                          " Show cursor position
set showcmd                        " Show command in bottom bar
set noerrorbells                   " No sounds on errors
set visualbell                     " Flash screen instead of beeping

" Status line
highlight StatusLine ctermbg=234 ctermfg=250 guibg=#1c1c1c guifg=#bcbcbc
highlight StatusLineNC ctermbg=235 ctermfg=242 guibg=#262626 guifg=#6c6c6c
set statusline=
set statusline+=%{$USER=='root'?'[ROOT]\ ':''}
set statusline+=%f                " filename
set statusline+=%m                " modified flag

" Cursor visibility
set cursorline                     " Highlight current line
"set nocursorline                   " Do not highlight current line
highlight CursorLine cterm=bold ctermbg=234 guibg=Grey15
highlight Cursor ctermfg=Black ctermbg=Green

" File type specific indentation
filetype plugin indent on          " Enable file type detection

" Default indentation settings
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set smartindent

augroup indentation_settings
    autocmd!
    " Webdev
    autocmd FileType html,css,javascript,typescript,json,yaml,yml setlocal expandtab tabstop=2 softtabstop=2 shiftwidth=2

    " Debian
    autocmd BufRead,BufNewFile **/debian/control,**/debian/rules,**/debian/changelog setlocal noexpandtab tabstop=8 softtabstop=8 shiftwidth=8

    " Make
    autocmd FileType make setlocal noexpandtab tabstop=8 shiftwidth=8
    autocmd BufRead,BufNewFile Makefile,makefile setlocal noexpandtab tabstop=8 shiftwidth=8

    " Docs and logs
    autocmd FileType markdown,text,log setlocal expandtab tabstop=2 softtabstop=2 shiftwidth=2
augroup END

" Search
set incsearch                      " Search as characters are entered
set hlsearch                       " Highlight matches
set ignorecase                     " Ignore case when searching
set smartcase                      " Override 'ignorecase' if search contains uppercase

" File handling
set confirm                        " Prompt to save changes
set autoread                       " Automatically read file changes from outside
autocmd FocusGained * :checktime   " Catch changes that happened while in background
set hidden                         " Allow buffer switching without saving
set nobackup                       " Don't create backup files
set noswapfile                     " Don't create swap files
set undofile                       " Persistent undo
set undodir=~/.vim/undodir         " Where to save undo histories
set history=1000                   " Command history

" Navigation and editing
nnoremap <leader>zz :let &scrolloff=999-&scrolloff<CR>
set scrolloff=999                  " Keep center except when at beginning or end of the file
set backspace=indent,eol,start     " Make backspace work as expected
set whichwrap+=<,>,h,l             " Allow specified keys to move to the previous/next line

" Performance
set lazyredraw                     " Don't redraw during macros
set ttyfast                        " Faster redrawing

" Key mappings
let mapleader = " "                " Set leader key to space
nnoremap <leader>w :w<CR>          " Save with leader+w
nnoremap <leader>q :q<CR>          " Quit with leader+q
nnoremap <leader>h :nohlsearch<CR> " Clear search highlighting

" Window splits
nnoremap <leader>v :vsplit<CR>     " v for vertical split
nnoremap <leader>s :split<CR>      " s for split (horizontal)

" More natural split opening
set splitbelow                     " Open new horizontal splits below
set splitright                     " Open new vertical splits to the right

" Window navigation (using window prefix)
nnoremap <leader>wh <C-w>h         " Move to left window
nnoremap <leader>wj <C-w>j         " Move to window below
nnoremap <leader>wk <C-w>k         " Move to window above
nnoremap <leader>wl <C-w>l         " Move to right window

" Window resizing
nnoremap <leader>= <C-w>=          " Equal size windows
nnoremap <leader>+ <C-w>5+         " Increase height by 5
nnoremap <leader>- <C-w>5-         " Decrease height by 5
nnoremap <leader>> <C-w>5>         " Increase width by 5
nnoremap <leader>< <C-w>5<         " Decrease width by 5

" Window management
nnoremap <leader>q <C-w>c          " Close current window
nnoremap <leader>o <C-w>o          " Close all other windows

" Buffer navigation
nnoremap <leader>bn :bnext<CR>     " Next buffer
nnoremap <leader>bp :bprev<CR>     " Previous buffer
nnoremap <leader>bd :bdelete<CR>   " Delete buffer

" Session management
set sessionoptions=blank,buffers,curdir,folds,help,tabpages,winsize
nnoremap <leader>ss :mksession! ~/.vim/session.vim<CR>     " Save session
nnoremap <leader>rs :source ~/.vim/session.vim<CR>         " Restore session

" Enhanced auto-completion
set complete+=kspell
set completeopt=menuone,longest
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Enhanced jump navigation
nnoremap <leader>j :jumps<CR>
nnoremap <C-o> <C-o>zz            " Jump back and center
nnoremap <C-i> <C-i>zz            " Jump forward and center

" Track and navigate recently used files
nnoremap <leader>fr :browse oldfiles<CR>

" File explorer improvements
let g:netrw_banner = 0            " Hide banner
let g:netrw_liststyle = 3         " Tree view
let g:netrw_browse_split = 4      " Open in previous window
let g:netrw_winsize = 25          " Width of explorer
nnoremap <leader>fe :Lexplore<CR> " Toggle file explorer

" Tab navigation
nnoremap <leader>tn :tabnew<CR>    " Create new tab
nnoremap <leader>tc :tabclose<CR>  " Close current tab
nnoremap <leader>to :tabonly<CR>   " Close all other tabs
nnoremap <C-h> :tabprevious<CR>    " Previous tab with Ctrl+h
nnoremap <C-l> :tabnext<CR>        " Next tab with Ctrl+l

" Folding
set foldmethod=indent              " Fold based on indentation
set foldnestmax=10                 " Maximum fold nesting level
set nofoldenable                   " Don't fold by default
if !isdirectory($HOME."/.vim")
    call mkdir($HOME."/.vim", "p", 0700)
endif

if !isdirectory($HOME."/.vim/undodir")
    call mkdir($HOME."/.vim/undodir", "p", 0700)
endif

" Create viminfo file if it doesn't exist
if !filereadable($HOME."/.vim/viminfo")
    silent !touch ~/.vim/viminfo
    silent !chmod 600 ~/.vim/viminfo
endif

" Enable persistent registers between vim sessions
set viminfo='100,<1000,s10,h,\"1000,n~/.vim/viminfo

" Explicitly read viminfo on startup and write on exit
autocmd VimEnter * rviminfo
autocmd VimLeave * wviminfo