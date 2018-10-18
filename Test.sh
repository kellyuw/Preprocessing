#!/bin/sh

IMAGE=$1
TASK=$2
RUN=$3
ANTSpath=/usr/local/ANTs-2.1.0-rc3/bin/

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

${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${MNI_BRAIN_MASK} -t ${MNI_REG_PREFIX}_1Warp.nii.gz ${MNI_REG_PREFIX}_0GenericAffine.mat ${CUSTOM_REG_PREFIX}_1Warp.nii.gz ${CUSTOM_REG_PREFIX}_0GenericAffine.mat ${FUNC_REG_PREFIX}_0GenericAffine.mat -o ${OUTPUT}


echo ${IMAGE}
echo ${TASK}
echo ${RUN}
echo ${PROJECT_DIR}
echo ${CUSTOM_BRAIN}
echo ${CUSTOM_REG_PREFIX}
echo ${FUNC_BRAIN}
echo ${FUNC_REG_PREFIX}
