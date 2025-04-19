" Basic settings
set nocompatible                   " Use Vim settings, rather than Vi settings
syntax enable                      " Enable syntax highlighting
filetype plugin indent on          " Enable file type detection
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

" Cursor visibility
set cursorline                     " Highlight current line
" set nocursorline                   " Do not highlight current line
highlight CursorLine cterm=bold ctermbg=234 guibg=Grey15
highlight Cursor ctermfg=Black ctermbg=Green

" File type specific indentation
augroup indentation_settings
    autocmd!
    " Use spaces for Python
    autocmd FileType python setlocal expandtab tabstop=4 softtabstop=4 shiftwidth=4
    
    " Use tabs for Debian control files
    autocmd BufRead,BufNewFile **/debian/control,**/debian/rules,**/debian/changelog setlocal noexpandtab tabstop=8 softtabstop=8 shiftwidth=8
    
    " Use tabs for Makefiles
    autocmd FileType make setlocal noexpandtab tabstop=8 shiftwidth=8
    
    " Use spaces for shell scripts
    autocmd FileType sh,bash setlocal expandtab tabstop=4 softtabstop=4 shiftwidth=4
augroup END

" Search
set incsearch                      " Search as characters are entered
set hlsearch                       " Highlight matches
set ignorecase                     " Ignore case when searching
set smartcase                      " Override 'ignorecase' if search contains uppercase

" File handling
set confirm                        " Prompt to save changes
set autoread                       " Automatically read file changes from outside
set hidden                         " Allow buffer switching without saving
set nobackup                       " Don't create backup files
set noswapfile                     " Don't create swap files
set undofile                       " Persistent undo
set undodir=~/.vim/undodir         " Where to save undo histories
set history=1000                   " Command history

" Navigation and editing
set scrolloff=15                   " Keep 8 lines above/below cursor when scrolling
set sidescrolloff=8                " Keep 8 columns left/right of cursor when scrolling horizontally
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

" Folding
set foldmethod=indent              " Fold based on indentation
set foldnestmax=10                 " Maximum fold nesting level
set nofoldenable                   " Don't fold by default

" Enable persistent registers between vim sessions
set viminfo='100,<1000,s10,h,\"1000,n~/.vim/viminfo

" Explicitly read viminfo on startup and write on exit
autocmd VimEnter * rviminfo
autocmd VimLeave * wviminfo

" Create directory and file if they don't exist
if !isdirectory($HOME."/.vim")
    call mkdir($HOME."/.vim", "p", 0700)
endif