#!/bin/bash -X
#Register image with ANTs (func to MNI)

if [ $# -lt 3 ]; then
	echo
	echo   "bash RegisterANTs-Image.sh <full path to image> <task name> <run name> <ouput name (optional)>"
	echo
	exit 1
fi

IMAGE=$1
TASK=$2
RUN=$3
ANTSpath=/usr/local/ANTs-2.1.0-rc3/bin/

if [ $# -gt 3 ]; then
OUTPUT=$4
else
	OUTPUT=`dirname ${IMAGE}`/`basename ${IMAGE} .nii.gz`_in_MNI_space.nii.gz
fi


#Check IMAGE to make sure it is full path, instead of relative
if [[ ${IMAGE} != *stressdevlab* ]]; then
	echo "ERROR: Please include full path to image"
	exit 1
fi

PROJECT_DIR=$(echo ${IMAGE} | awk -F "/" '{print $1"/"$2"/"$3"/"$4}')
if [[ ${IMAGE} == *session* ]] || [[ ${IMAGE} == *month* ]]; then
  PROJECT_DIR=$(echo ${IMAGE} | awk -F "/" '{print $1"/"$2"/"$3"/"$4"/"$6}')
fi

MNI_BRAIN_MASK="/mnt/stressdevlab/scripts/Atlases/FSLMNI/MNI152_T1_2mm_filled_brain_mask.nii.gz"
MNI_REG_PREFIX=$(cat ${PROJECT_DIR}/ProjectInfo.txt | grep MNI_REG_PREFIX | awk -F "=" '{print $2}')
CUSTOM_BRAIN=$(cat ${PROJECT_DIR}/ProjectInfo.txt | grep CUSTOM_BRAIN | awk -F "=" '{print $2}')
CUSTOM_REG_PREFIX=$(cat ${PROJECT_DIR}/ProjectInfo.txt | grep CUSTOM_REG_PREFIX | awk -F "=" '{print $2}')
FUNC_BRAIN=$(cat ${PROJECT_DIR}/ProjectInfo.txt | grep FUNC_BRAIN | awk -F "=" '{print $2}' | sed -e "s|TASK|${TASK}|g" -e "s|RUN|${RUN}|g")
FUNC_REG_PREFIX=$(cat ${PROJECT_DIR}/ProjectInfo.txt | grep FUNC_REG_PREFIX | awk -F "=" '{print $2}' | sed -e "s|TASK|${TASK}|g" -e "s|RUN|${RUN}|g")

cd ${SUBJECTDIR}
echo ${SUBJECTDIR} ${SUBJECT}
pwd

echo "Warping ${IMAGE} to MNI"
echo "${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${MNI_BRAIN_MASK} -t ${MNI_REG_PREFIX}_1Warp.nii.gz ${MNI_REG_PREFIX}_0GenericAffine.mat ${CUSTOM_REG_PREFIX}_1Warp.nii.gz ${CUSTOM_REG_PREFIX}_0GenericAffine.mat ${FUNC_REG_PREFIX}_1Warp.nii.gz ${FUNC_REG_PREFIX}_0GenericAffine.mat -o ${OUTPUT}"

#${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${MNI_BRAIN_MASK} -t ${MNI_REG_PREFIX}_1Warp.nii.gz ${MNI_REG_PREFIX}_0GenericAffine.mat ${CUSTOM_REG_PREFIX}_1Warp.nii.gz ${CUSTOM_REG_PREFIX}_0GenericAffine.mat ${FUNC_REG_PREFIX}_0GenericAffine.mat -o ${OUTPUT}


#if [[ ${PROJECT} == *HOME* ]]; then
#	${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${MNI_BRAIN_MASK} -t ${MNIREGPREFIX}_1Warp.nii.gz ${MNIREGPREFIX}_0GenericAffine.mat ${CUSTOMREGPREFIX}_1Warp.nii.gz ${CUSTOMREGPREFIX}_0GenericAffine.mat [${FUNCREGPREFIX}_0GenericAffine.mat,1] ${FUNCREGPREFIX}_1InverseWarp.nii.gz -o ${OUTPUT}
#elif [[ ${PROJECT} == *PING* ]]; then
#	${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${MNI_BRAIN_MASK} -t ${MNIREGPREFIX}_1Warp.nii.gz ${MNIREGPREFIX}_0GenericAffine.mat ${CUSTOMREGPREFIX}_1Warp.nii.gz ${CUSTOMREGPREFIX}_0GenericAffine.mat ${FUNCREGPREFIX}.txt -o ${OUTPUT}
#elif [[ ${PROJECT} == *new_fear_pipeline* ]] || [[ ${PROJECT} == *stress_pipeline* ]] || [[ ${PROJECT} == *VSCA* ]]; then
#	${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${MNI_BRAIN_MASK} -t ${MNIREGPREFIX}_1Warp.nii.gz ${MNIREGPREFIX}_0GenericAffine.mat ${CUSTOMREGPREFIX}_1Warp.nii.gz ${CUSTOMREGPREFIX}_0GenericAffine.mat ${FUNCREGPREFIX}_1Warp.nii.gz ${FUNCREGPREFIX}_0GenericAffine.mat -o ${OUTPUT}
#elif [[ ${PROJECT} == *fear_pipeline* ]] ; then
#	${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${MNI_BRAIN_MASK} -t ${MNIREGPREFIX}_1Warp.nii.gz ${MNIREGPREFIX}_0GenericAffine.mat ${CUSTOMREGPREFIX}_1Warp.nii.gz ${CUSTOMREGPREFIX}_0GenericAffine.mat ${FUNCREGPREFIX}_0GenericAffine.mat -o ${OUTPUT}
#lif [[ ${PROJECT} == *VSCA* ]]; then
#	${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${MNI_BRAIN_MASK} -t ${MNIREGPREFIX}_1Warp.nii.gz ${MNIREGPREFIX}_0GenericAffine.mat ${CUSTOMREGPREFIX}_1Warp.nii.gz ${CUSTOMREGPREFIX}_0GenericAffine.mat ${FUNCREGPREFIX}_0GenericAffine.mat -o ${OUTPUT}
#fi

#bash ${LAB_DIR}/scripts/Preprocessing/MakeSlicerQA.sh slicer `dirname ${IMAGE}`/`basename ${IMAGE} .nii.gz`_in_MNI_space.nii.gz ${MNI_BRAIN} `dirname ${IMAGE}`/`basename ${IMAGE} .nii.gz`_in_MNI_space.gif
