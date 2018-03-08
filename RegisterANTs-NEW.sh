#!/bin/bash -X
#Register FEAT directory with ANTs

# Takes 3 inputs (subject number, session number (single integer))

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
ANTSpath=/usr/local/ANTs-2.1.0-rc3/bin/
MNI_BRAIN=${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz
MNI=${FSLDIR}/data/standard/MNI152_T1_2mm.nii.gz

echo "FEATDIR: ${FEATDIR}"
echo "TASK: ${TASK}"
echo "RUN: ${RUN}"
echo "PROJECT: ${PROJECT}"

#Check FEATDIR to make sure it is full path, instead of relative
if [[ ${FEATDIR} != *stressdevlab* ]]; then
	echo "ERROR: Please include full path to feat directory."
	exit 1
fi

#Set ANTSpath
export ANTSPATH=${ANTSpath}
SUBJECTDIR=`echo ${FEATDIR} | awk -F "/${TASK}" '{print $1}'`

if [[ ${PROJECT} == *new_memory* ]] || [[ ${PROJECT} == *example* ]] || [[ ${PROJECT} == *VSCA* ]]; then
	CUSTOM_BRAIN=$MNI_BRAIN
elif [[ ${PROJECT} == *dep_threat_pipeline* ]]; then
	CUSTOM_BRAIN="/mnt/stressdevlab/${PROJECT}/Standard/DT_BRAIN.nii.gz"
	REGPREFIX=`dirname ${CUSTOM_BRAIN}`/`basename ${CUSTOM_BRAIN} .nii.gz`_to_MNI
elif [[ ${PROJECT} == *fear_pipeline* ]]; then
	CUSTOM_BRAIN=${LAB_DIR}/${PROJECT}/Template/Final/FINAL-MT_brain.nii.gz
	REGPREFIX=`dirname ${CUSTOM_BRAIN}`/`basename ${CUSTOM_BRAIN} .nii.gz`_to_MNI_brain
elif [[ ${PROJECT} == *stress_pipeline* ]]; then
	CUSTOM_BRAIN="${LAB_DIR}/${PROJECT}/Standard/ST_brain.nii.gz"
	REGPREFIX=`dirname ${CUSTOM_BRAIN}`/`basename ${CUSTOM_BRAIN} .nii.gz`_to_MNI
elif [[ ${PROJECT} == *HOME_pipeline* ]]; then
	CUSTOM_BRAIN="${LAB_DIR}/${PROJECT}/Standard/HOME_brain.nii.gz"
	REGPREFIX=`dirname ${CUSTOM_BRAIN}`/`basename ${CUSTOM_BRAIN} .nii.gz`_to_MNI
elif [[ ${PROJECT} == *PING* ]]; then
	CUSTOM_BRAIN="${LAB_DIR}/${PROJECT}/Standard/PING_brain.nii.gz"
	REGPREFIX=`dirname ${CUSTOM_BRAIN}`/`basename ${CUSTOM_BRAIN} .nii.gz`_to_MNI
fi

#Set other variables
STDREGDIR=${FEATDIR}/reg_standard/stats
REGDIR=${FEATDIR}/reg
STATSDIR=${FEATDIR}/stats
REGPREFIX=`dirname ${CUSTOM_BRAIN}`/`basename ${CUSTOM_BRAIN} .nii.gz`_to_MNI
SUBJECT=`basename ${SUBJECTDIR}`

echo ${SUBJECTDIR} ${SUBJECT}

#Remove ANTSReg flag if exists
if [[ -f ${FEATDIR}/.ANTSREG ]]; then
	rm "${FEATDIR}/.ANTSREG"
fi


#Make directories for registration
mkdir -p ${STDREGDIR}
mkdir -p ${REGDIR}

#Copy the standard MNI brain and selfreg (identity matrix) to featdir
cp ${MNI_BRAIN} ${REGDIR}/standard.nii.gz
cp ${LAB_DIR}/scripts/Preprocessing/selfreg.mat ${REGDIR}/example_func2standard.mat

#Warp example_func, mean_func, and mask to MNI space
echo "Warping example_func, mean_func, and mask to MNI space..."
for imagetype in example_func mean_func mask; do

	#The ${RUN} -> T1 ras matrix is in different location for new_memory_pipeline
	if [[ ${PROJECT} == *new_memory* ]] || [[ ${PROJECT} == *example* ]]; then
		${ANTSpath}/WarpImageMultiTransform 3 ${FEATDIR}/${imagetype}.nii.gz ${FEATDIR}/reg_standard/${imagetype}.nii.gz -R ${MNI_BRAIN} ${NIH_DIR}/NIHtoMNIWarp.nii.gz ${NIH_DIR}/NIHtoMNIAffine.txt ${SUBJECTDIR}/xfm_dir/T1_to_nih_Warp.nii.gz ${SUBJECTDIR}/xfm_dir/T1_to_nih_Affine.txt ${SUBJECTDIR}/xfm_dir/${RUN}_to_T1_ras.txt
	else
		fslmaths ${FEATDIR}/${imagetype}.nii.gz -mas ${TASK}/${RUN}_bet_R_brain_mask.nii.gz ${FEATDIR}/${imagetype}_brain.nii.gz
		${ANTSpath}/antsApplyTransforms -i ${FEATDIR}/${imagetype}_brain.nii.gz -r ${MNI_BRAIN} -t ${REGPREFIX}_1Warp.nii.gz ${REGPREFIX}_0GenericAffine.mat xfm_dir/T1_to_custom_1Warp.nii.gz xfm_dir/T1_to_custom_0GenericAffine.mat xfm_dir/${TASK}/${RUN}_to_T1_1Warp.nii.gz xfm_dir/${TASK}/${RUN}_to_T1_0GenericAffine.mat -o ${FEATDIR}/reg_standard/${imagetype}.nii.gz
	fi
done

#Register cope images
echo "Registering cope, varcope, and zstat images..."
for imagetype in cope varcope zstat; do
	for image in ${STATSDIR}/${imagetype}*.nii.gz; do

		if [[ ${PROJECT} == *new_memory* ]] || [[ ${PROJECT} == *example* ]]; then
			${ANTSpath}/WarpImageMultiTransform 3 ${image} ${STDREGDIR}/`basename ${image}` -R ${MNI_BRAIN} ${NIH_DIR}/NIHtoMNIWarp.nii.gz ${NIH_DIR}/NIHtoMNIAffine.txt ${SUBJECTDIR}/xfm_dir/T1_to_nih_Warp.nii.gz ${SUBJECTDIR}/xfm_dir/T1_to_nih_Affine.txt ${SUBJECTDIR}/xfm_dir/${RUN}_to_T1_ras.txt
		else
			${ANTSpath}/antsApplyTransforms -i ${image} -r ${MNI_BRAIN} -t ${REGPREFIX}_1Warp.nii.gz ${REGPREFIX}_0GenericAffine.mat xfm_dir/T1_to_custom_1Warp.nii.gz xfm_dir/T1_to_custom_0GenericAffine.mat xfm_dir/${TASK}/${RUN}_to_T1_1Warp.nii.gz xfm_dir/${TASK}/${RUN}_to_T1_0GenericAffine.mat -o ${STDREGDIR}/`basename ${image}`
		fi
	done
done

#Make dof
echo "Making dof images..."
dof=${STATSDIR}/dof; num=0;
for cope in ${STDREGDIR}/cope*.nii.gz; do
	num=$((num+1))
	fslmaths ${cope} -mul 0 -add `cat $dof` ${STDREGDIR}/FEtdof_t${num}.nii.gz
done

#Leave flag when registration finishes
echo ${STDREGDIR}/FEtdof_t${num}.nii.gz
if [[ -f ${STDREGDIR}/FEtdof_t${num}.nii.gz ]]; then
	touch ${FEATDIR}/.ANTSREG
fi
