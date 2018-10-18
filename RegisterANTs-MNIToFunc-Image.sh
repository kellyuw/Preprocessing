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
FUNC_BRAIN=$(cat ${PROJECT_DIR}/ProjectInfo.txt | grep FUNC_BRAIN | awk -F "=" '{print $2}' | sed -e "s|TASK|${TASK}|g" -e "s|RUN|${RUN}|g")
FUNC_REG_PREFIX=$(cat ${PROJECT_DIR}/ProjectInfo.txt | grep FUNC_REG_PREFIX | awk -F "=" '{print $2}' | sed -e "s|TASK|${TASK}|g" -e "s|RUN|${RUN}|g")
SUBJECT_DIR=${PROJECT_DIR}/${SUBJECT}

cd ${SUBJECT_DIR}
echo ${SUBJECTDIR} ${SUBJECT}
echo "FUNC_IMAGE: ${FUNC_IMAGE}"
echo "PROJECT: ${PROJECT}"
pwd

if [ $# -gt 2 ]; then
	OUTPUT=$3
else
	OUTPUT="${OUTPUT_DIR}/`basename ${MNI_IMAGE} .nii.gz`_in_${RUN}_space.nii.gz"
fi

if [[ ! -d ${OUTPUT_DIR} ]]; then
	echo "Making ${OUTPUT_DIR}"
fi


${ANTSpath}/antsApplyTransforms -i ${MNI_IMAGE} -r ${FUNC_BRAIN} -t ${FUNC_REG_PREFIX}_1Warp.nii.gz ${FUNC_REG_PREFIX}_0GenericAffine.mat [${CUSTOM_REG_PREFIX}_0GenericAffine.mat,1] ${CUSTOM_REG_PREFIX}_1InverseWarp.nii.gz [${MNI_REG_PREFIX}_0GenericAffine.mat,1] ${MNI_REG_PREFIX}_1InverseWarp.nii.gz -o ${OUTPUT}

exit


if [[ ${PROJECT} == *new_memory* ]] || [[ ${PROJECT} == *example* ]] || [[ ${PROJECT} == *VSCA* ]]; then
	CUSTOM_BRAIN=$MNI_BRAIN
elif [[ ${PROJECT} == *dep_threat_pipeline* ]]; then
	FUNC_BRAIN=${SUBJECTDIR}/${TASK}/${RUN}_bet_R_brain.nii.gz
	CUSTOM_BRAIN="/mnt/stressdevlab/${PROJECT}/Standard/DT_BRAIN.nii.gz"
elif [[ ${PROJECT} == *fear_pipeline* ]]; then
	CUSTOM_BRAIN=${LAB_DIR}/${PROJECT}/Template/Final/FINAL-MT_brain.nii.gz
	T1_BRAIN=${SUBJECTDIR}/freesurfer/T1_bet_R_brain.nii.gz
elif [[ ${PROJECT} == *stress_pipeline* ]]; then
	FUNC_BRAIN=${SUBJECTDIR}/${TASK}/${RUN}_FinalMidVol_brain.nii.gz
	CUSTOM_BRAIN="${LAB_DIR}/${PROJECT}/Template/ST_brain.nii.gz"
	T1_BRAIN=${SUBJECTDIR}/freesurfer/T1_brain.nii.gz
elif [[ ${PROJECT} == *HOME_pipeline* ]]; then
	CUSTOM_BRAIN="${LAB_DIR}/${PROJECT}/Standard/HOME_brain.nii.gz"
	T1_BRAIN=${SUBJECTDIR}/${TASK}/${RUN}_inverseT1_brainmask_brain.nii.gz
elif [[ ${PROJECT} == *PING* ]]; then
	PROJECT="PING/NewRestingState/New"
	CUSTOM_BRAIN="${LAB_DIR}/${PROJECT}/SaveStudySpecificTemplate/PING_brain.nii.gz"
	T1_BRAIN=${SUBJECTDIR}/freesurfer/inverseT1_brainmask_brain.nii.gz
fi

MNIREGPREFIX=`dirname ${CUSTOM_BRAIN}`/`basename ${CUSTOM_BRAIN} .nii.gz`_to_MNI
if [[ ${PROJECT} == *HOME_pipeline* ]]; then
	FUNCREGPREFIX=${SUBJECTDIR}/xfm_dir/${TASK}/${RUN}_from_inverseT1_s
	CUSTOMREGPREFIX=${SUBJECTDIR}/xfm_dir/T1_to_custom
	FUNC_BRAIN="${SUBJECT_TASK_DIR}/${RUN}_MidVol.nii.gz"
elif [[ ${PROJECT} == *PING* ]]; then
	FUNCREGPREFIX=${SUBJECTDIR}/xfm_dir/rest/EPIREG-Rest_to_T1_fs_ras.txt
	CUSTOMREGPREFIX=${SUBJECTDIR}/xfm_dir/T1_to_custom_sr
	FUNC_BRAIN="${SUBJECT_TASK_DIR}/${RUN}_FinalMidVol_brain.nii.gz"
elif [[ ${PROJECT} == *fear_pipeline* ]]; then
	if [[ ${TASK} == *rest* ]]; then
		FUNCREGPREFIX=${SUBJECTDIR}/xfm_dir/${TASK}/${RUN}_to_T1_r
		CUSTOMREGPREFIX=${SUBJECTDIR}/xfm_dir/T1_to_custom_s
		FUNC_BRAIN=${SUBJECTDIR}/${TASK}/${RUN}_FinalMidVol_bet_R_brain.nii.gz
	else
		FUNCREGPREFIX=${SUBJECTDIR}/xfm_dir/${TASK}/${RUN}_to_T1
		CUSTOMREGPREFIX=${SUBJECTDIR}/xfm_dir/T1_to_custom
		FUNC_BRAIN=${SUBJECTDIR}/${TASK}/${RUN}_bet_R_brain.nii.gz
	fi
	MNIREGPREFIX=`dirname ${CUSTOM_BRAIN}`/`basename ${CUSTOM_BRAIN} .nii.gz`_to_MNI_brain
elif [[ ${PROJECT} == *stress_pipeline* ]]; then
	FUNCREGPREFIX=${SUBJECTDIR}/xfm_dir/${TASK}/${RUN}_to_T1_r
	CUSTOMREGPREFIX=${SUBJECTDIR}/xfm_dir/T1_to_custom_s
	MNIREGPREFIX=`dirname ${CUSTOM_BRAIN}`/`basename ${CUSTOM_BRAIN} .nii.gz`_to_MNI_brain
else
	FUNCREGPREFIX=${SUBJECTDIR}/xfm_dir/${TASK}/${RUN}_to_T1
	CUSTOMREGPREFIX=${SUBJECTDIR}/xfm_dir/T1_to_custom
fi

#Set other variables
SUBJECT=`basename ${SUBJECTDIR}`
cd ${SUBJECTDIR}
echo ${SUBJECTDIR} ${SUBJECT}
pwd


if [[ ${PROJECT} == *HOME* ]]; then
	${ANTSpath}/antsApplyTransforms -i ${MNI_IMAGE} -r ${FUNC_BRAIN} -t ${FUNCREGPREFIX}_1Warp.nii.gz ${FUNCREGPREFIX}_0GenericAffine.mat [${CUSTOMREGPREFIX}_0GenericAffine.mat,1] ${CUSTOMREGPREFIX}_1InverseWarp.nii.gz [${MNIREGPREFIX}_0GenericAffine.mat,1] ${MNIREGPREFIX}_1InverseWarp.nii.gz -o ${OUTPUT}
elif [[ ${PROJECT} == *fear_pipeline* ]] || [[ ${PROJECT} == *stress_pipeline* ]]; then
		${ANTSpath}/antsApplyTransforms -i ${MNI_IMAGE} -r ${FUNC_BRAIN} -t [${FUNCREGPREFIX}_0GenericAffine.mat,1] [${CUSTOMREGPREFIX}_0GenericAffine.mat,1] ${CUSTOMREGPREFIX}_1InverseWarp.nii.gz [${MNIREGPREFIX}_0GenericAffine.mat,1] ${MNIREGPREFIX}_1InverseWarp.nii.gz ${INTERP} -o ${OUTPUT}
elif [[ ${PROJECT} == *PING* ]]; then
	${ANTSpath}/antsApplyTransforms -i ${MNI_IMAGE} -r ${FUNC_BRAIN} -t [${FUNCREGPREFIX},1] [${CUSTOMREGPREFIX}_0GenericAffine.mat,1] ${CUSTOMREGPREFIX}_1InverseWarp.nii.gz [${MNIREGPREFIX}_0GenericAffine.mat,1] ${MNIREGPREFIX}_1InverseWarp.nii.gz ${INTERP} -o ${OUTPUT}
fi

#bash ${LAB_DIR}/scripts/Preprocessing/MakeSlicerQA.sh slicer ${OUTPUT} ${FUNC_IMAGE} `dirname ${OUTPUT}`/`basename ${OUTPUT} .nii.gz`.png
