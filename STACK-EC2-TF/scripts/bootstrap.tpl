#!/bin/bash -x
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Update and install necessary packages
sudo yum update -y
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo yum install git -y
sudo yum install -y nfs-utils
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
sudo yum install -y httpd mariadb-server

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl is-enabled httpd

# EFS MOUNTING
FILE_SYSTEM_ID=${STACK_CLIXX_EFS}
TOKEN=$(sudo curl --request PUT "http://169.254.169.254/latest/api/token" --header "X-aws-ec2-metadata-token-ttl-seconds: 3600")
REGION=$(sudo curl -s http://169.254.169.254/latest/meta-data/placement/region --header "X-aws-ec2-metadata-token: $TOKEN")
MOUNT_POINT=/var/www/html
sudo mkdir -p $MOUNT_POINT
sudo chown ec2-user:ec2-user $MOUNT_POINT
echo "$FILE_SYSTEM_ID.efs.$REGION.amazonaws.com:/ $MOUNT_POINT nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0" | sudo tee -a /etc/fstab
sudo mount -a -t nfs4
sudo chmod -R 755 /var/www/html

# Add ec2-user to Apache group and set permissions
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;

# Clone git repository and set up Wordpress
cd /var/www/html
sudo git clone ${GIT_REPO}
sudo cp -r CliXX_Retail_Repository/* /var/www/html

# Configure Apache and set permissions
sudo sed -i '151s/None/All/' /etc/httpd/conf/httpd.conf
sudo chown -R apache:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
sudo find /var/www -type f -exec sudo chmod 0664 {} \;

# Update the wp-config.php with the correct database host
cd /var/www/html
sudo sed -i "s/${ORIGINAL_ENDPOINT}/${RDS_ENDPOINT}/g" /var/www/html/wp-config.php

# Restart Apache
sudo systemctl restart httpd
sudo service httpd restart

# Additional configurations
sudo /sbin/sysctl -w net.ipv4.tcp_keepalive_time=200 net.ipv4.tcp_keepalive_intvl=200 net.ipv4.tcp_keepalive_probes=5

# Change IP address to A record
mysql -h ${RDS_ENDPOINT} -u ${USER} -p${PASSWORD} -D ${DATABASE} -e "UPDATE wp_options SET option_value = '${LOAD_BALANCER_DNS}' WHERE option_value LIKE 'http%';"

# Mount EBS Volume
for x in /dev/sdb /dev/sdc /dev/sdd /dev/sde; do
  if [ ! -b "$x" ]; then
    echo "$x does not exist."
    continue
  fi

  # Create a new partition using fdisk
  (
  echo o      # Create a new empty partition table
  echo n      # Add a new partition
  echo p      # Primary partition
  echo 1      # Partition number
  echo        # First sector (accept default)
  echo        # Last sector (accept default)
  echo w      # Write changes
  ) | sudo fdisk $x
done

sudo vgcreate stack_vg /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1
sudo vgs
for lv in Lv_u01 Lv_u02 Lv_u03 Lv_u04; do
  sudo lvcreate -L 5G -n $lv stack_vg
  sudo mkfs.ext4 /dev/stack_vg/$lv
  strip="$${lv#Lv_}"
  mount_point="/$strip"
  [ ! -d "$mount_point" ] && sudo mkdir -p $mount_point
  sudo mount /dev/stack_vg/$lv $mount_point
  
  UUID=$(sudo blkid /dev/mapper/stack_vg-$lv -o value -s UUID)
  echo "UUID=$UUID $mount_point ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab > /dev/null
done
