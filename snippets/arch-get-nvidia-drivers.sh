#!/bin/bash
# This was written for the UntitledLinuxGameManager, with the intention to get the latest nvidia driver version to install then lock it in Pacman! 

sed -i '/^#\[multilib\]$/ {N; s/#\[multilib\]\n#Include = \/etc\/pacman.d\/mirrorlist/\[multilib\]\nInclude = \/etc\/pacman.d\/mirrorlist/g}' /etc/pacman.conf
pacman -Syyu --noconfirm

# get the nvidia driver version from glxinfo and then construct a new string with the version
nversiontmp=$(glxinfo | grep "OpenGL version string: 4.6.0 NVIDIA ")
nversion=${nversiontmp: -6}

# Iterate the archive for the newest iteration of the 64 bit nvidia drivers
up1=1
for ((;;)); do
  stat1=$(curl -Is "https://archive.archlinux.org/packages/n/nvidia-utils/nvidia-utils-${nversion}-${up1}-x86_64.pkg.tar.zst" | head -n 1)

  if echo "${stat1}" | grep "200" &> /dev/null; then
    ((up1+=1))
  else
    ((up1-=1))
    break;
  fi
done

# Iterate the archive for the newest iteration of the 32bit nvidia drivers and libraries
up2=1
for ((;;)); do
  stat2=$(curl -Is "https://archive.archlinux.org/packages/l/lib32-nvidia-utils/lib32-nvidia-utils-${nversion}-${up2}-x86_64.pkg.tar.zst" | head -n 1)
  if echo "${stat2}" | grep "200" &> /dev/null; then
    ((up2+=1))
  else
    ((up2-=1))
    break;
  fi
done
pacman -U --noconfirm "https://archive.archlinux.org/packages/n/nvidia-utils/nvidia-utils-${nversion}-${up1}-x86_64.pkg.tar.zst" "https://archive.archlinux.org/packages/l/lib32-nvidia-utils/lib32-nvidia-utils-${nversion}-${up2}-x86_64.pkg.tar.zst"
sed -i 's/#IgnorePkg   =/IgnorePkg = lib32-nvidia-utils nvidia-utils/g' /etc/pacman.conf
