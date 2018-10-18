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

if [[ ${IMAGE} == *session* ]] || [[ ${IMAGE} == *month* ]]; then
  PROJECT_DIR=$(echo ${IMAGE} | awk -F "/" '{print $1"/"$2"/"$3"/"$4"/"$6}')
	SUBJECT=$(echo ${IMAGE} | awk -F "/" '{print $5}')
else
	PROJECT_DIR=$(echo ${IMAGE} | awk -F "/" '{print $1"/"$2"/"$3"/"$4}')
	SUBJECT=$(echo ${IMAGE} | awk -F "/" '{print $5}')
fi

MNI_BRAIN_MASK="/mnt/stressdevlab/scripts/Atlases/FSLMNI/MNI152_T1_2mm_filled_brain_mask.nii.gz"
MNI_REG_PREFIX=$(cat ${PROJECT_DIR}/ProjectInfo.txt | grep MNI_REG_PREFIX | awk -F "=" '{print $2}')
CUSTOM_BRAIN=$(cat ${PROJECT_DIR}/ProjectInfo.txt | grep CUSTOM_BRAIN | awk -F "=" '{print $2}')
CUSTOM_REG_PREFIX=$(cat ${PROJECT_DIR}/ProjectInfo.txt | grep CUSTOM_REG_PREFIX | awk -F "=" '{print $2}')
FUNC_BRAIN=$(cat ${PROJECT_DIR}/ProjectInfo.txt | grep FUNC_BRAIN | awk -F "=" '{print $2}' | sed -e "s|TASK|${TASK}|g" -e "s|RUN|${RUN}|g")
T1_REG_PREFIX=$(cat ${PROJECT_DIR}/ProjectInfo.txt | grep T1_REG_PREFIX | awk -F "=" '{print $2}' | sed -e "s|TASK|${TASK}|g" -e "s|RUN|${RUN}|g")
SUBJECT_DIR=${PROJECT_DIR}/${SUBJECT}

cd ${SUBJECT_DIR}
echo ${SUBJECTDIR} ${SUBJECT}
pwd

echo "Warping ${IMAGE} to MNI"
${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${MNI_BRAIN_MASK} -t ${MNI_REG_PREFIX}_1Warp.nii.gz ${MNI_REG_PREFIX}_0GenericAffine.mat ${CUSTOM_REG_PREFIX}_1Warp.nii.gz ${CUSTOM_REG_PREFIX}_0GenericAffine.mat ${T1_REG_PREFIX}_1Warp.nii.gz ${T1_REG_PREFIX}_0GenericAffine.mat -o ${OUTPUT}
