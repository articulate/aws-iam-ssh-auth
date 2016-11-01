#!/bin/bash -e

if [ -z "$1" ]; then
  exit 1
fi

session_name="`hostname`-`date +%Y%m%d`"

sts=( $(
    aws sts assume-role \
    --role-arn "arn:aws:iam::689543204258:role/allow-ssh" \
    --role-session-name "$session_name" \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    --output text
) )

export AWS_ACCESS_KEY_ID="${sts[0]}"
export AWS_SECRET_ACCESS_KEY="${sts[1]}"
export AWS_SESSION_TOKEN="${sts[2]}"

aws iam list-ssh-public-keys --user-name "$1" --query "SSHPublicKeys[?Status == 'Active'].[SSHPublicKeyId]" --output text | while read KeyId; do
  aws iam get-ssh-public-key --user-name "$1" --ssh-public-key-id "$KeyId" --encoding SSH --query "SSHPublicKey.SSHPublicKeyBody" --output text
done
