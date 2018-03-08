#!/bin/sh

FS_Dir=$1
Subject=$2
Project_Dir=`dirname ${FS_Dir}`

if [[ ${FS_Dir} == *fear_pipeline* ]]; then
	Subject=$2
	Session=$3
	Subject_Dir=${Project_Dir}/session${Session}/${Subject}
	FS_Subject=${Subject}_${Session}
elif [[ ${FS_Dir} == *stress_pipeline* ]]; then
	Subject=$2
	Month=$3
	Subject_Dir=${Project_Dir}/month${Month}/${Subject}
	FS_Subject=${Subject}_${Month}
elif [[ ${FS_Dir} == *HOME* ]]; then
	Subject_Dir=${Project_Dir}/${Subject}
	FS_Subject=${Subject}
else
	Subject=$2
	Subject_Dir=${Project_Dir}/${Subject}
	FS_Subject=${Subject}
fi

Standard_Dir=${Project_Dir}/Standard
FS_Dir=${Project_Dir}/raw_FreeSurfer


ROIs="/mnt/stressdevlab/PING/RestingState/ROIScripts/ROI_Labels.txt"
NumROIs=`cat ${ROIs} | wc -l`


for i in `seq 1 ${NumROIs}` ; do
	ROI=`head -n ${i} ${ROIs} | tail -n 1`
	echo ${ROI} ${i}
	fslmaths ${Subject_Dir}/${ROI} -bin -mul ${i} ${Subject_Dir}/freesurfer/${i}_`basename ${ROI}`
done

rm ${Subject_Dir}/freesurfer/combined_labels.nii.gz
for i in `ls ${Subject_Dir}/freesurfer/[0-9]*` ; do
	if [[ ! -f ${Subject_Dir}/freesurfer/combined_labels.nii.gz ]]; then
		echo "Starting with ${i}"
		mask="${Subject_Dir}/freesurfer/combined_labels.nii.gz"
		cp ${i} ${mask}
	else
		echo "Adding ${i} to ${mask}"
		fslmaths ${mask} -add ${i} ${mask}
	fi
done
