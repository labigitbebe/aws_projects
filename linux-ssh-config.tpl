cat << EOF >> /Users/username/.ssh/config

Host ${hostname}
    hostname ${hostname}
    user ${user}
    identityfile ${identityfile}
EOF