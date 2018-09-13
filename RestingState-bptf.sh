#!/bin/sh

#Different source
#https://webcache.googleusercontent.com/search?q=cache:gVRbKOOCtYEJ:https://www.jiscmail.ac.uk/cgi-bin/webadmin%3FA2%3Dfsl%3B9ffadc97.1109+&cd=1&hl=en&ct=clnk&gl=us

ifile=$1
bptf_file=`dirname $ifile`/`basename $ifile _no_nuisance.nii.gz`_bptf.nii.gz
bptf_temp_file=`dirname $ifile`/`basename $ifile _no_nuisance.nii.gz`_bptf_temp.nii.gz
tmean_file=`dirname $ifile`/`basename $ifile _no_nuisance.nii.gz`_bptf_Tmean.nii.gz
tr=`fslval $1 pixdim4`

#sigma[vol] = filter_width[secs]/(2*TR[secs])
#https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=FSL;bad22e29.1709

lp_sigma=`echo "scale=5;50 / $tr" | bc`
hp_sigma=`echo "scale=5;6.25 / $tr" | bc`

fslmaths $ifile -Tmean ${tmean_file}
fslmaths $ifile -bptf ${hp_sigma} ${lp_sigma} ${bptf_temp_file}
fslmaths ${bptf_temp_file} -add ${tmean_file} ${bptf_file}

echo "** RestingState-bptf.sh **"
echo ${lp_sigma}
echo ${hp_sigma}
