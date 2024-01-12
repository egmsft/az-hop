#!/bin/bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$script_dir/../files/azhop-helpers.sh" 
read_os

find $script_dir/../files -name "*.sh" -exec chmod +x {} \;

# If PBS is not installed, then install it
if [ ! -f "/etc/pbs.conf" ]; then
    $script_dir/../files/$os_release/installpbs.sh
fi

echo "Configuring PBS"

sed -i 's/CHANGE_THIS_TO_PBS_PRO_SERVER_HOSTNAME/scheduler/' /etc/pbs.conf
sed -i 's/CHANGE_THIS_TO_PBS_PRO_SERVER_HOSTNAME/scheduler/' /var/spool/pbs/mom_priv/config
sed -i "s/^if /#if /g" /opt/pbs/lib/init.d/limits.pbs_mom
sed -i "s/^fi/#fi /g" /opt/pbs/lib/init.d/limits.pbs_mom

# Add $usecp option if it doesn't exists in the mom config
grep -q -F '$usecp' /var/spool/pbs/mom_priv/config || echo '$usecp *:{{mounts.home.mountpoint}} {{mounts.home.mountpoint}}' >> /var/spool/pbs/mom_priv/config

echo "Restart PBS"
retry_command "systemctl restart pbs"

echo "PBS Restarted"
