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
