# BR Arch mirrors
MIRRORS_URL=(
  'Server = http://ca.us.mirror.archlinux-br.org/$repo/os/$arch'
  'Server = http://mirror.rackspace.com/archlinux/$repo/os/$arch'
  'Server = https://america.mirror.pkgbuild.com/$repo/os/$arch'
  'Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch'
  'Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch'
  'Server = rsync://archlinux.c3sl.ufpr.br/archlinux/$repo/os/$arch'
  'Server = rsync://archlinux.pop-es.rnp.br/archlinux/$repo/os/$arch'
)

setup_fonts()
{
  cp .fonts/ ~/.fonts/
  fc-cache -f -v
}

setup_nvim()
{
  if [ -d ~/.config/nvim ]; then
    mv ~/.config/nvim ~/.config/nvim.BACKUP
    cp .config/nvim ~/.config/nvim
    setup_fonts
    nvim +'hi NormalFloat guibg=#1e222a' +PackerSync
  else
    cp .config/nvim ~/.config/nvim
    setup_fonts
    nvim +'hi NormalFloat guibg=#1e222a' +PackerSync
  fi
}

setup_mirrorlist()
{
  rm /etc/pacman.d/mirrorlist

  for M in "${MIRRORS_URL[@]}"; do
    echo "$M" >> /etc/pacman.d/mirrorlist
  done

  pacman -Syy
}

while true; do 
  echo "1) Setup Nvim"
  echo "2) Setup Fonts"
  echo "3) Setup Mirrorlist [root]"
  echo "4) Exit"
  echo 
  read -p "[1 ~ 4] -> " opt

  case $opt in
    1 ) setup_nvim;;
    2 ) setup_fonts;;
    3 ) setup_mirrorlist;;
    4 ) echo "Bye"; exit;;
  esac
done
