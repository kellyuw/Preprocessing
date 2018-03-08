#!/bin/sh

ProjectDir=$1
Subject=$2

if [[ ${ProjectDir} == *fear_pipeline* ]]; then
	Session=$3
	ProjectDir="/mnt/stressdevlab/fear_pipeline/session${Session}"
elif [[ ${ProjectDir} == *stress_pipeline* ]]; then
	Month=$3
	ProjectDir="/mnt/stressdevlab/stress_pipeline/month${Month}"
elif [[ ${ProjectDir} == *PING* ]]; then
	Vendor=$3
	ProjectDir="/mnt/stressdevlab/PING/RestingState/${Vendor}"
fi

ROIs="/mnt/stressdevlab/PING/RestingState/ROIScripts/ROI_Labels.txt"
NumROIs=`cat ${ROIs} | wc -l`

if [[ ${ProjectDir} != *PING* ]]; then
RegisteredLabels=${ProjectDir}/${Subject}/xfm_dir/rest/Rest_fs_labels_d.nii.gz
fi

mkdir -p ${ProjectDir}/${Subject}/xfm_dir/rest/yeo_labels

for i in `seq 1 ${NumROIs}` ; do
	ROI=`head -n ${i} ${ROIs} | tail -n 1`
	echo ${ROI} ${i}
	fslmaths ${RegisteredLabels} -thr ${i} -uthr ${i} ${ProjectDir}/${Subject}/xfm_dir/rest/yeo_labels/${i}_`basename ${ROI}`
	#fslmeants -i ${ProjectDir}/${Subject}/rest/Rest_bptf_good_vols.nii.gz -m ${ProjectDir}/${Subject}/xfm_dir/rest/yeo_labels/${i}_`basename ${ROI}` -o ${ProjectDir}/${Subject}/xfm_dir/rest/yeo_labels/${i}_`basename ${ROI} .nii.gz`.txt
	fslmeants -i ${ProjectDir}/${Subject}/rest/Rest_final.nii.gz -m ${ProjectDir}/${Subject}/xfm_dir/rest/yeo_labels/${i}_`basename ${ROI}` -o ${ProjectDir}/${Subject}/xfm_dir/rest/yeo_labels/${i}_`basename ${ROI} .nii.gz`.txt
done
