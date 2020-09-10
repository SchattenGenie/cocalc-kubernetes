#!/bin/bash
#$(kubectl get pod -l "app=cocalc" -o name)
kubectl --kubeconfig=/home/dmaevsky/.kube/config exec  -ti  $(kubectl --kubeconfig=/home/dmaevsky/.kube/config get pod -l "app=cocalc" -o name)  --  \
   bash -c "pg_dump -U sage -h /projects/postgres/data/socket/ -Fc smc >  /backup/`date +%Y_%m_%d__%H_%M_%S`_smc.sql && tar --exclude='/projects/home/0ec2b845-2d40-44df-89ab-c38a2a4c4e5f/mlhep2020/AIFeynman' --exclude='*.zip' --exclude='*.npz' --exclude='.[^/]*' -czvf  /backup/`date +%Y_%m_%d__%H_%M_%S`_smc.tar /projects/conf /projects/home"










