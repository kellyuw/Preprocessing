#!/bin/bash -X

####################################
# PURPOSE: register FEAT dir with ANTs (after first levels, register FEAT dir files to a format FSL likes for group levels). This code calls RegisterANTs-FuncToMNI-Image.sh as well
####################################
# USAGE:   bash   <this script>   <full path to feat dir>   <task name>   <run name>
#      example:
#      bash ./RegisterANTs-FEAT.sh /mnt/stressdevlab/fear_pipeline/1001/session1/rest/ROIMasks/Amygdala_bl_Harvard-Oxford_thr50_binarized.feat rest Rest

# TO RUN FOR MULTIPLE SUBJECTS AT ONCE, EXAMPLE:
# for i in `cat /mnt/stressdevlab/fear_pipeline/SubjectLists/Rest_All_n132.txt`; do bash /mnt/stressdevlab/fear_pipeline/Rest/scripts/ROI/RegisterANTs-FEAT.sh /mnt/stressdevlab/fear_pipeline/$i/session1/rest/ROIMasks/Amygdala_bl_Harvard-Oxford_thr50_binarized.feat rest Rest; done

# BEFORE ACTUALLY RUNNING, CAN SEE IF EVERYTHING IS WORKING BY DOING:
# for i in `cat /mnt/stressdevlab/fear_pipeline/SubjectLists/Rest_All_n132.txt`; do ls; done (or ... ; do echo; done)
####################################


#Register FEAT directory with ANTs

# Takes 3 inputs (full path to feat directory, task name, run name)

if [ $# -lt 3 ]; then
	echo
	echo   "bash RegisterANTs-FEAT.sh <full path to feat directory> <task name> <run name> "
	echo
	exit 1
fi

FEAT_DIR=$1
TASK=$2
RUN=$3

#Check FEAT_DIR to make sure it is full path, instead of relative
if [[ ${FEAT_DIR} != *stressdevlab* ]]; then
	echo "ERROR: Please include full path to image"
	exit 1
fi

if [[ ${FEAT_DIR} == *session* ]] || [[ ${FEAT_DIR} == *month* ]]; then
  PROJECT_DIR=$(echo ${FEAT_DIR} | awk -F "/" '{print $1"/"$2"/"$3"/"$4"/"$6}')
	SUBJECT=$(echo ${FEAT_DIR} | awk -F "/" '{print $5}')
elif [[ ${FEAT_DIR} == *PING* ]]; then
	PROJECT_DIR=$(echo ${FEAT_DIR} | awk -F "/" '{print $1"/"$2"/"$3"/"$4"/"$5"/"$6}')
	SUBJECT=$(echo ${FEAT_DIR} | awk -F "/" '{print $7}')
else
	PROJECT_DIR=$(echo ${FEAT_DIR} | awk -F "/" '{print $1"/"$2"/"$3"/"$4}')
	SUBJECT=$(echo ${FEAT_DIR} | awk -F "/" '{print $5}')
fi

SUBJECT_TASK_DIR=`dirname ${FEAT_DIR}`
TASK=`basename ${SUBJECT_TASK_DIR}`
RUN=`basename ${FEAT_DIR} .nii.gz`
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
SCRIPTS_DIR="/mnt/stressdevlab/scripts/Preprocessing"

#Set other variables
REG_STATS_DIR="${FEAT_DIR}/reg_standard/stats"
REG_DIR="${FEAT_DIR}/reg"
STATS_DIR="${FEAT_DIR}/stats"

#Remove ANTSReg flag if exists
if [[ -f ${FEAT_DIR}/.ANTSREG ]]; then
	rm "${FEAT_DIR}/.ANTSREG"
fi


#Make directories for registration
mkdir -p ${REG_STATS_DIR}
mkdir -p ${REG_DIR}

#Copy the standard MNI brain and selfreg (identity matrix) to FEAT_DIR
cp ${MNI_BRAIN} ${REG_DIR}/standard.nii.gz
cp ${SCRIPTS_DIR}/selfreg.mat ${REG_DIR}/example_func2standard.mat

#Warp example_func, mean_func, and mask to MNI space
echo "Warping example_func, mean_func, and mask to MNI space..."
for imagetype in example_func mean_func mask; do
	fslmaths ${FEAT_DIR}/${imagetype}.nii.gz -mas ${FUNC_BRAIN} ${FEAT_DIR}/${imagetype}_brain.nii.gz
	bash ${SCRIPTS_DIR}/RegisterANTs-FuncToMNI-Image.sh ${FEAT_DIR}/${imagetype}_brain.nii.gz ${TASK} ${RUN} ${FEAT_DIR}/reg_standard/${imagetype}.nii.gz
done
exit
#Register cope images
echo "Registering cope, varcope, and zstat images..."
for imagetype in cope varcope zstat; do
	for image in `ls ${STATS_DIR}/${imagetype}*.nii.gz`; do
		echo "${image}"
		bash ${SCRIPTS_DIR}/RegisterANTs-FuncToMNI-Image.sh ${image} ${TASK} ${RUN} ${REG_STATS_DIR}/`basename ${image}`
	done
done

#Make dof
echo "Making dof images..."
dof=${STATS_DIR}/dof; num=0;
for cope in `ls ${REG_STATS_DIR}/cope*.nii.gz`; do
	num=$((num+1))
	fslmaths ${cope} -mul 0 -add `cat $dof` ${REG_STATS_DIR}/FEtdof_t${num}.nii.gz
done

#Leave flag when registration finishes
echo ${REG_STATS_DIR}/FEtdof_t${num}.nii.gz
if [[ -f ${REG_STATS_DIR}/FEtdof_t${num}.nii.gz ]]; then
	touch ${FEAT_DIR}/.ANTSREG
fi
