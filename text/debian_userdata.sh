#!/bin/bash -xe

function lock_wait {
    endtime=$(( $(date +%s) + 300 ))
    set +e
    while [ $(date +%s) -lt $endtime ]; do
        "$@" && break
        sleep 15
    done
    set -e
}

function install_ssm_deb {
    if [[ -r "/tmp/ssm_agent_install" ]]; then : ;
    else
      mkdir -p /tmp/ssm_agent_install
    fi
    curl https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb -o /tmp/ssm_agent_install/amazon-ssm-agent.deb
    lock_wait dpkg -i /tmp/ssm_agent_install/amazon-ssm-agent.deb

    if ps -ef | grep -q [a]mazon-ssm-agent  ;then
        ssm_running="yes"
    else
        ssm_running="no"
    fi

    if command -v systemctl ; then
        systemctl enable amazon-ssm-agent
        if [[ $ssm_running == "no" ]]; then
            systemctl start amazon-ssm-agent
        fi
    else
        if [[ $ssm_running == "no" ]]; then
            start amazon-ssm-agent
        fi
    fi

    return 0
}

function install_aws_cli_v2 {
  mkdir -p /opt/aws/aws
  curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /opt/aws/awscliv2.zip && \
  unzip -o /opt/aws/awscliv2.zip -d /opt/aws && \
  /opt/aws/aws/install -u
}

export LC_ALL=C.UTF-8
export DEBIAN_FRONTEND=noninteractive

${initial_commands}

exec 1> >(logger -s -t $(basename $0)) 2>&1

lock_wait apt-get update
lock_wait apt-get -y install python-setuptools python3-pip unzip

# Install AWSCLIv2
install_aws_cli_v2

if ps -ef | grep -q [a]mazon-ssm-agent ;then
    ssm_running="yes"
else
    ssm_running="no"
fi

if [[ $ssm_running == "yes" ]]; then
    echo "amazon-ssm-agent already running"
else
   # use deb installer
   install_ssm_deb
fi