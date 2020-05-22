#!/bin/bash
USER_HOME=/home/$USERNAME
BASH_USER_PATH=$USER_HOME/.bashrc
ZSH_USER_PATH=$USER_HOME/.zshrc

echo "Installing Packages"
apt-get update
apt-get install -y \
    curl \
    git \
    gnupg2 \
    jq \
    sudo \
    zsh \
    apt-transport-https \
    openssh-client \
    less \
    iproute2

## Setup and install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
cp -R /root/.oh-my-zsh $USER_HOME
cp /root/.zshrc $USER_HOME
sed -i -e "s/\/root\/.oh-my-zsh/\/home\/$USERNAME\/.oh-my-zsh/g" $ZSH_USER_PATH
chown -R $USER_UID:$USER_GID $USER_HOME/.oh-my-zsh $ZSH_USER_PATH

## Install nvm and zsh prompt
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
echo "Install node stable LTS"
nvm install stable
npm i -g spaceship-prompt

# Install kubectl
echo "Installing Kubectl"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

# Install Helm
echo "Installing Helm"
curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -

# Sync localhost kubeconfig
echo '\n\ if [ "$SYNC_LOCALHOST_KUBECONFIG" = "true" ] && [ -d "/usr/local/share/kube-localhost" ]; then\n\
    mkdir -p $HOME/.kube\n\
    sudo cp -r /usr/local/share/kube-localhost/* $HOME/.kube\n\
    sudo chown -R $(id -u) $HOME/.kube\n\
    sed -i -e "s/localhost/host.docker.internal/g" $HOME/.kube/config\n\
    \n\
    if [ -d "/usr/local/share/minikube-localhost" ]; then\n\
        mkdir -p $HOME/.minikube\n\
        sudo cp -r /usr/local/share/minikube-localhost/ca.crt $HOME/.minikube\n\
        sudo cp -r /usr/local/share/minikube-localhost/client.crt $HOME/.minikube\n\
        sudo cp -r /usr/local/share/minikube-localhost/client.key $HOME/.minikube\n\
        sudo chown -R $(id -u) $HOME/.minikube\n\
        sed -i -r "s|(\s*certificate-authority:\s).*|\\1$HOME\/.minikube\/ca.crt|g" $HOME/.kube/config\n\
        sed -i -r "s|(\s*client-certificate:\s).*|\\1$HOME\/.minikube\/client.crt|g" $HOME/.kube/config\n\
        sed -i -r "s|(\s*client-key:\s).*|\\1$HOME\/.minikube\/client.key|g" $HOME/.kube/config\n\
    fi\n\
fi' | tee -a /root/.bashrc /root/.zshrc $BASH_USER_PATH >> $ZSH_USER_PATH \

# Install K9S
curl -sL https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_x86_64.tar.gz | tar xzv

# Add zsh config files
echo "export TERM=xterm-256color" >> $ZSH_USER_PATH

# Clean up
&& apt-get autoremove -y \
&& apt-get clean -y \
&& rm -rf /var/lib/apt/lists/*