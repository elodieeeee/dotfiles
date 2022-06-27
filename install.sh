#!/bin/zsh

# checking user
if [[ $(whoami) = 'root' ]]; then print "Don't run as root!" && exit 1; else; fi

# setting variables
local new=(print '\n')
local missa=('')
local missb=('')
local missc=('')
local ins=()
local zsh=()
local omzsh=(~'/.oh-my-zsh')
local missing=('')
local default=()
local current=()

function install_omzsh () {
  print "Oh My Zsh doesn't appear to be installed, would you like me to install it for you? (Y/n)"
  read -sq place
  if [[ ($place = 'y') ]]
  then
    print 'Okay, installing Oh My Zsh'
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    print '\nFinished! You now need to log out of your current shell session and log back in before you can run this script again'
    exit 0
  else
    print 'Okay buddy'
    exit 0
  fi
}

function install_p10k () {
  print "Powerlevel10k doesn't appear to be installed, would you like me to install it for you? (Y/n)"
  read -sq place
  if [[ ($place = 'y') ]]
  then
    print 'Okay, installing Powerlevel10k'
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    print '\nFinished, continuing installer\n'
  else
    print 'Okay buddy'
    exit 0
  fi
}

function install_auto () {
  print "Zsh Autosuggestions doesn't appear to be installed, would you like me to install it for you? (Y/n)"
  read -sq place
  if [[ ($place = 'y') ]]
  then
    print 'Okay, installing Zsh Autosuggestions'
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    print '\nFinished, continuing installer\n'
  else
    print 'Okay buddy'
    exit 0
  fi
}

# checking for packages
if $([ ! -d "$omzsh" ]); then install_omzsh; else; fi
if $([ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]); then install_p10k; else; fi
if $([ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]); then install_auto; else; fi
if [[ $(command -v curl) = "" ]]; then missa=(curl $missa); fi
if [[ $(command -v bat) = "" ]]; then missc=(bat $missa); fi
if [[ $(command -v exa) = "" ]]; then missa=(exa $missa); fi
if [[ $(command -v tmux) = "" ]]; then missa=(tmux $missa); fi
if [[ $(command -v rsync) = "" ]]; then missa=(rsync $missa); fi
if [[ $(command -v fzf) = "" ]]; then missa=(fzf $missa); fi

# placing dots
function place_dots () {
  print '\nPlacing all dotfiles'
  rsync -crv ./home/. ~/
  print 'Finished, terminating installer'
  exit 0
}

# installing packages
function install_packages () {
  print '\nInstalling all required packages'
  if [[ ($missa != '') ]]
  then
    if [[ $(sudo apt install -y $missa) ]]; then; else pkg install -y $missa; fi
    #sudo apt install -y '$missa'
  else; fi
  if [[ ($place = 'y') ]]
  then
    print 'All missing packages have been installed, continuing'
    place_dots
  else
    print 'Finished, terminating installer'
    exit 0
  fi
}

# promt to place dotfiles
function dots () {
  print 'Do you want me to place all the dotfiles for you? (Y/n)'
  read -sq place
  if [[ ($ins = 'y') ]]
  then
    install_packages
  elif [[ $place = 'y' ]]
  then
    place_dots
  else
    print 'okay but why did you run the installer then lol'
    exit 0
  fi
}

# promt to install missing packages
function packages () {
  print 'The following packages are missing:' $missa
  print 'Do you want me to install them for you? (Y/n)'
  read -sq ins
  dots
}

if [[ ($missa = '') ]]
then
  dots
else
  packages
fi

print 'uh oh, I did a fucky wucky'
exit 1
