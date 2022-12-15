/home/sles/.ssh/authorized_keys:
    file:
        - append
        - sources:
            - salt://ssh/id_rsa.pub
            - salt://ssh/tf_id_rsa.pub