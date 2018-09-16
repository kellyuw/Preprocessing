#!/bin/bash -X
#Register FEAT directory with ANTs

# Takes 3 inputs (full path to feat directory, task name, run name)

if [ $# -lt 3 ]; then
	echo
	echo   "bash RegisterANTs-FEAT.sh <full path to feat directory> <task name> <run name> "
	echo
	exit 1
fi

FEATDIR=$1
TASK=$2
RUN=$3

LABDIR="/mnt/stressdevlab"
PROJECT=`echo ${FEATDIR} | awk -F "stressdevlab/" '{print $2}' | awk -F "/" '{print $1}'`
SCRIPTSDIR="${LABDIR}/scripts/Preprocessing"
MNI_BRAIN=${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz

#Check FEATDIR to make sure it is full path, instead of relative
if [[ ${FEATDIR} != *stressdevlab* ]]; then
	echo "ERROR: Please include full path to feat directory."
	exit 1
fi

#Set other variables
REGSTATSDIR=${FEATDIR}/reg_standard/stats
REGDIR=${FEATDIR}/reg
STATSDIR=${FEATDIR}/stats

SUBJECTDIR=`echo ${FEATDIR} | awk -F "/${TASK}" '{print $1}'`

if [[ ${FEATDIR} == *PING* ]] || [[ ${FEATDIR} == *HOME_pipeline* ]]; then
	BRAINMASK=${SUBJECTDIR}/${RUN}_sr_brain.nii.gz
elif [[ ${FEATDIR} == *new_fear_pipeline* ]]; then
	BRAINMASK=${SUBJECTDIR}/${TASK}/${RUN}_FinalMidVol_brain.nii.gz
else
	BRAINMASK=${SUBJECTDIR}/${RUN}_bet_R_brain.nii.gz
fi

#Remove ANTSReg flag if exists
if [[ -f ${FEATDIR}/.ANTSREG ]]; then
	rm "${FEATDIR}/.ANTSREG"
fi


#Make directories for registration
mkdir -p ${REGSTATSDIR}
mkdir -p ${REGDIR}

#Copy the standard MNI brain and selfreg (identity matrix) to featdir
cp ${MNI_BRAIN} ${REGDIR}/standard.nii.gz
cp ${SCRIPTSDIR}/selfreg.mat ${REGDIR}/example_func2standard.mat

#Warp example_func, mean_func, and mask to MNI space
echo "Warping example_func, mean_func, and mask to MNI space..."
for imagetype in example_func mean_func mask; do
	fslmaths ${FEATDIR}/${imagetype}.nii.gz -mas ${BRAINMASK} ${FEATDIR}/${imagetype}_brain.nii.gz
	bash ${SCRIPTSDIR}/RegisterANTs-FuncToMNI-Image.sh ${FEATDIR}/${imagetype}_brain.nii.gz ${TASK} ${RUN} ${FEATDIR}/reg_standard/${imagetype}.nii.gz
done

#Register cope images
echo "Registering cope, varcope, and zstat images..."
for imagetype in cope varcope zstat; do
	for image in ${STATSDIR}/${imagetype}*.nii.gz; do
		bash ${SCRIPTSDIR}/RegisterANTs-FuncToMNI-Image.sh ${image} ${TASK} ${RUN} ${REGSTATSDIR}/`basename ${image}`
	done
done

#Make dof
echo "Making dof images..."
dof=${STATSDIR}/dof; num=0;
for cope in ${REGSTATSDIR}/cope*.nii.gz; do
	num=$((num+1))
	fslmaths ${cope} -mul 0 -add `cat $dof` ${REGSTATSDIR}/FEtdof_t${num}.nii.gz
done

#Leave flag when registration finishes
echo ${REGSTATSDIR}/FEtdof_t${num}.nii.gz
if [[ -f ${REGSTATSDIR}/FEtdof_t${num}.nii.gz ]]; then
	touch ${FEATDIR}/.ANTSREG
fi
