#!/bin/bash

session_name="`hostname`-`date +%Y%m%d`"

sts=( $(
    /usr/local/bin/aws sts assume-role \
    --role-arn "arn:aws:iam::689543204258:role/allow-ssh" \
    --role-session-name "$session_name" \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    --output text
) )

export AWS_ACCESS_KEY_ID="${sts[0]}"
export AWS_SECRET_ACCESS_KEY="${sts[1]}"
export AWS_SESSION_TOKEN="${sts[2]}"

/usr/local/bin/aws iam list-users --query "Users[].[UserName]" --output text | while read User; do
  python -mplatform | grep -qi Ubuntu && sudo /usr/sbin/adduser --gecos "" --disabled-password "$User" || /usr/sbin/adduser --comment "IAM" "$User"
  echo "$User ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$User"
  chmod 0440 /etc/sudoers.d/$User
done
