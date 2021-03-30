#! /bin/bash
#
# Script to save the ESA config, then copy locally via SCP. This is assuming you wish to
# have the cluster in SSH via port 22. This script has been written and tested against
# AsyncOS 13.5.2-036 (03/30/2021).
#
# *NOTE* This script is a proof-of-concept and provided as an example basis. While these steps have
# been successfully tested, this script is for demonstration and illustration purposes. Custom
# scripts are outside of the scope and supportability of Cisco. Cisco Technical Assistance will
# not write, update, or troubleshoot custom external scripts at any time.
#
# <SCRIPT>
#
# $HOSTNAME & $HOSTNAME2 can be either the FQDN or IP address of the ESAs in cluster.
#
HOSTNAME1="xxx.xxx.xxx"
HOSTNAME2="xxx.xxx.xxx"
#
# $USERNAME assumes that you have preconfigured SSH key from this host to your ESA.
# http://www.cisco.com/c/en/us/support/docs/security/email-security-appliance/118305-technote-esa-00.html
#
USERNAME=
#
# $BACKUP_PATH is the directory location on the local system.
#
BACKUP_PATH="xxxxxxxxx"
#
# $FILENAME contains the actual script that calls the ESA, issues the 'saveconfig' command.
# The rest of the string is the cleanup action to reflect only the <model>-<serial number>-<timestamp>.xml.
#
echo "|=== PHASE 1 ===| BACKUP CONFIGURATION ON ESA"
FILENAME1=`ssh $USERNAME@$HOSTNAME1 "clustermode cluster; saveconfig 2" | grep xml | sed 's/\"\/configuration\///g' | sed 's/\"\.$//g'`
FILENAME2=`ssh $USERNAME@$HOSTNAME2 "clustermode cluster; saveconfig 2" | grep xml | sed 's/\"\/configuration\///g' | sed 's/\"\.$//g'`
#
# The 'scp' command will secure copy the $FILENAME from the ESA to specified backup path, as entered above.
# The -q option for 'scp' will disable the copy meter/progress bar.
#
echo "|=== PHASE 2 ===| COPY XML FROM ESA TO LOCAL"
scp -q $USERNAME@$HOSTNAME1:/configuration/$FILENAME1 $BACKUP_PATH
scp -q $USERNAME@$HOSTNAME2:/configuration/$FILENAME2 $BACKUP_PATH
#
echo "|=== COMPLETE ===| $FILENAME1 successfully saved to $BACKUP_PATH"
echo "|=== COMPLETE ===| $FILENAME2 successfully saved to $BACKUP_PATH"
#
echo "|=== PHASE 3 ===| SEND XML TO xxx@xxx.xxx"
echo "<html>
<body>
    <div>
        <p>The following is a copy of the configuration information for your Cisco C600V Email Security Appliance.</p>
    </div>
</body>
</html>" > message.html
message_base64=$(cat message.html | base64)
FILENAME1_base64=$(cat $BACKUP_PATH/$FILENAME1 | base64)
FILENAME2_base64=$(cat $BACKUP_PATH/$FILENAME2 | base64)

echo "To: xxx@xxx.xxx
Subject: xxxxxxxxx
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary=\"MULTIPART-MIXED-BOUNDARY\"

--MULTIPART-MIXED-BOUNDARY
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: base64
Content-Disposition: inline

$message_base64

--MULTIPART-MIXED-BOUNDARY
Content-Type: text/plain
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename=\"$FILENAME1\"

$FILENAME1_base64

--MULTIPART-MIXED-BOUNDARY
Content-Type: text/plain
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename=\"$FILENAME2\"

$FILENAME2_base64

--MULTIPART-MIXED-BOUNDARY--

" >> data.txt

unix2dos data.txt

curl smtp://xxx.xxx.xxx --mail-rcpt 'xxx@xxx.xxx' --upload-file data.txt --user xxx:PASSWORD -v login-options AUTH=NTLM

# </SCRIPT>
#
