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

setup_starship()
{
  cat > ~/.config/starship.toml << "EOF"
# v0.1
# format = """[](fg:235)[](bg:235)$username$hostname$directory$git_branch$time[i](fg:235 bg:235)[](fg:235) $character """
format = """$username$hostname$directory$git_branch(fg:235)(fg:235) $character """

add_newline=false

[username]
disabled = false
show_always = false
format = "[$user]($style)"
style_user = "fg:203"

[hostname]
disabled = false
ssh_only = true
format = "[  $hostname]($style)"
style = "fg:222"

[character]
success_symbol = "[](fg:077)"
error_symbol = "[](fg:160)"

[directory]
format = "[  $path]($style)"
style = "fg:183 italic"
truncation_length = 2
truncate_to_repo = true
truncation_symbol = "…/"
fish_style_pwd_dir_length = 0

[cmd_duration]
format = " took [$duration]($style)"
style = "039"
min_time = 10

[time]
disabled = true
format = "[  $time]($style)"
style = "fg:203 bg:235"

[git_branch]
style = "bold fg:140"
format = "[  $branch]($style)"

[git_status]
style = "fg:248"
EOF
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

export PATH=/home/cloudyy/.local/bin:$PATH
eval "$(starship init bash)"

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

setup_date()
{
  sudo pacman -Syy ntp
  sudo rm /etc/ntp.conf 

  sudo cat > /etc/ntp.conf << "EOF"
# Please consider joining the pool:
#
#     http://www.pool.ntp.org/join.html
#
# For additional information see:
# - https://wiki.archlinux.org/index.php/Network_Time_Protocol_daemon
# - http://support.ntp.org/bin/view/Support/GettingStarted
# - the ntp.conf man page

# Associate to Arch's NTP pool
server a.st1.ntp.br iburst nts
server b.st1.ntp.br iburst nts
server c.st1.ntp.br iburst nts
server d.st1.ntp.br iburst nts
server gps.ntp.br iburst nts

# By default, the server allows:
# - all queries from the local host
# - only time queries from remote hosts, protected by rate limiting and kod
restrict default kod limited nomodify nopeer noquery notrap
restrict 127.0.0.1
restrict ::1
                                                                                                                                       
# Location of drift file                                                                                                               
driftfile /var/lib/ntp/ntp.drift
EOF

  sudo systemctl start ntpd
  sudo systemctl enable ntpd
  sudo ntpd
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
  echo "10) Setup Starship"
  echo "11) Set date/time"
  echo "0) Exit"
  echo 
  read -p "[0 ~ 10] -> " opt

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
    10 ) setup_starship;;
    11 ) setup_date;;
    0 ) echo "Bye"; exit;;
  esac
done
