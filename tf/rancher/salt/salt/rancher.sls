include:
  - registration

rke-pre-configure:
      cmd.run:
        - name: |
            swapoff -a
            systemctl disable kdump --now
            systemctl disable firewalld --now
