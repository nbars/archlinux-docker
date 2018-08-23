FROM base/archlinux:latest
MAINTAINER Nils Bars <arch@nbars.de>

COPY pacman.conf /etc/pacman.conf

RUN  chmod 644 /etc/pacman.conf && chown root:root /etc/pacman.conf

#Update system and install some packages
RUN pacman -Syyu --noconfirm \
 && pacman -S --noconfirm --needed base base-devel git wget nano sudo \
    openssh ccache iputils iproute2 jshon xdelta3 tree archlinux-keyring

#Replace gcc with gcc-multilib
RUN echo -e "y\ny\ny" | sudo pacman -S gcc-multilib

RUN pacman-key --init && pacman-key --populate archlinux \
 && rm -rf /var/cache/pacman/pkg/*

RUN useradd -m -d /home/user -s /bin/bash user \
    && echo "user:user" | chpasswd \
    && groupadd sudo && gpasswd -a user sudo

#Enable sudo group
RUN echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

#install cower and pacaur
RUN  \
  sudo -u user gpg --keyserver hkp://p80.pool.sks-keyservers.net:80  --recv-keys 1EB2638FF56C0C53 ; \
  cd /tmp ; \
  sudo -u user wget https://aur.archlinux.org/cgit/aur.git/snapshot/cower.tar.gz ; \
  sudo -u user tar -xzf cower.tar.gz ; \
  cd ./cower ; \
  sudo -u user makepkg -si --noconfirm --needed ; \
  cd .. ; \
  sudo -u user wget https://aur.archlinux.org/cgit/aur.git/snapshot/pacaur.tar.gz ; \
  sudo -u user tar -xzf pacaur.tar.gz ; \
  cd ./pacaur ; \
  sudo -u user makepkg -si --noconfirm --needed

USER user

# Default command
CMD ["echo", "No default cmd set!"]
