#!/bin/bash

tmpdir=`mktemp -d`

cd $tmpdir

python -mplatform | grep -qi Ubuntu && sudo apt-get update || sudo yum update
python -mplatform | grep -qi Ubuntu && apt-get install -y git || yum install -y git

git clone https://github.com/articulate/aws-iam-ssh-auth.git

cd $tmpdir/aws-iam-ssh-auth

cp authorized_keys_command.sh /opt/authorized_keys_command.sh
chmod +x /opt/authorized_keys_command.sh

cp import_users.sh /opt/import_users.sh
chmod +x /opt/import_users.sh

sed -i 's:#AuthorizedKeysCommand none:AuthorizedKeysCommand /opt/authorized_keys_command.sh:g' /etc/ssh/sshd_config
sed -i 's:#AuthorizedKeysCommandUser nobody:AuthorizedKeysCommandUser nobody:g' /etc/ssh/sshd_config

echo "*/10 * * * * root /opt/import_users.sh" > /etc/cron.d/import_users
chmod 0644 /etc/cron.d/import_users

/opt/import_users.sh

python -mplatform | grep -qi Ubuntu && service ssh restart || service sshd restart
