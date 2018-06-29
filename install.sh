#!/bin/bash

sshdConfig="/etc/ssh/sshd_config"
tmpdir=`mktemp -d`

cd $tmpdir

# only runs if git isn't already installed
if ! [ -x "$(command -v git)" ]; then
  if [ -f /etc/lsb-release ]; then
    sudo apt-get update
    sudo apt-get install -y git
  else
    sudo yum update
    sudo yum install -y git
  fi
fi

git clone https://github.com/articulate/aws-iam-ssh-auth.git

cd $tmpdir/aws-iam-ssh-auth

cp authorized_keys_command.sh /opt/authorized_keys_command.sh
chmod +x /opt/authorized_keys_command.sh

cp import_users.sh /opt/import_users.sh
chmod +x /opt/import_users.sh


if ! grep -q ^AuthorizedKeysCommand $sshdConfig; then
  if [ -f /etc/lsb-release ]; then
    echo "AuthorizedKeysCommand /opt/authorized_keys_command.sh" >> $sshdConfig
    echo "AuthorizedKeysCommandUser nobody" >> $sshdConfig
  else
    sed -i 's:#AuthorizedKeysCommand none:AuthorizedKeysCommand /opt/authorized_keys_command.sh:g' $sshdConfig
    sed -i 's:#AuthorizedKeysCommandUser nobody:AuthorizedKeysCommandUser nobody:g' $sshdConfig
  fi

  if [ -f /etc/lsb-release ]; then
    service ssh restart
  else
    service sshd restart
  fi
fi

echo "@reboot root /opt/import_users.sh > /var/log/import-users.log 2>&1" > /etc/cron.d/import_users
echo "*/10 * * * * root /opt/import_users.sh > /var/log/import-users.log 2>&1" >> /etc/cron.d/import_users
chmod 0644 /etc/cron.d/import_users

/opt/import_users.sh
