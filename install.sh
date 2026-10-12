
set -euo pipefail

current_dir="$(cd "$(dirname "$0")" && pwd)"

proxy() {
  if [ "$1" = "proxy" ]; then
    proxy_host="192.168.8.100"
    proxy_port="2501"
    socks_proxy="socks5://$proxy_host:1080"
    export http_proxy="http://$proxy_host:$proxy_port"
    export https_proxy="http://$proxy_host:$proxy_port"
    export all_proxy="$socks_proxy"
    export no_proxy="localhost,127.0.0.1"
    export HTTP_PROXY="$http_proxy"
    export HTTPS_PROXY="$https_proxy"
    export ALL_PROXY="$all_proxy"
    export NO_PROXY="$no_proxy"
  elif [ "$1" = "noproxy" ]; then
    unset http_proxy
    unset https_proxy
    unset all_proxy
    unset no_proxy
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset ALL_PROXY
    unset NO_PROXY
  fi
}

install_git(){
    # check if git is installed
    if ! command -v git &> /dev/null; then
        echo "git is not installed. Installing git..."
        sudo dnf install -y git || {
        echo "Failed to install git. Please install it manually."
        exit 1
        }
    else
        echo "git is already installed."
    fi
}

# oh-my-zsh
install_oh_my_zsh() {
  # check zsh is installed
  if ! command -v zsh &> /dev/null; then
    # install zsh
    echo "zsh is not installed. Installing zsh..."
    sudo dnf install -y zsh || {
      echo "Failed to install zsh. Please install it manually."
      exit 1
    }
  fi

  # check if oh-my-zsh is already installed
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "oh-my-zsh is already installed."
  else
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  # set zsh as default shell
  if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting zsh as the default shell..."
    sudo chsh -s "$(which zsh)" || {
      echo "Failed to set zsh as the default shell. Please set it manually."
      exit 1
    }
  fi

  # soft link zshrc
  if [ -f "$HOME/.zshrc" ]; then
    echo "Removing existing .zshrc"
    rm "$HOME/.zshrc"
  fi
  touch "$HOME/.zshrc_custom"
  ln -s "$current_dir/zshrc" "$HOME/.zshrc"
}

install_zsh_plugins() {
  # check if zsh-autosuggestions is installed
  if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
  fi

  # check if fast-syntax-highlighting is installed
  if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/fast-syntax-highlighting" ]; then
    echo "Installing fast-syntax-highlighting..."
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting "$HOME/.oh-my-zsh/custom/plugins/fast-syntax-highlighting"
  fi
}

# tmux
install_tmux() {
  # check if tmux is installed
  if ! command -v tmux &> /dev/null; then
    echo "tmux is not installed. Installing tmux..."
    sudo dnf install -y tmux || {
      echo "Failed to install tmux. Please install it manually."
      exit 1
    }
  else
    echo "tmux is already installed."
    blank_line
    # install tmux plugin manager
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
      echo "Installing tmux plugin manager..."
      git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    else
      echo "tmux plugin manager is already installed."
    fi
  fi

  # soft link tmux.conf
  if [ -f "$HOME/.tmux.conf" ]; then
    echo "Removing existing .tmux.conf"
    rm "$HOME/.tmux.conf"
  fi
  ln -s "$current_dir/tmux.conf" "$HOME/.tmux.conf"

  # soft link tmux-powerline
  if [ -d "$HOME/.config/tmux-powerline" ]; then
    echo "Removing existing tmux-powerline"
    rm -rf "$HOME/.config/tmux-powerline"
  fi
  # check if .config directory exists
  if [ ! -d "$HOME/.config" ]; then
    echo "Creating .config directory"
    mkdir "$HOME/.config"
  fi
  ln -s "$current_dir/tmux-powerline" "$HOME/.config/tmux-powerline"
}

install_tmux_plugins() {
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing tmux plugin manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  else
    echo "tmux plugin manager is already installed."
  fi

  # check if tmux is running
  if [ -n "$TMUX" ]; then
    echo "Installing tmux plugins..."
    tmux source ~/.tmux.conf
    ~/.tmux/plugins/tpm/bin/install_plugins
  else
    echo "tmux is not running. Please start tmux and run the following command to install plugins:"
    echo "~/.tmux/plugins/tpm/bin/install_plugins"
  fi
}

blank_line() {
  echo ""
}

proxy proxy

install_git

blank_line

install_oh_my_zsh
install_zsh_plugins

blank_line

install_tmux
install_tmux_plugins
