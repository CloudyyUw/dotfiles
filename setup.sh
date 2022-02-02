setup_fonts()
{
  cp .fonts/ ~/.fonts/
  fc-cache -f -v
}

if [ -d ~/.config/nvim ]; then
  mv ~/.config/nvim ~/.config/nvim.BACKUP
  cp .config/nvim ~/.config/nvim
  setup_fonts()
  nvim +'hi NormalFloat guibg=#1e222a' +PackerSync
else
  cp .config/nvim ~/.config/nvim
  setup_fonts()
  nvim +'hi NormalFloat guibg=#1e222a' +PackerSync
fi
