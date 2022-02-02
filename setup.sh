#!/bin/bash
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

AUR_PACKAGES=(
  'albert-git',
  'remarkable'
)

PACMAN_PACKAGES="unzip nodejs npm yarn openssh go flatpak wget linux-headers intel-media-driver android-tools sshd blueman discord filezilla gimp kdenlive steam lib32-alsa-plugins lib32-libpulse lib32-openal"

FLATPAK_PACKAGES=(
  'org.telegram.desktop'
  'com.obsproject.Studio'
  'com.github.phase1geo.minder'
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

setup_git()
{
  
  read -p "Git email: " GIT_EMAIL
  read -p "Git username: " GIT_USER

  cat > .gitconfig << EOF
[user]
	email = $GIT_EMAIL
	name = $GIT_USER
[core]
	editor = nvim

EOF
  cp .gitconfig ~/
}

setup_ssh()
{
  cp .ssh ~/.ssh
}

setup_bash_zshrc_others()
{
  BASHPATH="~/.bashrc"
  ZSHRCPATH="~/.zshrc"
  
  # > = create file
  # >> append
  cat > $BASHPATH << "EOF"
#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
EOF
  
  cat >> $ZSHRCPATH << "EOF"
env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi

unset env
EOF

  cp .albertignore ~/
}

setup_pacman_packages()
{
  pacman -Syy $PACMAN_PACKAGES
}

setup_flatpak_packages()
{
  for P in "${FLATPAK_PACKAGES[@]}"; do
    echo "Flatpak: $P"
    flatpak install $P 
  done
} 

setup_aur_packages()
{
  for PACKAGE in "${AUR_PACKAGES[@]}"; do 
    git clone https://aur.archlinux.org/"$PACKAGE".git && cd $PACKAGE && makepkg -si && cd ..
  done
}

while true; do 
  echo "1) Setup Nvim"
  echo "2) Setup Fonts"
  echo "3) Setup Mirrorlist [root]"
  echo "4) Setup git"
  echo "5) Setup ssh"
  echo "6) Setup bashrc/zshrc (and others)"
  echo "7) Install pacman packages [root]"
  echo "8) Install flatpak packages"
  echo "9) Install AUR packages"
  echo "0) Exit"
  echo 
  read -p "[0 ~ 9] -> " opt

  case $opt in
    1 ) setup_nvim;;
    2 ) setup_fonts;;
    3 ) setup_mirrorlist;;
    4 ) setup_git;;
    5 ) setup_ssh;;
    6 ) setup_bash_zshrc_others;;
    7 ) setup_pacman_packages;;
    8 ) setup_flatpak_packages;;
    9 ) setup_aur_packages;;
    0 ) echo "Bye"; exit;;
  esac
done
