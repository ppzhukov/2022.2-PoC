include:
  - registration

add-product-containers:
     cmd.run:
        - name: 'SUSEConnect -p sle-module-containers/15.4/x86_64'
        - require:
            - sls: registration

