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

function install_ssm_snap {
    if snap install amazon-ssm-agent --classic; then
        echo "snap should be installed"
        snap list amazon-ssm-agent
    else
        # handle case where it actually installed but timed out
        systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
        systemctl stop snap.amazon-ssm-agent.amazon-ssm-agent.service
        snap start amazon-ssm-agent --enable
    fi
    return 0
}

export LC_ALL=C.UTF-8
export DEBIAN_FRONTEND=noninteractive

${initial_commands}

exec 1> >(logger -s -t $(basename $0)) 2>&1

export LC_ALL=C.UTF-8
export DEBIAN_FRONTEND=noninteractive

source /etc/os-release
if [[ "$VERSION_ID"  == "14.04" || "$VERSION_ID"  == "16.04" || "$VERSION_ID"  == "18.04" ]]; then
  lock_wait apt-get update
  lock_wait apt-get -y install python-setuptools python-pip

  pip install awscli --upgrade

else
  #20.04+ use python3 stuff
  lock_wait apt-get update
  lock_wait apt-get -y install python-setuptools python3-pip
fi

cp -a /usr/local/init/ubuntu/cfn-hup /etc/init.d/cfn-hup
chmod +x /etc/init.d/cfn-hup
update-rc.d cfn-hup defaults

if ps -ef | grep -q [a]mazon-ssm-agent ;then
    ssm_running="yes"
else
    ssm_running="no"
fi

if [[ $ssm_running == "yes" ]]; then
    echo "amazon-ssm-agent already running"
else
   # check the possible ubuntu cases
   source /etc/os-release
   if [[ "$VERSION_ID"  == "14.04" ]]; then
        # use deb installer
        install_ssm_deb

   elif [[ "$VERSION_ID"  == "16.04" ]]; then
        # assume snap then fallback to deb
        if snap list amazon-ssm-agent | grep -q amazon-ssm-agent  ; then
             echo "snap is installed ... starting"
             snap start amazon-ssm-agent
        else
            # aws guidance says if snap package is not present,use deb for >16.04
            install_ssm_deb
        fi
   else
        #always  uses snap for 18.04 and higher
        if snap list amazon-ssm-agent | grep -q amazon-ssm-agent ; then
             echo "snap is installed ... starting"
             snap start amazon-ssm-agent
        else
            install_ssm_snap
        fi
    fi
fi

${final_commands}
