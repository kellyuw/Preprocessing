#!/bin/bash

#Display usage instructions if no subject ID is entered.
if [ $# -lt 1 ]; then
	echo
	echo   "bash UploadZip.sh <Subject ID>"
	echo
	exit
fi

#Confirm that script is run from the beip directory only
if [[ `pwd` != *"/mnt/stressdevlab/beip"* ]]; then
	echo
	echo "ERROR: This script currently is designed for BEIP data only."
	echo "Please navigate to the /mnt/stressdevlab/beip directory before running."
	echo
	exit
fi

#Get variables
subject=$1
filename="/mnt/stressdevlab/beip/subjects/${subject}/${subject}.zip"

#Create zip file and set permissions appropriately
if [ ! -f ${filename} ]; then
	cd /mnt/stressdevlab/beip/subjects/${subject}/ANONDICOM
	echo "Zipping anonymized dicoms for beip subject ${subject}..."
	sudo zip -r ${filename} .
	sudo chmod ug+rwx ${filename}
	sudo chgrp sdlabadmin ${filename}
fi

#Provide reminder of extra steps required for uploading 
echo
echo "REMINDER: Please upload zip file at ${filename} to XNAT for safe-keeping!"
echo
echo "1. Navigate to https://xnatpro.ibic.washington.edu/app/template/AlternateImageUpload.vm"
echo "2. Select BEIP from the project dropdown menu"
echo "3. Select Archive as the destination"
echo "4. Click the 'Choose File' button and navigate through file browser to select zipped image file."
echo "5. Click the 'Begin Upload' button."
echo "6. Double-check the BEIP project page to confirm data has been uploaded correctly."

exit

curl -v -k -u ${user}:${password} -X POST "${host}/data/JSESSION" > test.cookie

#echo $cookie
c=`cat test.cookie`

xnatsubject="BEIP_${subject}"
experimentid="${xnatsubject}"

#Create session
curl -v -k --cookie "JSESSIONID=${c}" -u ${user}:${password} -X PUT "${host}/data/archive/projects/${project}/subjects/${subject}/experiments/${experimentid}?xsiType=xnat:mrSessionData"


#Upload zip
curl -v -k --cookie "JSESSIONID=${c}" -u ${user}:${password} --form image_archive=@${file} "${host}/data/services/import"

#curl -v -k --cookie "JSESSIONID=${c}" -u ${user}:${password} -X POST @"${filename}" "${host}/data/services/import?project=$project&subject=${subject}&session=${experimentid}&overwrite=append&autoarchive=false&inbody=true"


#close session
#curl -v -k --cookie "JSESSIONID=${c}" -X DELETE https://xnatpro.ibic.washington.edu/data/JSESSION
