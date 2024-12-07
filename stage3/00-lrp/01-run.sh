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
install -m 600 files/ethernet-eth0 "${ROOTFS_DIR}/etc/NetworkManager/system-connections/ethernet-eth0"

echo "Installing Rabbitmq dependencies"
on_chroot << EOF
	 for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove -y $pkg; done
	  sudo apt-get update
	sudo apt-get install ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/raspbian/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	
	# Add the repository to Apt sources:
	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/raspbian \
	  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update -y

 	 sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   	docker pull rabbitmq
EOF
