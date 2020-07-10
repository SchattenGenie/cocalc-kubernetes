#!/bin/bash
#$(kubectl get pod -l "app=cocalc" -o name)
kubectl --kubeconfig=/home/vbelavin/.kube/config exec  -ti  $(kubectl get pod -l "app=cocalc" -o name)  --  \
   bash -c "pg_dump -U sage -h /projects/postgres/data/socket/ smc > /backup/`date +%Y_%m_%d__%H_%M_%S`_smc.sql && tar -cf /backup/`date +%Y_%m_%d__%H_%M_%S`_smc.tar /projects/conf /projects/home"

