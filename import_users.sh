#!/bin/bash

session_name="`hostname`-`date +%Y%m%d`"

sts=( $(
    aws sts assume-role \
    --role-arn "arn:aws:iam::689543204258:role/ssh-auth" \
    --role-session-name "$session_name" \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    --output text
) )

export AWS_ACCESS_KEY_ID="${sts[0]}"
export AWS_SECRET_ACCESS_KEY="${sts[1]}"
export AWS_SESSION_TOKEN="${sts[2]}"

aws iam list-users --query "Users[].[UserName]" --output text | while read User; do
  if id -u "$User" >/dev/null 2>&1; then
    echo "$User exists"
  else
    /usr/sbin/adduser "$User"
    echo "$User ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$User"
  fi
done
