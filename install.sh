#!/bin/sh
# Script to install squeezebox and squeezelite as services on a raspberry pi preconfigured with my preferred plugins
# Author: Daniel Butler (kefabean) 

# Terminate script on first error

set -e

# Configure hostname

sudo sed -i 's/127.0.1.1.*/127.0.1.1\tkefa-music/' /etc/hosts
sudo hostname kefa-music 
sudo bash -c 'echo kefa-music > /etc/hostname'
sudo sed -i 's/options snd-usb-audio.*/options snd-usb-audio index=0/' /etc/modprobe.d/alsa-base.conf

# Remove packages not required to release space and speed up updates

sudo apt-get remove -y wolfram-engine
#sudo apt-get remove -y wolfram-engine lxappearance lxde lxde-common lxde-core lxde-icon-theme lxinput lxmenu-data lxpanel lxpolkit lxrandr lxsession lxsession-edit  lxshortcut lxtask  lxterminal  xinit xserver-xorg lightdm scratch midori desktop-base desktop-file-utils gnome-icon-theme gnome-themes-standard leafpad menu-xdg omxplayer xarchiver zenity tk8.5 pcmanfm blt idle idle3 python-tk python3-tk dillo openbox
#sudo apt-get update && sudo apt-get upgrade
#sudo apt-get -y autoremove

# Configure SSH with my public key

mkdir -p /home/pi/.ssh
sudo chmod 700 /home/pi/.ssh
sudo bash -c 'echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDDIJpyB/wb4X3airZl3t9nStARAiAxKOm4aDmZxoIBZuCvIWlwI8CcnWBS+LyFBBnbsFlPC0l38WQho1eftRJDxSc9MLHnFpkMIhL/GJCtqD1MPWDnVRtAeSUj007O3wLXTs/GLPqB+Nr4aEEJPeHqeDZYWaED5OvuVG6JuKPO0Js7KYXVDV1QJnBLk3LX0VIL70A13JWLgkpjBfDYznvn1UZUnvwzQQ/nwc+4fII8jby8cyceeaVC3fqHxN271wZCWwhbd3r8poR479wXZdHNkLM+mFe3M5PiAmNaP113I+7sQVQbAcXF/C+U3PnLjeMNUtLvSdbxRArhsoE0125mtarGi6vwJ+QuSu5spPKDC5qOPLF0HRvxISZ1KEQHVR+qML4WYDaHasUrq+jI/J5Opmor6taOzEwLj/lOumC3bFea0QlVXixV4L+DNilvRLqIAzc+0XWjVBHvuBOOUps0sb7B01UKgNGyf0LsnwAP0BuSBs7wa6jABjVaI1346ZDH60op/fJ0MkwS0Rq62j4DZx8PEn5I+bJSVcjC8THoE5cL/Hn5njzykd93AX9fieBgnaaReDcak7lL2BP3FLWQt9kAYfET0sONvsV8vEH1NnAczdeTnfudi4UXudM0+tHtGW62o0EjMtGvqoGpVQih7oeCWd33tDgsvu7e0OZw/w== daniel@daniel.local" > /home/pi/.ssh/authorized_keys'
sudo chmod 644 /home/pi/.ssh/authorized_keys
sudo sed -i 's/PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo service ssh restart

# Install prerequisites

sudo apt-get install -y libflac-dev libfaad2 libmad0 libinline-perl
mkdir -p downloads
rm -rf downloads/wiringPi
git clone git@github.com:kefabean/wiringPi.git downloads/wiringPi
OLD_DIR=$(pwd)
cd ./downloads/wiringPi
./build
cd ${OLD_DIR}
rm -rf downloads/433Utils
git clone git@github.com:kefabean/433Utils.git downloads/433Utils
make -C ./downloads/433Utils/RPi_utils

# Install squeezeserver (sourced from http://downloads.slimdevices.com/LogitechMediaServer_v7.8.0/logitechmediaserver_7.8.0_all.deb)

test ! -f downloads/logitechmediaserver_7.8.0_all.deb && wget http://downloads.slimdevices.com/LogitechMediaServer_v7.8.0/logitechmediaserver_7.8.0_all.deb -P downloads
sudo dpkg -iE downloads/logitechmediaserver_7.8.0_all.deb
mkdir -p /home/pi/music
mkdir -p /home/pi/playlists
sudo chown -R squeezeboxserver:pi /home/pi/music
sudo chown -R squeezeboxserver:pi /home/pi/playlists

# Install and configure which plugins are active

sudo service logitechmediaserver stop
sudo rm -rf /var/lib/squeezeboxserver/cache/InstalledPlugins/Plugins
sudo mkdir -p /var/lib/squeezeboxserver/cache/InstalledPlugins/Plugins
test ! -f downloads/BBCiPlayer-v1.3.1alpha3.zip && wget https://kefa.s3.amazonaws.com/binaries/squeezebox/BBCiPlayer-v1.3.1alpha3.zip -P downloads
sudo unzip -n downloads/BBCiPlayer-v1.3.1alpha3.zip -d /var/lib/squeezeboxserver/cache/InstalledPlugins/Plugins
test ! -f downloads/Spotify-linux-v2.3.9.zip && wget https://kefa.s3.amazonaws.com/binaries/squeezebox/Spotify-linux-v2.3.9.zip -P downloads
sudo unzip -n downloads/Spotify-linux-v2.3.9.zip -d /var/lib/squeezeboxserver/cache/InstalledPlugins/Plugins
rm -rf downloads/IRBlaster
git clone https://github.com/kefabean/IRBlaster.git downloads/IRBlaster
sudo cp -Rn -t /var/lib/squeezeboxserver/cache/InstalledPlugins/Plugins/ downloads/IRBlaster
sudo cp files/state.prefs /var/lib/squeezeboxserver/prefs/plugin
sudo cp files/extensions.prefs /var/lib/squeezeboxserver/prefs/plugin
sudo chown -R squeezeboxserver:nogroup /var/lib/squeezeboxserver/cache/InstalledPlugins
sudo service logitechmediaserver start

# Install squeezelite (originally sourced from http://squeezelite-downloads.googlecode.com/git/squeezelite-armv6hf)

test ! -f downloads/squeezelite-armv6hf && wget https://kefa.s3.amazonaws.com/binaries/squeezebox/squeezelite-armv6hf -P downloads
ps cax | grep squeezelite 
if [ $? -eq 0 ]; then
  sudo service squeezelite stop
fi
sudo cp downloads/squeezelite-armv6hf /usr/bin
sudo chmod a+x /usr/bin/squeezelite-armv6hf
sudo cp files/squeezelite-initd /etc/init.d/squeezelite
sudo chmod 755 /etc/init.d/squeezelite
sudo update-rc.d squeezelite defaults
sudo service squeezelite start
