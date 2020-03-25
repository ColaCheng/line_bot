#!/bin/bash

function setup_aws_region()
{
  mkdir -p ~/.aws
  printf "[default]\nregion=" > ~/.aws/config
  echo $REGION >> ~/.aws/config
}

function reset_git_config()
{
  git config --global --unset core.sshCommand
}

function set_git_config()
{
  github_key=`jq -r '.github_key' /home/ubuntu/.secrets`
  echo "$github_key" > /home/ubuntu/deployment/github_key
  ssh-keyscan -t rsa github.com > /home/ubuntu/deployment/known_hosts
  chmod 600 /home/ubuntu/deployment/github_key
  git config --global core.sshCommand "ssh -o UserKnownHostsFile=/home/ubuntu/deployment/known_hosts -i /home/ubuntu/deployment/github_key"
}

function wait_for_local_health()
{
  until [ "$state" == "200" ]; do state=$(curl -I -X GET localhost:${health_check_port}${health_check_path} | head -n 1|cut -d$' ' -f2); sleep 10; done;
}

export HOME=/home/ubuntu
export REGION=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone | head -c-1`
mkdir -p /home/ubuntu/deployment

reset_git_config

aws secretsmanager get-secret-value --secret-id ${my_env}/test --version-stage AWSCURRENT | jq -r '.SecretString' > /home/ubuntu/.secrets

set_git_config

sudo docker rmi -f $(sudo docker images --filter "dangling=true" -q --no-trunc)
cd /home/ubuntu/line_bot; git pull || exit 1
cd /home/ubuntu/line_bot; sudo ./run.sh || exit 1

wait_for_local_health
reset_git_config
rm -rf /home/ubuntu/deployment

sudo cfn-signal --stack "${stack_prefix}-stack" --resource WebASG --region $REGION