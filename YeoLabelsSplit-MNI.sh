#!/bin/sh

ProjectDir=$1
Subject=$2

if [[ ${ProjectDir} == *fear_pipeline* ]]; then
	Session=$3
	ProjectDir="/mnt/stressdevlab/fear_pipeline/session${Session}"
elif [[ ${ProjectDir} == *stress_pipeline* ]]; then
	Month=$3
	ProjectDir="/mnt/stressdevlab/stress_pipeline/month${Month}"
fi

ROIs="/mnt/stressdevlab/scripts/Atlases/Yeo_JNeurophysiol11_SplitLabels/MNI152/7Networks.txt"
NumROIs=`cat ${ROIs} | wc -l`

if [[ ${ProjectDir} == *PING* ]]; then
RegisteredLabels="${ProjectDir}/${Subject}/rest/ROIMasks/Yeo2011_7Networks_N1000.split_components.FSL_MNI152_2mm_in_Rest_space.nii.gz"
fi

OutDir="${ProjectDir}/${Subject}/rest/ROIMasks/yeo_labels"
mkdir -p ${OutDir}

for i in `seq 1 ${NumROIs}` ; do

	ROI_NAME=`head -n ${i} ${ROIs} | tail -n 1 | awk -F " " '{print $2}'`
	ROI_NUM=`head -n ${i} ${ROIs} | tail -n 1 | awk -F " " '{print $1}'`
	echo ${ROI} ${i}
	fslmaths ${RegisteredLabels} -thr ${i} -uthr ${i} -bin ${OutDir}/${i}_${ROI_NAME}.nii.gz
	
	fslmeants -i ${ProjectDir}/${Subject}/rest/Rest_final.nii.gz -m ${OutDir}/${i}_${ROI_NAME}.nii.gz -o ${OutDir}/${i}_${ROI_NAME}.txt
done
