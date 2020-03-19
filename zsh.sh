#!/bin/bash

echo -e "\n";
apt install git-core zsh -y
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# change default to zsh
chsh -s $(which zsh)
apt install fonts-powerline -y
cat 'ZSH_THEME="agnoster"' >> ~/.zshrc
echo -e "[Done]";

# https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>! ~/.zshrc

# Productivity
# Zsh syntax hightlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Zsh syntax autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

# Now add zsh-syntax-highlighting in your plugins list:
# nano ~/.zshrc

# plugins=(
#    git
#    zsh-autosuggestions
#    zsh-syntax-highlighting
#)
