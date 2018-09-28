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

FEATDIR=$1
TASK=$2
RUN=$3

LABDIR="/mnt/stressdevlab"
PROJECT=`echo ${FEATDIR} | awk -F "stressdevlab/" '{print $2}' | awk -F "/" '{print $1}'`
SCRIPTSDIR="${LABDIR}/scripts/Preprocessing"
MNI_BRAIN=${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz
MNI_BRAIN_MASK="/mnt/stressdevlab/scripts/Atlases/FSLMNI/MNI152_T1_2mm_filled_brain_mask.nii.gz"

#Check FEATDIR to make sure it is full path, instead of relative
if [[ ${FEATDIR} != *stressdevlab* ]]; then
	echo "ERROR: Please include full path to feat directory."
	exit 1
fi

#Set other variables
REGSTATSDIR="${FEATDIR}/reg_standard/stats"
REGDIR="${FEATDIR}/reg"
STATSDIR="${FEATDIR}/stats"

echo "STATSDIR = ${STATSDIR}"

SUBJECTDIR=`echo ${FEATDIR} | awk -F "/${TASK}" '{print $1}'`

if [[ ${FEATDIR} == *HOME_pipeline* ]]; then
	BRAINMASK=${SUBJECTDIR}/${TASK}/${RUN}_sr_brain.nii.gz
elif [[ ${FEATDIR} == *PING* ]]; then
	BRAINMASK=${SUBJECTDIR}/${TASK}/${RUN}_FinalMidVol_brainmask.nii.gz
elif [[ ${FEATDIR} == *stress_pipeline* ]]; then
        BRAINMASK=${SUBJECTDIR}/${TASK}/${RUN}_FinalMidVol_brain.nii.gz
elif [[ ${FEATDIR} == *new_fear_pipeline* ]]; then
	BRAINMASK=${SUBJECTDIR}/${TASK}/${RUN}_FinalMidVol_brain.nii.gz
elif [[ ${FEATDIR} == *fear_pipeline* ]]; then
	if [[ ${TASK} == *rest* ]]; then
        	BRAINMASK=${SUBJECTDIR}/${TASK}/${RUN}_FinalMidVol_bet_R_brain_mask.nii.gz
	else
        	BRAINMASK=${SUBJECTDIR}/${TASK}/${RUN}_bet_R_brain_mask.nii.gz
	fi
elif [[ ${FEATDIR} == *VSCA* ]]; then
	BRAINMASK=${SUBJECTDIR}/new_xfm_dir/${TASK}/${RUN}_brain_from_T1_r.nii.gz
else
	BRAINMASK=${SUBJECTDIR}/${TASK}/${RUN}_bet_R_brain.nii.gz
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
	for image in `ls ${STATSDIR}/${imagetype}*.nii.gz`; do
		echo "${image}"
		bash ${SCRIPTSDIR}/RegisterANTs-FuncToMNI-Image.sh ${image} ${TASK} ${RUN} ${REGSTATSDIR}/`basename ${image}`
	done
done

#Make dof
echo "Making dof images..."
dof=${STATSDIR}/dof; num=0;
for cope in `ls ${REGSTATSDIR}/cope*.nii.gz`; do
	num=$((num+1))
	fslmaths ${cope} -mul 0 -add `cat $dof` ${REGSTATSDIR}/FEtdof_t${num}.nii.gz
done

#Leave flag when registration finishes
echo ${REGSTATSDIR}/FEtdof_t${num}.nii.gz
if [[ -f ${REGSTATSDIR}/FEtdof_t${num}.nii.gz ]]; then
	touch ${FEATDIR}/.ANTSREG
fi
