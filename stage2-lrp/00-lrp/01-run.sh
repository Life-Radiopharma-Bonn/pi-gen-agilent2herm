#!/bin/bash -e
echo "Running stage2-lrp"
on_chroot << EOF
cd /root/ && \
rm -rf agilent2herm && \
git clone https://github.com/Life-Radiopharma-Bonn/agilent2herm.git && \
cd agilent2herm/setup/ && \
bash ./doSetup.sh
EOF
echo "setting static ip for non networked stuff"
#install -m 644 files/01-network-manager-all.yaml "${ROOTFS_DIR}/etc/netplan/01-network-manager-all.yaml"
