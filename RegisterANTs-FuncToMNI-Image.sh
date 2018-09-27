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

#Set other vars
LAB_DIR="/mnt/stressdevlab"
PROJECT=`echo ${IMAGE} | awk -F "stressdevlab/" '{print $2}' | awk -F "/" '{print $1}'`
PROJECT_DIR="${LAB_DIR}/${PROJECT}"
ANTSpath=/usr/local/ANTs-2.1.0-rc3/bin/
MNI_BRAIN=${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz
MNI_BRAIN_MASK="/mnt/stressdevlab/scripts/Atlases/FSLMNI/MNI152_T1_2mm_filled_brain_mask.nii.gz"
MNI=${FSLDIR}/data/standard/MNI152_T1_2mm.nii.gz

echo "IMAGE: ${IMAGE}"
echo "TASK: ${TASK}"
echo "RUN: ${RUN}"
echo "PROJECT: ${PROJECT}"


#Set ANTSpath
export ANTSPATH=${ANTSpath}
if [[ ${IMAGE} == *xfm_dir* ]]; then
	SUBJECTDIR=`echo ${IMAGE} | awk -F "/xfm_dir" '{print $1}'`
else
	SUBJECTDIR=`echo ${IMAGE} | awk -F "/${TASK}" '{print $1}'`
fi

if [[ ${PROJECT} == *new_memory* ]] || [[ ${PROJECT} == *example* ]] || [[ ${PROJECT} == *VSCA* ]]; then
	CUSTOM_BRAIN=$MNI_BRAIN
elif [[ ${PROJECT} == *dep_threat_pipeline* ]]; then
	CUSTOM_BRAIN="/mnt/stressdevlab/${PROJECT}/Standard/DT_BRAIN.nii.gz"
elif [[ ${PROJECT} == *new_fear_pipeline* ]]; then
	T1_BRAIN=${SUBJECTDIR}/${TASK}/${RUN}_FinalMidVol_brain.nii.gz
	CUSTOM_BRAIN=${LAB_DIR}/${PROJECT}/Template/Final/FINAL-MT_brain.nii.gz
elif [[ ${PROJECT} == *stress_pipeline* ]]; then
	T1_BRAIN=${SUBJECTDIR}/${TASK}/${RUN}_FinalMidVol_brain.nii.gz
	CUSTOM_BRAIN=${LAB_DIR}/${PROJECT}/Template/Final/FINAL-MT_brain.nii.gz
elif [[ ${PROJECT} == *HOME_pipeline* ]]; then
	CUSTOM_BRAIN="${LAB_DIR}/${PROJECT}/Standard/HOME_brain.nii.gz"
	T1_BRAIN=${SUBJECTDIR}/${TASK}/${RUN}_inverseT1_brainmask_brain.nii.gz
elif [[ ${PROJECT} == *PING* ]]; then
	PROJECT="PING/NewRestingState/New"
	CUSTOM_BRAIN="${LAB_DIR}/${PROJECT}/SaveStudySpecificTemplate/PING_brain.nii.gz"
	T1_BRAIN=${SUBJECTDIR}/freesurfer/inverseT1_brainmask_brain.nii.gz
elif [[ ${PROJECT} == *VSCA* ]]; then
	CUSTOM_BRAIN="${LAB_DIR}/${PROJECT}/Standard/VSCA_optiBET_brain.nii.gz"
	T1_BRAIN="${SUBJECTDIR}/mprage/T1_brain.nii.gz"
fi

MNIREGPREFIX=`dirname ${CUSTOM_BRAIN}`/`basename ${CUSTOM_BRAIN} .nii.gz`_to_MNI
if [[ ${PROJECT} == *HOME_pipeline* ]]; then
	FUNCREGPREFIX=${SUBJECTDIR}/xfm_dir/${TASK}/${RUN}_from_inverseT1_s
	CUSTOMREGPREFIX=${SUBJECTDIR}/xfm_dir/T1_to_custom
elif [[ ${PROJECT} == *new_fear_pipeline* ]] || [[ ${PROJECT} == *stress_pipeline* ]]; then
	FUNCREGPREFIX=${SUBJECTDIR}/xfm_dir/${TASK}/${RUN}_to_T1_s
	CUSTOMREGPREFIX=${SUBJECTDIR}/xfm_dir/T1_to_custom_s
	MNIREGPREFIX=`dirname ${CUSTOM_BRAIN}`/`basename ${CUSTOM_BRAIN} .nii.gz`_to_MNI_brain
elif [[ ${PROJECT} == *VSCA* ]]; then
	MNIREGPREFIX=${LAB_DIR}/${PROJECT}/Standard/VSCA_optiBET_brain_to_MNI_brain
	FUNCREGPREFIX="${SUBJECTDIR}/new_xfm_dir/${TASK}/${RUN}_to_T1_r"
	CUSTOMREGPREFIX="${SUBJECTDIR}/new_xfm_dir/T1_to_custom_s"
else
	FUNCREGPREFIX=${SUBJECTDIR}/xfm_dir/${TASK}/${RUN}_to_T1
	CUSTOMREGPREFIX=${SUBJECTDIR}/xfm_dir/T1_to_custom
fi

#Set other variables
SUBJECT=`basename ${SUBJECTDIR}`

if [[ ${PROJECT} == *new_fear_pipeline* ]]; then
	if [[ `basename ${SUBJECTDIR}` == *session* ]]; then
		SUBJECT=`echo ${SUBJECTDIR} | awk -F "new_fear_pipeline/" '{print $2}' | awk -F "/" '{print $1}'`
		SESSION=`echo ${SUBJECTDIR} | awk -F "new_fear_pipeline/" '{print $2}'` | awk -F "/" '{print $2}'
		SUBJECTDIR=${LAB_DIR}/${PROJECT}/${SUBJECT}/${SESSION}
	else
		SUBJECT=`echo ${SUBJECTDIR} | awk -F "new_fear_pipeline/" '{print $2}'` | awk -F "/" '{print $2}'
		SESSION=`echo ${SUBJECTDIR} | awk -F "new_fear_pipeline/" '{print $2}'` | awk -F "/" '{print $1}'
		SUBJECTDIR=${LAB_DIR}/${PROJECT}/${SUBJECT}/${SESSION}
	fi
fi

if [[ ${PROJECT} == *stress_pipeline* ]]; then
	if [[ `basename ${SUBJECTDIR}` == *month* ]]; then
		SUBJECT=`echo ${SUBJECTDIR} | awk -F "stress_pipeline/" '{print $2}' | awk -F "/" '{print $1}'`
		SESSION=`echo ${SUBJECTDIR} | awk -F "stress_pipeline/" '{print $2}'` | awk -F "/" '{print $2}'
		SUBJECTDIR=${LAB_DIR}/${PROJECT}/${SUBJECT}/${MONTH}
	else
		SUBJECT=`echo ${SUBJECTDIR} | awk -F "stress_pipeline/" '{print $2}'` | awk -F "/" '{print $2}'
		SESSION=`echo ${SUBJECTDIR} | awk -F "stress_pipeline/" '{print $2}'` | awk -F "/" '{print $1}'
		SUBJECTDIR=${LAB_DIR}/${PROJECT}/${SUBJECT}/${MONTH}
	fi
fi

cd ${SUBJECTDIR}
echo ${SUBJECTDIR} ${SUBJECT}
pwd

echo "Warping ${IMAGE} to MNI"

if [[ ${PROJECT} == *HOME* ]]; then
	${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${MNI_BRAIN_MASK} -t ${MNIREGPREFIX}_1Warp.nii.gz ${MNIREGPREFIX}_0GenericAffine.mat ${CUSTOMREGPREFIX}_1Warp.nii.gz ${CUSTOMREGPREFIX}_0GenericAffine.mat [${FUNCREGPREFIX}_0GenericAffine.mat,1] ${FUNCREGPREFIX}_1InverseWarp.nii.gz -o ${OUTPUT}
elif [[ ${PROJECT} == *PING* ]]; then
	${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${MNI_BRAIN_MASK} -t ${MNIREGPREFIX}_1Warp.nii.gz ${MNIREGPREFIX}_0GenericAffine.mat ${CUSTOMREGPREFIX}_1Warp.nii.gz ${CUSTOMREGPREFIX}_0GenericAffine.mat ${FUNCREGPREFIX}.txt -o ${OUTPUT}
elif [[ ${PROJECT} == *new_fear_pipeline* ]] || [[ ${PROJECT} == *stress_pipeline* ]]; then
	${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${MNI_BRAIN_MASK} -t ${MNIREGPREFIX}_1Warp.nii.gz ${MNIREGPREFIX}_0GenericAffine.mat ${CUSTOMREGPREFIX}_1Warp.nii.gz ${CUSTOMREGPREFIX}_0GenericAffine.mat ${FUNCREGPREFIX}_1Warp.nii.gz ${FUNCREGPREFIX}_0GenericAffine.mat -o ${OUTPUT}
elif [[ ${PROJECT} == *fear_pipeline* ]] || [[ ${PROJECT} == *VSCA* ]] ; then
	${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${MNI_BRAIN_MASK} -t ${MNIREGPREFIX}_1Warp.nii.gz ${MNIREGPREFIX}_0GenericAffine.mat ${CUSTOMREGPREFIX}_1Warp.nii.gz ${CUSTOMREGPREFIX}_0GenericAffine.mat ${FUNCREGPREFIX}_0GenericAffine.mat -o ${OUTPUT}
#lif [[ ${PROJECT} == *VSCA* ]]; then
#	${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${MNI_BRAIN_MASK} -t ${MNIREGPREFIX}_1Warp.nii.gz ${MNIREGPREFIX}_0GenericAffine.mat ${CUSTOMREGPREFIX}_1Warp.nii.gz ${CUSTOMREGPREFIX}_0GenericAffine.mat ${FUNCREGPREFIX}_0GenericAffine.mat -o ${OUTPUT}
fi

#bash ${LAB_DIR}/scripts/Preprocessing/MakeSlicerQA.sh slicer `dirname ${IMAGE}`/`basename ${IMAGE} .nii.gz`_in_MNI_space.nii.gz ${MNI_BRAIN} `dirname ${IMAGE}`/`basename ${IMAGE} .nii.gz`_in_MNI_space.gif
