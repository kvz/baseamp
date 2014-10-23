## Kevin's Transloadit Tasks (#22)

- [x] CRM's System libxml is linked dynamically into PHP. Issue is closed to cleanup for Fahad, but still needs looking into: https://github.com/transloadit/transloadit-CRM/issues/3
- [x] Add support for 3 more parameters to html/convert bot: http://support.transloadit.com/discussions/questions/91523-alpha-masking
- [ ] 2014-10-26 KVZ Upgrade stunnel and turn off SSLv3 (again) https://assets.digitalocean.com/email/POODLE_email.html (#133039174)
- [ ] Logrotate on CRM boxes for `/srv/transloadit-crm/shared/log` (3.6G nginx.access.log, 1.9G crm-cron-cake-calc_revenue.log)
- [ ] Use Airbud in InstanceFetcher
- [ ] CRM: Add Oracle & rapgenius logo. Cambridge logo and the one next to it have a white bg.
- [ ] Add librato alerts e.g. for high cellcount / mem usage / assembly errors
- [ ] Create /queues API2 endpoint that statuspage & GlobalMetricsReporter can use. Now we directly push to statuspage (bah). And have GMR directly connect to redis (bah).
- [ ] Create an ubuntufy script, and IAM it via http://www.packer.io/. We can run the ubuntufy by hand on Iron. Then we can ditch ubuntu* and deb scripts.


