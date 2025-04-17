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

" Cursor visibility
set cursorline                     " Highlight current line
" set nocursorline                   " Do not highlight current line
highlight CursorLine cterm=bold ctermbg=234 guibg=Grey15
highlight Cursor ctermfg=Black ctermbg=Green

" Indentation
set expandtab                      " Use spaces instead of tabs
set tabstop=4                      " Number of spaces a tab counts for
set softtabstop=4                  " Number of spaces in tab when editing
set shiftwidth=4                   " Number of spaces to use for autoindent
set autoindent                     " Copy indent from current line when starting a new line
set smartindent                    " Smart autoindenting when starting a new line

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

" Create directory for undo files if doesn't exist
if !isdirectory($HOME."/.vim/undodir")
    call mkdir($HOME."/.vim/undodir", "p", 0700)
endif