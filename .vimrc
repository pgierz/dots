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
"                                                                                                                         
"
"
"
"
"
"
"
"




if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')
" Some good colors (maybe)
Plug 'arcticicestudio/nord-vim'
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'koalaman/shellcheck'
Plug 'vim-syntastic/syntastic'
Plug 'tomtom/checksyntax_vim'
Plug 'vim-airline/vim-airline'
Plug 'szymonmaszke/vimpyter' "vim-plug
call plug#end()

colorscheme nord
let g:airline_powerline_fonts = 1
set number relativenumber
syntax on
set expandtab
set smarttab

" Set the cursor to be different depending on the mode:
let &t_SI = "\<Esc>[6 q"
let &t_EI = "\<Esc>[2 q"

set background=dark

" A snippet for making functions quickly
let @f='<<Ifunction A { }'
set guifont=Hack\ Regular\ Nerd\ Font\ Complete:h16
