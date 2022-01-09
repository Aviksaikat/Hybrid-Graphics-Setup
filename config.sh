#!/bin/bash
C=$(printf '\033')
RED="${C}[1;31m"
GREEN="${C}[1;32m"
NC="${C}[0m"

#? checking permissions
if [[ $EUID -ne 0 ]]; then
   echo "${RED}This script must be run as root${NC}" 
   exit 1
fi

echo "${GREEN}Checking if the files exists & making backup just in case ;)${NC}"

#? if those files exists then make a backup
FILE1=/usr/share/X11/xorg.conf.d/10-amdgpu.conf
if test -f "$FILE1"; 
then
    sudo mv "$FILE1" "$FILE1.bak"
fi

FILE2=/usr/share/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf
if test -f "$FILE2"; 
then
    sudo mv "$FILE2" "$FILE2.bak"
fi

echo "${GREEN}[*]Copying....${NC}"
sudo cp config-files/10-amdgpu.conf /usr/share/X11/xorg.conf.d/10-amdgpu.conf
sudo cp config-files/10-nvidia-drm-outputclass.conf /usr/share/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf

echo "${GREEN}[*]Choose your display manager"
echo "1. GDM"
echo "2. SDDM"
read n

if [ $n -eq 1 ];
then 
    sudo cp config-files/optimus.desktop /etc/xdg/autostart/optimus.desktop
    sudo cp config-files/optimus.desktop /usr/share/gdm/greeter/autostart/optimus.desktop
fi

if [ $n -eq 2 ];
then 
    sudo echo "xrandr --setprovideroutputsource modesetting NVIDIA-0; xrandr --auto" >> /usr/share/sddm/scripts/Xsetup
fi

echo "${GREEN}Enabling prime synchronisation${NC}"
sudo echo "options nvidia-drm modeset=1" >> /etc/modprobe.d/nvidia.conf

echo "${GREEN}Blacklisting nouveau${NC}"
sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"

echo "${GREEN}Updating initramfs${NC}"
sudo update-initramfs -u -k all
echo "${RED}Rebooting"
sudo reboot