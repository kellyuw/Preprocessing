#!/bin/bash -X

SUBJECT=$1
FS_SUBJECT=${SUBJECT}

if [[ `pwd` == *fear_pipeline* ]]; then
FS_DIR="/mnt/stressdevlab/fear_pipeline/raw_FreeSurfer"
SESSION=$2
FS_SUBJECT="${SUBJECT}_${SESSION}"

elif [[ `pwd` == *new_memory_pipeline* ]]; then
FS_DIR="/mnt/stressdevlab/new_memory_pipeline/raw_FreeSurfer"

elif [[ `pwd` == *dep_threat_pipeline* ]]; then
FS_DIR="/mnt/stressdevlab/dep_threat_pipeline/raw_FreeSurfer"

elif [[ `pwd` == *stress_pipeline* ]]; then
FS_DIR="/mnt/stressdevlab/stress_pipeline/raw_FreeSurfer"
SESSION=$2
FS_SUBJECT="${SUBJECT}_${SESSION}"

elif [[ `pwd` == *SAS_DTI* ]]; then
FS_DIR="/mnt/stressdevlab/SAS_DTI/FreeSurfer"
fi

cd ${FS_DIR}

if [[ ${hostname} == *vmpfc* ]]; then
    export FREESURFER_HOME=/usr/local/freesurfer/freesurfer_dev
else
    export FREESURFER_HOME=/usr/local/freesurfer/stable6_0
fi

echo "FREESURFER_HOME ${FREESURFER_HOME}"

source ${FREESURFER_HOME}/SetUpFreeSurfer.sh
export SUBJECTS_DIR=${FS_DIR}

if [[ ! -f ${FS_DIR}/${FS_SUBJECT}/mri/rh.hippoSfVolumes-T1.v10.txt ]]; then
	${FREESURFER_HOME}/bin/recon-all -s ${FS_SUBJECT} -hippocampal-subfields-T1
elif [[ ! -f ${FS_DIR}/${FS_SUBJECT}/mri/assembly/right_discreteLabels.nii ]]; then
	if [[ `pwd` == *fear_pipeline* ]]; then
		bash /mnt/stressdevlab/scripts/FreeSurfer/HippoSeg/QC_subfields_step_1_prepare.sh ${SUBJECT} ${SESSION}
	else
		bash /mnt/stressdevlab/scripts/FreeSurfer/HippoSeg/QC_subfields_step_1_prepare.sh ${SUBJECT}
	fi
fi

export FREESURFER_HOME=/usr/local/freesurfer/stable5_3/
source /usr/local/freesurfer/stable5_3/SetUpFreeSurfer.sh
