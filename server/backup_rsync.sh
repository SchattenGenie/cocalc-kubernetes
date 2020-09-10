#!/bin/bash
#$(kubectl get pod -l "app=cocalc" -o name)
kubectl --kubeconfig=/home/dmaevsky/.kube/config exec  -ti  $(kubectl --kubeconfig=/home/dmaevsky/.kube/config get pod -l "app=cocalc" -o name)  --  \
   bash -c "pg_dump -U sage -h /projects/postgres/data/socket/ -Fc smc >  /backup/`date +%Y_%m_%d__%H_%M_%S`_smc.sql && /backup/backup.sh"










