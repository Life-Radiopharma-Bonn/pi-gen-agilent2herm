#!/bin/bash -e
echo "Running stage2-lrp"
on_chroot << EOF
cd /root/ && \
rm -rf agilent2herm && \
git clone https://github.com/Life-Radiopharma-Bonn/agilent2herm.git && \
cd agilent2herm/setup/ && \
git checkout -b rabbitmq && \
bash ./doSetup.sh
EOF
echo "setting static ip for non networked stuff"
install -m 600 files/ethernet-eth0 "${ROOTFS_DIR}/etc/NetworkManager/system-connections/ethernet-eth0"

echo "Installing Rabbitmq dependencies"
on_chroot << EOF
	sudo apt-get update && apt-get upgrade -y && apt-get install -y rabbitmq-server && systemctl enable rabbitmq-server
EOF
on_chroot << EOF
  systemctl disable avahi-daemon
EOF
on_chroot << EOF
  systemctl disable systemd-timesyncd
EOF

on_chroot << EOF
	echo "i2c-bcm2708" >> /etc/modules
	echo "i2c_dev" >> /etc/modules
	sudo apt-get install -y i2c-tools
	
	search_pattern="dtparam=i2c_arm"
	replacement="dtparam=i2c_arm=on"
	sed -i "s/^.*$search_pattern.*\$/$replacement/" /boot/firmware/config.txt
	
	(crontab -l ; echo "@reboot echo ds3231 0x68 | sudo tee /sys/class/i2c-adapter/i2c-1/new_device")| crontab -
	
	#do one ntp sync after initial setup
 	#else manually set clock (e.g. hwclock -w)
EOF

