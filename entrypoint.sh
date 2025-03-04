#!/bin/bash

SSH_USER=$1
SSH_HOST=$2
SSH_PORT=$3
PATH_SOURCE=$4
OWNER=$5

mkdir -p /root/.ssh
ssh-keyscan -H "$SSH_HOST" >> /root/.ssh/known_hosts

if [ -z "$DEPLOY_KEY" ];
then
	echo $'\n' "------ DEPLOY KEY NOT SET YET! ----------------" $'\n'
	exit 1
else
	printf '%b\n' "$DEPLOY_KEY" > /root/.ssh/id_rsa
	chmod 400 /root/.ssh/id_rsa

	echo $'\n' "------ CONFIG SUCCESSFUL! ---------------------" $'\n'
fi

if [ ! -z "$SSH_PORT" ];
then
        printf "Host %b\n\tPort %b\n" "$SSH_HOST" "$SSH_PORT" > /root/.ssh/config
	ssh-keyscan -p $SSH_PORT -H "$SSH_HOST" >> /root/.ssh/known_hosts
fi

rsync --progress -avzh \
	--exclude='.git/' \
	--exclude='.git*' \
	--exclude='.editorconfig' \
	--exclude='readme.md' \
	--exclude='README.md' \
	-e "ssh -i /root/.ssh/id_rsa" \
	--rsync-path="sudo rsync" . $SSH_USER@$SSH_HOST:$PATH_SOURCE

if [ $? -eq 0 ]
then
	echo $'\n' "------ SYNC SUCCESSFUL! -----------------------" $'\n'
	
	ssh -i /root/.ssh/id_rsa $SSH_USER@$SSH_HOST -t "cd $PATH_SOURCE && bash ./deploy.sh"
	
	echo $'\n' "------ CONGRATS! DEPLOY SUCCESSFUL!!! ---------" $'\n'
	exit 0
else
	echo $'\n' "------ DEPLOY FAILED! -------------------------" $'\n'
	exit 1
fi
