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
elif [[ ${PROJECT} == *fear_pipeline* ]]; then
	if [[ `basename ${SUBJECTDIR}` == *session* ]]; then
		SUBJECT=`dirname ${SUBJECTDIR} | awk -F "/fear_pipeline/" '{print $2}'`
		SUBJECTDIR=${LAB_DIR}/${PROJECT}/`basename ${SUBJECTDIR}`/${SUBJECT}
	fi
	T1_BRAIN=${SUBJECTDIR}/${TASK}/${RUN}_bet_R_brain.nii.gz
	CUSTOM_BRAIN=${LAB_DIR}/${PROJECT}/Template/Final/FINAL-MT_brain.nii.gz
elif [[ ${PROJECT} == *stress_pipeline* ]]; then
	CUSTOM_BRAIN="${LAB_DIR}/${PROJECT}/Standard/ST_brain.nii.gz"
elif [[ ${PROJECT} == *HOME_pipeline* ]]; then
	CUSTOM_BRAIN="${LAB_DIR}/${PROJECT}/Standard/HOME_brain.nii.gz"
	T1_BRAIN=${SUBJECTDIR}/${TASK}/${RUN}_inverseT1_brainmask_brain.nii.gz
elif [[ ${PROJECT} == *PING* ]]; then
	PROJECT="PING/NewRestingState/New"
	CUSTOM_BRAIN="${LAB_DIR}/${PROJECT}/Standard/PING_brain.nii.gz"
	T1_BRAIN=${SUBJECTDIR}/freesurfer/inverseT1_brainmask_brain.nii.gz
fi

MNIREGPREFIX=`dirname ${CUSTOM_BRAIN}`/`basename ${CUSTOM_BRAIN} .nii.gz`_to_MNI
if [[ ${PROJECT} == *HOME_pipeline* ]] || [[ ${PROJECT} == *PING* ]]; then
	FUNCREGPREFIX=${SUBJECTDIR}/xfm_dir/${TASK}/${RUN}_from_inverseT1_sr
	CUSTOMREGPREFIX=${SUBJECTDIR}/xfm_dir/T1_to_custom
elif [[ ${PROJECT} == *new_fear_pipeline* ]]; then
	FUNCREGPREFIX=${SUBJECTDIR}/xfm_dir/${TASK}/${RUN}_to_T1_s
	CUSTOMREGPREFIX=${SUBJECTDIR}/xfm_dir/T1_to_custom_s
	MNIREGPREFIX=`dirname ${CUSTOM_BRAIN}`/`basename ${CUSTOM_BRAIN} .nii.gz`_to_MNI_brain
elif [[ ${PROJECT} == *fear_pipeline* ]]; then
	FUNCREGPREFIX=${SUBJECTDIR}/xfm_dir/${TASK}/${RUN}_to_T1
	CUSTOMREGPREFIX=${SUBJECTDIR}/xfm_dir/T1_to_custom
	MNIREGPREFIX=`dirname ${CUSTOM_BRAIN}`/`basename ${CUSTOM_BRAIN} .nii.gz`_to_MNI_brain
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

cd ${SUBJECTDIR}
echo ${SUBJECTDIR} ${SUBJECT}
pwd

check_file_exists () {
if [[ ! -f $1 ]]; then
	echo "Unable to find $1"
	exit 1
fi
}

if [[ ${PROJECT} == *PING* ]] || [[ ${PROJECT} == *HOME* ]]; then
	for prereq in ${FUNCREGPREFIX}_1Warp.nii.gz ${FUNCREGPREFIX}_0GenericAffine.mat ${T1_BRAIN} ${BRAINMASK} xfm_dir/T1_to_custom_1Warp.nii.gz xfm_dir/T1_to_custom_0GenericAffine.mat; do
		check_file_exists ${prereq}
	done
	#echo "Warping ${IMAGE} to T1"
	#${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${T1_BRAIN} -t [${FUNCREGPREFIX}_0GenericAffine.mat,1] ${FUNCREGPREFIX}_1InverseWarp.nii.gz -o `dirname ${IMAGE}`/`basename ${IMAGE} .nii.gz`_in_T1_space.nii.gz

	#echo "Warping ${IMAGE} to ${CUSTOM_BRAIN}"
	#${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${CUSTOM_BRAIN} -t ${CUSTOMREGPREFIX}_1Warp.nii.gz ${CUSTOMREGPREFIX}_0GenericAffine.mat [${FUNCREGPREFIX}_0GenericAffine.mat,1] ${FUNCREGPREFIX}_1InverseWarp.nii.gz -o `dirname ${IMAGE}`/`basename ${IMAGE} .nii.gz`_in_custom_space.nii.gz

	echo "Warping ${IMAGE} to MNI"
	${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${MNI_BRAIN} -t ${MNIREGPREFIX}_1Warp.nii.gz ${MNIREGPREFIX}_0GenericAffine.mat ${CUSTOMREGPREFIX}_1Warp.nii.gz ${CUSTOMREGPREFIX}_0GenericAffine.mat [${FUNCREGPREFIX}_0GenericAffine.mat,1] ${FUNCREGPREFIX}_1InverseWarp.nii.gz -o ${OUTPUT}

elif [[ ${PROJECT} == *fear_pipeline* ]]; then
	#echo "Warping ${IMAGE} to T1"
	#${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${T1_BRAIN} -t ${FUNCREGPREFIX}_1Warp.nii.gz ${FUNCREGPREFIX}_0GenericAffine.mat -o `dirname ${IMAGE}`/`basename ${IMAGE} .nii.gz`_in_T1_space.nii.gz

	#echo "Warping ${IMAGE} to ${CUSTOM_BRAIN}"
	#${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${CUSTOM_BRAIN} -t ${CUSTOMREGPREFIX}_1Warp.nii.gz ${CUSTOMREGPREFIX}_0GenericAffine.mat ${FUNCREGPREFIX}_1Warp.nii.gz ${FUNCREGPREFIX}_0GenericAffine.mat -o `dirname ${IMAGE}`/`basename ${IMAGE} .nii.gz`_in_custom_space.nii.gz

	echo "Warping ${IMAGE} to MNI"
	${ANTSpath}/antsApplyTransforms -i ${IMAGE} -r ${MNI_BRAIN} -t ${MNIREGPREFIX}_1Warp.nii.gz ${MNIREGPREFIX}_0GenericAffine.mat ${CUSTOMREGPREFIX}_1Warp.nii.gz ${CUSTOMREGPREFIX}_0GenericAffine.mat ${FUNCREGPREFIX}_1Warp.nii.gz ${FUNCREGPREFIX}_0GenericAffine.mat -o ${OUTPUT}
fi

#bash ${LAB_DIR}/scripts/Preprocessing/MakeSlicerQA.sh slicer `dirname ${IMAGE}`/`basename ${IMAGE} .nii.gz`_in_MNI_space.nii.gz ${MNI_BRAIN} `dirname ${IMAGE}`/`basename ${IMAGE} .nii.gz`_in_MNI_space.gif
