# Hybrid-Graphics-Setup

> Saikat Karmakar | Jan 9 : 2021

--- 

- If you're trying to connect to external monitors using HDMI and you have a hybrid setup like me (AMD Radeon vega + nvidia 1650) then these configuration files may help you as it worked for me.
- Just copy these `.conf` files to `/usr/share/X11/xorg.conf.d` 

### Automatic
## Caution: This script is not tested run this at your own risk
```bash
git clone https://github.com/Aviksaikat/Hybrid-Graphics-Setup
cd Hybrid-Graphics-Setup
chmod +x config.sh
sudo ./config.sh
```

### Manual steps
1. `sudo (text_editor) /usr/share/X11/xorg.conf.d/10-amdgpu.conf`
```sh
Section "OutputClass"
  Identifier "AMDgpu"
  MatchDriver "amdgpu"
  Driver "modesetting"
EndSection
```
2. `sudo (text_editor) /usr/share/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf`
```sh
Section "OutputClass"
    Identifier "nvidia"
    MatchDriver "nvidia-drm"
    Driver "nvidia"
    Option "AllowEmptyInitialConfiguration"
    ModulePath "/usr/lib/nvidia/xorg"
    ModulePath "/usr/lib/xorg/modules"
    Option "PrimaryGPU" "Yes"
EndSection
```
3. Make sure no other config files named interfere `10-nvidia-drm-outputclass.conf` & `10-amdgpu.conf` (in /etc/X11 or /usr/share/X11). 
- ## Finally  
### Display managers (choose yours):
#### LightDM
- create `/etc/lightdm/display_setup.sh`
```bash
#!/bin/sh
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
```
- Make the script executable:
```bash
chmod +x /etc/lightdm/display_setup.sh
```
Now configure lightdm to run the script by editing the `[Seat:*]` section in `/etc/lightdm/lightdm.conf` :

`/etc/lightdm/lightdm.conf`
```
[Seat:*] display-setup-script=/etc/lightdm/display_setup.sh
```
Now reboot and your display manager should start.
If your display dpi is not correct add the following line (applies also to the other display managers):
```
xrandr --dpi 96
```

#### SDDM
`/usr/share/sddm/scripts/Xsetup`

```bash
xrandr --setprovideroutputsource modesetting NVIDIA-0; xrandr --auto
```
#### GDM
`/usr/share/gdm/greeter/autostart/optimus.desktop /etc/xdg/autostart/optimus.desktop`
```bash
[Desktop Entry]
Type=Application
Name=Optimus
Exec=sh -c "xrandr --setprovideroutputsource modesetting NVIDIA-0; xrandr --auto"
NoDisplay=true
X-GNOME-Autostart-Phase=DisplayServer
```
Make sure that GDM use `X as default backend`.

- **Enable prime synchronisation**

edit or create: `/etc/modprobe.d/nvidia.conf`:

add:
```bash
options nvidia-drm modeset=1
```
- **Blacklist nouveau:**
```bash
sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
```
- **Update initramfs:**
```bash
sudo update-initramfs -u -k all
```
- Reboot.


- This was the original ticket I opened and the nvidia support super actively helped me thanks to them I can work on my new monitor. https://forums.developer.nvidia.com/t/having-problem-while-using-external-monitor-on-parrot-os/199476/18