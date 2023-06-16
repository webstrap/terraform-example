#cloud-config

hostname: example-${ecs_cluster}

write_files:
  - path: /var/lib/iptables/rules-save
    filesystem: root
    mode: 0644
    contents:
      inline: |
        *nat
        -A PREROUTING -d 169.254.170.2/32 -p tcp -m tcp --dport 80 -j DNAT --to-destination 127.0.0.1:51679
        -A OUTPUT -d 169.254.170.2/32 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 51679
        COMMIT
  - path: /etc/sysctl.d/localnet.conf
    filesystem: root
    mode: 0644
    contents:
      inline: |
        net.ipv4.conf.all.route_localnet=1
  - path: /etc/sysctl.d/bbr.conf
    permissions: 0644
    owner: root
    content: |
      net.core.default_qdisc=fq
      net.ipv4.tcp_congestion_control=bbr
  - path: /etc/ecs/ecs.config
    permissions: 0644
    owner: root
    content: |
      ECS_CLUSTER=${ecs_cluster}
      ECS_ENABLE_SPOT_INSTANCE_DRAINING=true
  - path: /etc/ssh/sshd_config
    permissions: 0600
    owner: root:root
    content: |
      Port 22

      PrintMotd yes

      UsePrivilegeSeparation sandbox
      Subsystem sftp internal-sftp

      PermitRootLogin without-password

      PasswordAuthentication no
      PermitEmptyPasswords no
      ChallengeResponseAuthentication no
      UsePAM no

      PubkeyAuthentication yes

      IgnoreRhosts yes

      AcceptEnv LANG LC_*

coreos:
  update:
    reboot-strategy: off
  units:
    - name: format-ebs-sdf-volume.service
      command: start
      content: |
        [Unit]
        Description=Formats the EBS sdf volume if needed
        Before=docker.service
        [Service]
        Type=oneshot
        RemainAfterExit=yes
        ExecStart=/bin/bash -c '(/usr/sbin/blkid -t TYPE=ext4 | grep /dev/sdf) || (/usr/sbin/wipefs -fa /dev/sdf && /usr/sbin/mkfs.ext4 /dev/sdf)'
    - name: var-lib-docker.mount
      command: start
      content: |
        [Unit]
        Description=Mount EBS Volume to /var/lib/docker
        Requires=format-ebs-sdf-volume.service
        After=format-ebs-sdf-volume.service
        Before=docker.service
        [Mount]
        What=/dev/sdf
        Where=/var/lib/docker
        Type=ext4
    - name: iptables-restore.service
      enable: true
    - name: systemd-sysctl.service
      enable: true
    - name: ks-sysctl-load-bbr-config.service
      command: start
      content: |
        [Unit]
        Description=Load sysctl bbr config
        [Service]
        Type=oneshot
        ExecStart=/usr/sbin/sysctl -p /etc/sysctl.d/bbr.conf
    - name: ks-sysctl-set-vm-max-count.service
      command: start
      content: |
        [Unit]
        Description=Set VM max Map count
        [Service]
        Type=oneshot
        ExecStart=/usr/sbin/sysctl vm.max_map_count=262144
    - name: amazon-ecs-agent.service
      command: start
      content: |
        [Unit]
        Description=AWS ECS Agent
        Documentation=https://docs.aws.amazon.com/AmazonECS/latest/developerguide/
        Requires=docker.socket
        After=docker.socket

        [Service]
        Environment=ECS_CLUSTER=${ecs_cluster}
        Environment=ECS_LOGLEVEL=info
        Environment=ECS_VERSION=latest
        Restart=on-failure
        RestartSec=30
        RestartPreventExitStatus=5
        SyslogIdentifier=ecs-agent
        ExecStartPre=-/bin/mkdir -p /var/log/ecs /var/ecs-data /etc/ecs
        ExecStartPre=-/usr/bin/touch /etc/ecs/ecs.config
        ExecStartPre=-/usr/bin/docker kill ecs-agent
        ExecStartPre=-/usr/bin/docker rm ecs-agent
        ExecStartPre=/usr/bin/docker pull amazon/amazon-ecs-agent:$${ECS_VERSION}
        ExecStart=/usr/bin/docker run \
            --name ecs-agent \
            --env-file=/etc/ecs/ecs.config \
            --volume=/var/run/docker.sock:/var/run/docker.sock \
            --volume=/var/log/ecs:/log \
            --volume=/var/ecs-data:/data \
            --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
            --volume=/run/docker/execdriver/native:/var/lib/docker/execdriver/native:ro \
            --publish=127.0.0.1:51678:51678 \
            --publish=127.0.0.1:51679:51679 \
            --env=ECS_AVAILABLE_LOGGING_DRIVERS='["awslogs"]' \
            --env=ECS_ENABLE_TASK_IAM_ROLE=true \
            --env=ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true \
            --env=ECS_LOGFILE=/log/ecs-agent.log \
            --env=ECS_LOGLEVEL=$${ECS_LOGLEVEL} \
            --env=ECS_DATADIR=/data \
            --env=ECS_CLUSTER=$${ECS_CLUSTER} \
            amazon/amazon-ecs-agent:$${ECS_VERSION}

        [Install]
        WantedBy=multi-user.target
