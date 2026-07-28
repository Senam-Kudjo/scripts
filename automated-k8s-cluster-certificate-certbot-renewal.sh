## shiiiiit the title is self explanatory.
### the cron schedule used => 10 0 10 */3 * /opt/cert/staging/cert-renewal.sh
### it means it executes on the 10th day of every three month ... thats approximately every 70 days
### DON'T FORGET TO CHANGE THE PATHS!!!

#!/bin/bash

cd /etc/letsencrypt/live/staging.mymtn.com.gh #i.e

sudo certbot renew --cert-name <insert_domain_name>

kubectl config use-context <insert_cluster_name>

kubectl get secret <insert_secret_name> -n <insert_namespace> -o yaml > $(date +%F)-ssl-cert-backup.yaml

kubectl delete secret <insert_secret_name> -n <insert_namespace>

kubectl create secret tls <insert_secret_name> -n <insert_namespace> --cert=/etc/letsencrypt/live/staging.mymtnlite.com.gh/fullchain.pem --key=/etc/letsencrypt/live/staging.mymtnlite.com.gh/privkey.pem --dry-run=client -o yaml | kubectl apply -f -
