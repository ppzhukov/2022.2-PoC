base:
  'roles:router':
    - match: grain
    - router
  'roles:rancher':
    - match: grain
    - rancher
    - chrony
  'roles:rke':
    - match: grain
    - rke
    - chrony
  '*':
    - ssh-key
