"          _____                    _____                    _____                    _____                    _____          
"         /\    \                  /\    \                  /\    \                  /\    \                  /\    \         
"        /::\____\                /::\    \                /::\____\                /::\    \                /::\    \        
"       /:::/    /                \:::\    \              /::::|   |               /::::\    \              /::::\    \       
"      /:::/    /                  \:::\    \            /:::::|   |              /::::::\    \            /::::::\    \      
"     /:::/    /                    \:::\    \          /::::::|   |             /:::/\:::\    \          /:::/\:::\    \     
"    /:::/____/                      \:::\    \        /:::/|::|   |            /:::/__\:::\    \        /:::/  \:::\    \    
"    |::|    |                       /::::\    \      /:::/ |::|   |           /::::\   \:::\    \      /:::/    \:::\    \   
"    |::|    |     _____    ____    /::::::\    \    /:::/  |::|___|______    /::::::\   \:::\    \    /:::/    / \:::\    \  
"    |::|    |    /\    \  /\   \  /:::/\:::\    \  /:::/   |::::::::\    \  /:::/\:::\   \:::\____\  /:::/    /   \:::\    \ 
"    |::|    |   /::\____\/::\   \/:::/  \:::\____\/:::/    |:::::::::\____\/:::/  \:::\   \:::|    |/:::/____/     \:::\____\
"    |::|    |  /:::/    /\:::\  /:::/    \::/    /\::/    / ~~~~~/:::/    /\::/   |::::\  /:::|____|\:::\    \      \::/    /
"    |::|    | /:::/    /  \:::\/:::/    / \/____/  \/____/      /:::/    /  \/____|:::::\/:::/    /  \:::\    \      \/____/ 
"    |::|____|/:::/    /    \::::::/    /                       /:::/    /         |:::::::::/    /    \:::\    \             
"    |:::::::::::/    /      \::::/____/                       /:::/    /          |::|\::::/    /      \:::\    \            
"    \::::::::::/____/        \:::\    \                      /:::/    /           |::| \::/____/        \:::\    \           
"     ~~~~~~~~~~               \:::\    \                    /:::/    /            |::|  ~|               \:::\    \          
"                               \:::\    \                  /:::/    /             |::|   |                \:::\    \         
"                                \:::\____\                /:::/    /              \::|   |                 \:::\____\        
"                                 \::/    /                \::/    /                \:|   |                  \::/    /        
"                                  \/____/                  \/____/                  \|___|                   \/____/         
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')


" To reorder this alphabetically after adding a plugin, you can use the
" vim-ism:
"
" V (enter visual line mode)
" } (Move to the end of the paragraph)
" : sort (self explanatory, ya nerd)

Plug 'Yggdroot/indentLine'
Plug 'airblade/vim-gitgutter'
Plug 'altercation/vim-colors-solarized'
Plug 'arcticicestudio/nord-vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'jceb/vim-orgmode'
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'koalaman/shellcheck'
Plug 'python/black'
Plug 'szymonmaszke/vimpyter'
Plug 'tell-k/vim-autoflake'
Plug 'tomtom/checksyntax_vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'universal-ctags/ctags'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-syntastic/syntastic'
Plug 'whatyouhide/vim-gotham'
call plug#end()

syntax on

colorscheme nord
"colorscheme gotham
"colorscheme solarized
let g:airline_powerline_fonts = 1
set number relativenumber
set expandtab
set smarttab
set autoindent

" Set the cursor to be different depending on the mode:
let &t_SI = "\<Esc>[6 q"
let &t_EI = "\<Esc>[2 q"

set background=light
let g:airline_theme='solarized'


" A snippet for making functions quickly
let @f='<<Ifunction A { }'
set guifont=Hack\ Regular\ Nerd\ Font\ Complete:h16

" Fix backspace
set backspace=indent,eol,start

" Always kill all whitespace on save for py files
autocmd BufWritePre *.py execute ':Black'

" Settings for Syntastic
let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

noremap <Leader>y "*y
noremap <Leader>p "*p
noremap <Leader>Y "+y
noremap <Leader>P "+p
