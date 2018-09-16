#!/bin/bash

	USAGE(){
	echo "Identify scanner spikes by interrogating the signal outside of the brain."
	echo "================================================================="
	echo "Usage: "
	echo " ibicIDSN <File> <tr> "
	echo "         Note: Two parameters required -- don't forget the TR"
	}

if [ $# -lt 2 ]; then
	clear
	echo ====================================
	echo   Two arguments required
	echo ====================================
	USAGE ;
	exit
fi

if [ ! -e ${1} ] ; then
	clear
	echo ""
	echo ====================================
	echo The file ${1} does not exist
	echo ====================================
	echo
	USAGE ;
	exit
fi

file=${1}
tr=${2}
temp_dir=`mktemp -d /tmp/tmp.IDSNXXXXX`
#temp_dir="/tmp/tmp.IDSN29tUk/"
home=`pwd`

echo "Making images in temp dir: ${temp_dir}"
cd ${temp_dir}
cp ${file} ${temp_dir}

echo Generating a tissue mask...
fslsplit ${file} split_vol

for vol in split_vol*; do
	bet ${vol} `basename $vol`_brain -f 0.3
done

fslmerge -t all_vols_brain `ls split_vol*brain*`

fslmaths all_vols_brain -Tmean vol0_brain

fslmaths vol0_brain.nii.gz -bin -kernel gauss 12 -ero -ero vol0_brain_e2.nii.gz

fslmaths vol0_brain_e2.nii.gz -kernel gauss 15 -dilM -dilM -dilM vol0_brain_e2d3

rm all_vols_brain*
rm split_vol*
rm vol0_brain.nii.gz
rm vol0_brain_e2.nii.gz

fslsplit vol0_brain_e2d3.nii.gz temp_slice -z

rm vol0_brain_e2d3.nii.gz

for i in `ls temp_slice*`; do fslmaths temp_slice0000 -add $i temp_slice0000; done

for i in `ls temp_slice*`; do cp temp_slice0000.nii.gz $i; done

fslmerge -z max_brain `ls temp_slice00*`

rm temp_slice00*

fslmaths max_brain.nii.gz -bin tissue_mask

echo Generating an Out of Body mask...

fslmaths tissue_mask.nii.gz -mul -1 -add 1 -bin OutOfBodyMask

fslmaths ${file} -Tmax max_func

fslmaths max_func.nii.gz  -mul tissue_mask.nii.gz backgroundimage

fslmaths ${file} -mul OutOfBodyMask.nii.gz OutOfBodyData

echo Running Melodic to generate components...
melodic -i OutOfBodyData.nii.gz -o `basename ${file} .nii.gz`_OutOfBody.ica --bgimage=backgroundimage.nii.gz --nomask --nobet --tr=2 --mmthresh=0.5 --report

rm max_func.nii.gz tissue_mask.nii.gz backgroundimage.nii.gz max_brain.nii.gz OutOfBodyMask.nii.gz OutOfBodyData.nii.gz

echo Identifying Spikes

if [ -f `basename ${file} .nii.gz`_SN_all_outliers.txt ]; then rm `basename ${file} .nii.gz`_SN_all_outliers.txt; fi

echo 'Start looking for components!'
for component in `basename ${file} .nii.gz`_OutOfBody.ica/report/t[0-9]*.txt
do
    row=0
    echo Working on component $component
    for line in `cat $component`
    do
	if (( $(echo "$line" | awk '{ print ($1 > 6 || $1 < -6)}') ))
	then
		echo $row is an outlier
		echo $row >> `basename ${file} .nii.gz`_SN_all_outliers.txt
	fi
	row=$(($row + 1))
    done
done
touch `basename ${file} .nii.gz`_SN_all_outliers.txt

cat `basename ${file} .nii.gz`_SN_all_outliers.txt | sort -nu | tee `dirname ${file}`/`basename ${file} .nii.gz`_all_SN_outliers.txt
rm `basename ${file} .nii.gz`_SN_all_outliers.txt

cd $home
