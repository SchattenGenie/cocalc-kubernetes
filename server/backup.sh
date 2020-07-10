#!/bin/bash
#$(kubectl get pod -l "app=cocalc" -o name)
kubectl exec  -ti  cocalc-7b97f4465b-8sdcj  --  \
   bash -c "pg_dump -U sage -h /projects/postgres/data/socket/ smc > /backup/`date +%Y_%m_%d__%H_%M_%S`_smc.sql && tar -cf /backup/`date +%Y_%m_%d__%H_%M_%S`_smc.tar /projects/conf /projects/home"

