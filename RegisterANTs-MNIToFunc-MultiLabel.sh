#!/bin/bash -X
#Register image with ANTs (MNI to func)

if [ $# -lt 2 ]; then
	echo
	echo   "bash RegisterANTs-Image.sh <full path to image> <task name> <run name> <output name (optional)>"
	echo
	exit 1
fi

MNI_IMAGE=$1
FUNC_IMAGE=$2

#Check FUNC_IMAGE to make sure it is full path, instead of relative
if [[ ${FUNC_IMAGE} != *stressdevlab* ]]; then
	echo "ERROR: Please include full path to image"
	exit 1
fi

#Set other vars
LAB_DIR="/mnt/stressdevlab"
PROJECT=`echo ${FUNC_IMAGE} | awk -F "stressdevlab/" '{print $2}' | awk -F "/" '{print $1}'`
PROJECT_DIR="${LAB_DIR}/${PROJECT}"
ANTSpath=/usr/local/ANTs-2.1.0-rc3/bin/
MNI_BRAIN=${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz
MNI=${FSLDIR}/data/standard/MNI152_T1_2mm.nii.gz

echo "FUNC_IMAGE: ${FUNC_IMAGE}"
echo "PROJECT: ${PROJECT}"

SUBJECT_TASK_DIR=`dirname ${FUNC_IMAGE}`
TASK=`basename ${SUBJECT_TASK_DIR}`
RUN=`basename ${FUNC_IMAGE} .nii.gz`
SUBJECT_DIR=`dirname ${SUBJECT_TASK_DIR}`
OUTPUT_DIR="${SUBJECT_TASK_DIR}/ROIMasks"

if [ $# -gt 3 ]; then
	OUTPUT=$3
else
	OUTPUT="${OUTPUT_DIR}/`basename ${MNI_IMAGE} .nii.gz`_in_${RUN}_space.nii.gz"
fi

if [[ ! -d ${OUTPUT_DIR} ]]; then
	echo "Making ${OUTPUT_DIR}"
fi

#Set ANTSpath
export ANTSPATH=${ANTSpath}

if [[ ${PROJECT} == *new_memory* ]] || [[ ${PROJECT} == *example* ]] || [[ ${PROJECT} == *VSCA* ]]; then
	CUSTOM_BRAIN=$MNI_BRAIN
elif [[ ${PROJECT} == *dep_threat_pipeline* ]]; then
	T1_BRAIN=${SUBJECT_DIR}/${TASK}/${RUN}_bet_R_brain.nii.gz
	CUSTOM_BRAIN="/mnt/stressdevlab/${PROJECT}/Standard/DT_BRAIN.nii.gz"
elif [[ ${PROJECT} == *fear_pipeline* ]]; then
	T1_BRAIN=${SUBJECT_DIR}/${TASK}/${RUN}_bet_R_brain.nii.gz
	CUSTOM_BRAIN=${LAB_DIR}/${PROJECT}/Template/Final/FINAL-MT_brain.nii.gz
elif [[ ${PROJECT} == *stress_pipeline* ]]; then
	T1_BRAIN=${SUBJECT_DIR}/${TASK}/${RUN}_bet_R_brain.nii.gz
	CUSTOM_BRAIN="${LAB_DIR}/${PROJECT}/Standard/ST_brain.nii.gz"
elif [[ ${PROJECT} == *HOME_pipeline* ]]; then
	CUSTOM_BRAIN="${LAB_DIR}/${PROJECT}/Standard/HOME_brain.nii.gz"
	T1_BRAIN=${SUBJECT_DIR}/${TASK}/${RUN}_inverseT1_brainmask_brain.nii.gz
elif [[ ${PROJECT} == *PING* ]]; then
	PROJECT="PING/NewRestingState/New"
	CUSTOM_BRAIN="${LAB_DIR}/${PROJECT}/Standard/PING_brain.nii.gz"
	T1_BRAIN=${SUBJECT_DIR}/freesurfer/inverseT1_brainmask_brain.nii.gz
	FUNC_BRAIN="${SUBJECT_TASK_DIR}/${RUN}_sr_brain.nii.gz"
fi

MNIREGPREFIX=`dirname ${CUSTOM_BRAIN}`/`basename ${CUSTOM_BRAIN} .nii.gz`_to_MNI
if [[ ${PROJECT} == *HOME_pipeline* ]] || [[ ${PROJECT} == *PING* ]]; then
	FUNCREGPREFIX=${SUBJECT_DIR}/xfm_dir/${TASK}/${RUN}_from_inverseT1_sr
	CUSTOMREGPREFIX=${SUBJECT_DIR}/xfm_dir/T1_to_custom
elif [[ ${PROJECT} == *fear_pipeline* ]]; then
	FUNCREGPREFIX=${SUBJECT_DIR}/xfm_dir/${TASK}/${RUN}_to_T1
	CUSTOMREGPREFIX=${SUBJECT_DIR}/xfm_dir/T1_to_custom
	MNIREGPREFIX=`dirname ${CUSTOM_BRAIN}`/`basename ${CUSTOM_BRAIN} .nii.gz`_to_MNI_brain
else
	FUNCREGPREFIX=${SUBJECT_DIR}/xfm_dir/${TASK}/${RUN}_to_T1
	CUSTOMREGPREFIX=${SUBJECT_DIR}/xfm_dir/T1_to_custom
fi

#Set other variables
SUBJECT=`basename ${SUBJECT_DIR}`
cd ${SUBJECT_DIR}
echo ${SUBJECT_DIR} ${SUBJECT}
pwd

check_file_exists () {
if [[ ! -f $1 ]]; then
	echo "Unable to find $1"
	exit 1
fi
}

for prereq in ${MNI_IMAGE} ${FUNC_IMAGE} ${FUNC_BRAIN} ${FUNCREGPREFIX}_1Warp.nii.gz ${FUNCREGPREFIX}_0GenericAffine.mat xfm_dir/T1_to_custom_1Warp.nii.gz xfm_dir/T1_to_custom_0GenericAffine.mat; do
	check_file_exists ${prereq}
done

if [[ ${PROJECT} == *PING* ]] || [[ ${PROJECT} == *HOME* ]]; then
	echo "Warping ${MNI_IMAGE} to ${FUNC_IMAGE}"
	#${ANTSpath}/antsApplyTransforms -i ${MNI_IMAGE} -r ${CUSTOM_BRAIN} -t [${MNIREGPREFIX}_0GenericAffine.mat,1] ${MNIREGPREFIX}_1InverseWarp.nii.gz -o ${OUTPUT}
	${ANTSpath}/antsApplyTransforms -i ${MNI_IMAGE} -r ${FUNC_BRAIN} -t ${FUNCREGPREFIX}_1Warp.nii.gz ${FUNCREGPREFIX}_0GenericAffine.mat [${CUSTOMREGPREFIX}_0GenericAffine.mat,1] ${CUSTOMREGPREFIX}_1InverseWarp.nii.gz [${MNIREGPREFIX}_0GenericAffine.mat,1] ${MNIREGPREFIX}_1InverseWarp.nii.gz -o ${OUTPUT}
	#${ANTSpath}/antsApplyTransforms -i ${MNI_IMAGE} -r ${FUNC_BRAIN} -t [${MNIREGPREFIX}_0GenericAffine.mat,1] ${MNIREGPREFIX}_1InverseWarp.nii.gz [${CUSTOMREGPREFIX}_0GenericAffine.mat,1] ${CUSTOMREGPREFIX}_1InverseWarp.nii.gz  -o ${OUTPUT}

elif [[ ${PROJECT} == *fear_pipeline* ]]; then
	echo "Warping ${MNI_IMAGE} to ${FUNC_IMAGE}"
	${ANTSpath}/antsApplyTransforms -i ${MNI_IMAGE} -r ${FUNC_BRAIN} -t [${MNIREGPREFIX}_0GenericAffine.mat,1] ${MNIREGPREFIX}_1InverseWarp.nii.gz [${CUSTOMREGPREFIX}_0GenericAffine.mat,1] ${CUSTOMREGPREFIX}_1InverseWarp.nii.gz [${FUNCREGPREFIX}_0GenericAffine.mat,1] ${FUNCREGPREFIX}_1InverseWarp.nii.gz -o ${OUTPUT}
fi

#bash ${LAB_DIR}/scripts/Preprocessing/MakeSlicerQA.sh slicer ${OUTPUT} ${FUNC_IMAGE} `dirname ${OUTPUT}`/`basename ${OUTPUT} .nii.gz`.png
