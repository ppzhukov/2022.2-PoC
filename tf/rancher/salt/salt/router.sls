include:
  - registration

dns-dhcp-server-install:
  pkg.installed:
    - names:
        - dhcp-server
        - bind
    - require:
        - sls: registration

dhcpd:
  service.running:
    - enable: True
    - watch:
      - pkg: dhcp-server
      - file: /etc/dhcpd.conf
    - require:
      - pkg: dhcp-server
      - file: /etc/dhcpd.conf
      - /etc/sysconfig/dhcpd

/etc/dhcpd.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://router/dhcpd.conf
    - require:
      - pkg: dhcp-server

/etc/sysconfig/dhcpd:
  file.replace:
      - name: /etc/sysconfig/dhcpd
      - pattern: '^DHCPD_INTERFACE=".*"'
      - repl: 'DHCPD_INTERFACE="eth0"'
      - require:
        - pkg: dhcp-server

named:
  service.running:
    - enable: True
    - watch:
      - pkg: bind
      - file: /var/lib/named/master/stend.test
      - file: /var/lib/named/master/14.168.192.in-addr.arpa
      - file: /etc/named.conf
    - require:
      - pkg: bind
      - file: /var/lib/named/master/stend.test
      - file: /var/lib/named/master/14.168.192.in-addr.arpa
      - bind_conf
      - named_conf

bind_conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - names:
       - /var/lib/named/master/stend.test:
         - source: salt://router/stend.test
       - /var/lib/named/master/14.168.192.in-addr.arpa:
         - source: salt://router/14.168.192.in-addr.arpa
    - require:
      - pkg: bind

named_conf:
  file.append:
    - name: /etc/named.conf
    - text: |
            zone "stend.test" in {
                    allow-transfer { any; };
                    file "master/stend.test";
                    type master;
            };
            zone "14.168.192.in-addr.arpa" in {
                    file "master/14.168.192.in-addr.arpa";
                    type master;
            };
/etc/sysconfig/network/config:
  file.replace:
      - name: /etc/sysconfig/network/config
      - pattern: 'NETCONFIG_DNS_STATIC_SERVERS=\".*\"'
      - repl: 'NETCONFIG_DNS_STATIC_SERVERS="127.0.0.1"'
      - require:
        - pkg: bind

netconfig_update:
    cmd.run:
        - name: 'netconfig update -f'
        - require:
            - /etc/sysconfig/network/config

firewald:
  cmd.run:
    - name: |
        systemctl enable firewalld --now
        firewall-cmd --permanent --zone=external --change-interface=eth1
        firewall-cmd --permanent --zone=internal --add-interface=eth0
        firewall-cmd --permanent --zone=internal --set-target=ACCEPT
        firewall-cmd --permanent --zone=external --add-service=http --add-service=https
        firewall-cmd --reload
    - cwd: /tmp
    - shell: /bin/bash


/etc/chrony.d/ntp.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://router/ntp.conf

chronyd:
  service.running:
    - enable: True
    - watch:
      - pkg: chrony
      - file: /etc/chrony.d/ntp.conf
    - require:
      - pkg: chrony
      - file: /etc/chrony.d/ntp.conf

chronyd-install:
  pkg.installed:
    - names:
      - chrony
    - require:
        - sls: registration
