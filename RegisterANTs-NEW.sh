#!/bin/bash -X
#Register FEAT directory with ANTs

# Takes 3 inputs (full path to feat directory, task name, run name)

if [ $# -lt 3 ]; then
	echo
	echo   "bash RegisterANTs.sh <full path to feat directory> <task name> <run name>"
	echo
	exit 1
fi

FEATDIR=$1
TASK=$2
RUN=$3

LAB_DIR="/mnt/stressdevlab"
PROJECT=`echo ${FEATDIR} | awk -F "stressdevlab/" '{print $2}' | awk -F "/" '{print $1}'`
PROJECT_DIR="${LAB_DIR}/${PROJECT}"
SCRIPTS_DIR=${LAB_DIR}/scripts/Preprocessing
MNI_BRAIN=${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz

echo "FEATDIR: ${FEATDIR}"
echo "TASK: ${TASK}"
echo "RUN: ${RUN}"
echo "PROJECT: ${PROJECT}"

#Check FEATDIR to make sure it is full path, instead of relative
if [[ ${FEATDIR} != *stressdevlab* ]]; then
	echo "ERROR: Please include full path to feat directory."
	exit 1
fi

SUBJECTDIR=`echo ${FEATDIR} | awk -F "/${TASK}" '{print $1}'`
if [[ `basename ${SUBJECTDIR}` == *session* ]]; then
	SUBJECT=`dirname ${SUBJECTDIR} | awk -F "/fear_pipeline/" '{print $2}'`
	SUBJECTDIR=${LAB_DIR}/${PROJECT}/`basename ${SUBJECTDIR}`/${SUBJECT}
elif [[ `basename ${SUBJECTDIR}` == *month* ]]; then
	SUBJECT=`dirname ${SUBJECTDIR} | awk -F "/stress_pipeline/" '{print $2}'`
	SUBJECTDIR=${LAB_DIR}/${PROJECT}/`basename ${SUBJECTDIR}`/${SUBJECT}
fi

if [[ ${PROJECT} == *HOME_pipeline* ]] || [[ ${PROJECT} == *PING* ]]; then
	BRAINMASK=${SUBJECTDIR}/${TASK}/${RUN}_sr_brain.nii.gz
else
	BRAINMASK=${SUBJECTDIR}/${TASK}/${RUN}_bet_R_brain.nii.gz
fi

#Set other variables
SUBJECT=`basename ${SUBJECTDIR}`
echo ${SUBJECTDIR} ${SUBJECT}

#Remove ANTSReg flag if exists
if [[ -f ${FEATDIR}/.ANTSREG ]]; then
	rm "${FEATDIR}/.ANTSREG"
fi

#Make directories for registration
mkdir -p ${FEATDIR}/reg_standard/stats
mkdir -p ${FEATDIR}/reg

#Copy the standard MNI brain and selfreg (identity matrix) to featdir
cp ${MNI_BRAIN} ${FEATDIR}/reg/standard.nii.gz
cp ${LAB_DIR}/scripts/Preprocessing/selfreg.mat ${FEATDIR}/reg/example_func2standard.mat


#Warp example_func, mean_func, and mask to MNI space
echo "Warping example_func, mean_func, and mask to MNI space..."
for imagetype in example_func mean_func mask; do
		fslmaths ${FEATDIR}/${imagetype}.nii.gz -mas ${BRAINMASK} ${FEATDIR}/${imagetype}_brain.nii.gz
		bash ${SCRIPTS_DIR}/RegisterANTs-FuncToMNI-Image.sh ${FEATDIR}/${imagetype}_brain.nii.gz ${TASK} ${RUN} ${FEATDIR}/reg_standard/${imagetype}.nii.gz
done

#Register cope images
echo "Registering cope, varcope, and zstat images..."
for imagetype in cope varcope zstat; do
	for image in ${FEATDIR}/stats/${imagetype}*.nii.gz; do
		bash ${SCRIPTS_DIR}/RegisterANTs-FuncToMNI-Image.sh ${image} ${TASK} ${RUN} ${FEATDIR}/reg_standard/stats/`basename ${image}`
	done
done

#Make dof
echo "Making dof images..."
dof=${FEATDIR}/stats/dof; num=0;
for cope in ${FEATDIR}/reg_standard/stats/cope*.nii.gz; do
	num=$((num+1))
	fslmaths ${cope} -mul 0 -add `cat $dof` ${FEATDIR}/reg_standard/stats/FEtdof_t${num}.nii.gz
done

#Leave flag when registration finishes
echo ${FEATDIR}/reg_standard/stats/FEtdof_t${num}.nii.gz
if [[ -f ${FEATDIR}/reg_standard/stats/FEtdof_t${num}.nii.gz ]]; then
	touch ${FEATDIR}/.ANTSREG
fi
