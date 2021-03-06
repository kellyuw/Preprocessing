#!/bin/bash -X
#Register image with ANTs (MNI to func)

if [ $# -lt 2 ]; then
	echo
	echo   "bash RegisterANTs-MNIToFunc-Image.sh <full path to MNI image> <full path to func image> <output(optional)>"
	echo
	exit 1
fi

#Set ANTSpath
ANTSpath=/usr/local/ANTs-2.1.0-rc3/bin/
export ANTSPATH=${ANTSpath}

MNI_IMAGE=$1
FUNC_IMAGE=$2
MNI_BRAIN=${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz

#Check FUNC_IMAGE to make sure it is full path, instead of relative
if [[ ${FUNC_IMAGE} != *stressdevlab* ]]; then
	echo "ERROR: Please include full path to image"
	exit 1
fi

if [[ ${FUNC_IMAGE} == *session* ]] || [[ ${FUNC_IMAGE} == *month* ]]; then
  PROJECT_DIR=$(echo ${FUNC_IMAGE} | awk -F "/" '{print $1"/"$2"/"$3"/"$4"/"$6}')
	SUBJECT=$(echo ${FUNC_IMAGE} | awk -F "/" '{print $5}')
elif [[ ${FUNC_IMAGE} == *PING* ]]; then
	PROJECT_DIR=$(echo ${FUNC_IMAGE} | awk -F "/" '{print $1"/"$2"/"$3"/"$4"/"$5"/"$6}')
	SUBJECT=$(echo ${FUNC_IMAGE} | awk -F "/" '{print $7}')
else
	PROJECT_DIR=$(echo ${FUNC_IMAGE} | awk -F "/" '{print $1"/"$2"/"$3"/"$4}')
	SUBJECT=$(echo ${FUNC_IMAGE} | awk -F "/" '{print $5}')
fi

SUBJECT_TASK_DIR=`dirname ${FUNC_IMAGE}`
TASK=`basename ${SUBJECT_TASK_DIR}`
RUN=`basename ${FUNC_IMAGE} .nii.gz`
SUBJECT_DIR=`dirname ${SUBJECT_TASK_DIR}`
OUTPUT_DIR="${SUBJECT_TASK_DIR}/ROIMasks"
MNI_BRAIN_MASK="/mnt/stressdevlab/scripts/Atlases/FSLMNI/MNI152_T1_2mm_filled_brain_mask.nii.gz"
MNI_REG_PREFIX=$(cat ${PROJECT_DIR}/ProjectInfo.txt | grep MNI_REG_PREFIX | awk -F "=" '{print $2}')
CUSTOM_BRAIN=$(cat ${PROJECT_DIR}/ProjectInfo.txt | grep CUSTOM_BRAIN | awk -F "=" '{print $2}')
CUSTOM_REG_PREFIX=$(cat ${PROJECT_DIR}/ProjectInfo.txt | grep CUSTOM_REG_PREFIX | awk -F "=" '{print $2}')
T1_BRAIN=$(cat ${PROJECT_DIR}/ProjectInfo.txt | grep T1_brain | awk -F "=" '{print $2}')
FUNC_BRAIN=$(cat ${PROJECT_DIR}/ProjectInfo.txt | grep FUNC_BRAIN | awk -F "=" '{print $2}' | sed -e "s|TASK|${TASK}|g" -e "s|RUN|${RUN}|g")
T1_REG_PREFIX=$(cat ${PROJECT_DIR}/ProjectInfo.txt | grep T1_REG_PREFIX | awk -F "=" '{print $2}' | sed -e "s|TASK|${TASK}|g" -e "s|RUN|${RUN}|g")
T1_REG_TYPE=$(echo "${T1_REG_PREFIX:$((${#T1_REG_PREFIX}-1)):1}")
SUBJECT_DIR=${PROJECT_DIR}/${SUBJECT}

cd ${SUBJECT_DIR}
pwd

if [ $# -gt 2 ]; then
	OUTPUT=$3
else
	OUTPUT="${OUTPUT_DIR}/`basename ${MNI_IMAGE} .nii.gz`_in_${RUN}_space.nii.gz"
fi

if [[ ! -d ${OUTPUT_DIR} ]]; then
	echo "Making ${OUTPUT_DIR}"
fi

echo "Warping ${MNI_IMAGE} to ${RUN} space"
if [[ ${T1_REG_TYPE} == *r* ]]; then
	${ANTSpath}/antsApplyTransforms -i ${MNI_IMAGE} -r ${FUNC_BRAIN} -t [${T1_REG_PREFIX}_0GenericAffine.mat,1] [${CUSTOM_REG_PREFIX}_0GenericAffine.mat,1] ${CUSTOM_REG_PREFIX}_1InverseWarp.nii.gz [${MNI_REG_PREFIX}_0GenericAffine.mat,1] ${MNI_REG_PREFIX}_1InverseWarp.nii.gz -o ${OUTPUT}
else
	${ANTSpath}/antsApplyTransforms -i ${MNI_IMAGE} -r ${FUNC_BRAIN} -t [${T1_REG_PREFIX}_0GenericAffine.mat,1] ${T1_REG_PREFIX}_1InverseWarp.nii.gz [${CUSTOM_REG_PREFIX}_0GenericAffine.mat,1] ${CUSTOM_REG_PREFIX}_1InverseWarp.nii.gz [${MNI_REG_PREFIX}_0GenericAffine.mat,1] ${MNI_REG_PREFIX}_1InverseWarp.nii.gz -o ${OUTPUT}
fi

echo "Warping ${MNI_IMAGE} to T1 space"
${ANTSpath}/antsApplyTransforms -i ${MNI_IMAGE} -r ${T1_BRAIN} -t  [${CUSTOM_REG_PREFIX}_0GenericAffine.mat,1] ${CUSTOM_REG_PREFIX}_1InverseWarp.nii.gz [${MNI_REG_PREFIX}_0GenericAffine.mat,1] ${MNI_REG_PREFIX}_1InverseWarp.nii.gz -o `dirname ${T1_BRAIN}`/`basename ${MNI_IMAGE} .nii.gz`_in_T1_space.nii.gz

exit
