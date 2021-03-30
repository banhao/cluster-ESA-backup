# cluster-ESA-backup

cluster_ESA_backup.sh is a fork of "https://www.cisco.com/c/en/us/support/docs/security/email-security-appliance/118403-technote-esa-00.html"

But this version is much better than the Cisco original one. The original one needs to disconncect the cluster and reconnect again. 

This version just force the appliance switch to machine mode. After the backup use the SCP to copy the configuration backup file and use cURL to send an email.

SCP setting please refer this Cisco document: https://www.cisco.com/c/en/us/support/docs/security/email-security-appliance/118305-technote-esa-00.html#

