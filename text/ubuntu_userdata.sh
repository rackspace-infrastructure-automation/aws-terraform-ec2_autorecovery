#!/bin/bash -xe

${initial_commands}

exec 1> >(logger -s -t $(basename $0)) 2>&1

export LC_ALL=C.UTF-8

apt-get update
apt-get -y install python-setuptools python-pip
pip install awscli --upgrade
mkdir -p aws-cfn-bootstrap-latest
curl https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz | tar xz -C aws-cfn-bootstrap-latest --strip-components 1
easy_install aws-cfn-bootstrap-latest
cp -a aws-cfn-bootstrap-latest/init/ubuntu/cfn-hup /etc/init.d/cfn-hup
chmod +x /etc/init.d/cfn-hup
update-rc.d cfn-hup defaults
ssm_running=$( ps -ef | grep [a]mazon-ssm-agent | wc -l )
if [[ $ssm_running != "0" ]]; then
    echo -e "amazon-ssm-agent already running"
    exit 0
else
    if [[ -r "/tmp/ssm_agent_install" ]]; then : ;
    else mkdir -p /tmp/ssm_agent_install; fi
    curl https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb -o /tmp/ssm_agent_install/amazon-ssm-agent.deb
    dpkg -i /tmp/ssm_agent_install/amazon-ssm-agent.deb
    ssm_running=$( ps -ef | grep [a]mazon-ssm-agent | wc -l )

    if [[ $( command -v systemctl ) ]]; then
        systemctl enable amazon-ssm-agent
        if [[ $ssm_running == "0" ]]; then
            systemctl start amazon-ssm-agent
        fi
    else
        if [[ $ssm_running == "0" ]]; then
            start amazon-ssm-agent
        fi
    fi
fi

${final_commands}
