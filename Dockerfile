FROM centos:7

ENV PATH=$PATH:/root/.cargo/bin
ENV RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup
ENV RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
ENV NVM_NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node

# install base utils
RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup \
  && curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo \
  && yum makecache \
  && yum -y update

RUN yum -y install zsh which git gcc lldb openssl openssl-devel

# install nodejs
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
SHELL [ "bash", "-c" ]
RUN . $HOME/.bash_profile \
  && nvm install v14.11.0 \
  && nvm use v14.11.0 \
  && npm install yarn -g --registry https://registry.npm.taobao.org

# install rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# install wasm-pack
# RUN curl --proxy 127.0.0.1:1080 https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
COPY ./sources/install-wasm-pack.sh /root/tmp/install-wasm-pack.sh
RUN $HOME/tmp/install-wasm-pack.sh

# install oh-my-zsh
RUN REPO=mirrors/oh-my-zsh \
  REMOTE=https://gitee.com/${REPO}.git \
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
COPY ./sources/chsh /etc/pam.d/chsh
RUN chsh -s /bin/zsh
COPY ./sources/.zshrc /root/tmp/.zshrc
RUN cat $HOME/tmp/.zshrc >> $HOME/.zshrc

# cargo config
COPY ./sources/cargo-config /root/.cargo/config
RUN cargo install wasm-bindgen-cli --version 0.2.68