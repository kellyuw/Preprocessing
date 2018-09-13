#!/bin/bash

SUBJECT=$1
SUBJECT_DIR="/mnt/stressdevlab/PING/NewRestingState/New/${SUBJECT}"
INPUT1="${SUBJECT_DIR}/QA/rest/Test/1.nii.gz"
INPUT2="${SUBJECT_DIR}/QA/rest/Test/2.nii.gz"
#T1="${SUBJECT_DIR}/freesurfer/T1.nii.gz"
RGB1="${SUBJECT_DIR}/QA/rest/Test/`basename ${INPUT1} .nii.gz`_rgb.mha"
RGB2="${SUBJECT_DIR}/QA/rest/Test/`basename ${INPUT2} .nii.gz`_rgb.mha"
FUNC="${SUBJECT_DIR}/rest/Rest_MidVol.nii.gz"
FUNC_MASK="${SUBJECT_DIR}/rest/Rest_big_brain.nii.gz"
#T1_MASK="${SUBJECT_DIR}/freesurfer/best_brainmask.nii.gz.nii.gz"

color="red"
/usr/local/ANTs-2.1.0-rc3/bin/ConvertScalarImageToRGB 3 ${INPUT1} ${RGB1} ${FUNC_MASK} red [0,3]
/usr/local/ANTs-2.1.0-rc3/bin/ConvertScalarImageToRGB 3 ${INPUT2} ${RGB2} ${FUNC_MASK} blue [0,3]

		#/usr/local/ANTs-2.1.0-rc3/bin/CreateTiledMosaic -i ${FUNC} -r `dirname ${RGB}`/`basename ${RGB} .nii.gz`${color}.nii.gz  -x ${FUNC_MASK} -d ${DIR} -o ${SUBJECT_DIR}/QA/rest/Test/`basename ${RGB} .nii.gz`${color}_${DIR}.png -f 0x1
/usr/local/ANTs-2.1.0-rc3/bin/CreateTiledMosaic -i ${FUNC} -r ${RGB1} -d 0 -o ${SUBJECT_DIR}/QA/rest/Test/1.jpg -f 0x1 -alpha 0.9
/usr/local/ANTs-2.1.0-rc3/bin/CreateTiledMosaic -i ${FUNC} -r ${RGB2} -d 0 -o ${SUBJECT_DIR}/QA/rest/Test/2.jpg -f 0x1 -alpha 0.9
composite -blend 90 ${SUBJECT_DIR}/QA/rest/Test/1.jpg ${SUBJECT_DIR}/QA/rest/Test/2.jpg ${SUBJECT_DIR}/QA/rest/Test/blend_90.jpg
composite -blend 80 ${SUBJECT_DIR}/QA/rest/Test/1.jpg ${SUBJECT_DIR}/QA/rest/Test/2.jpg ${SUBJECT_DIR}/QA/rest/Test/blend_80.jpg
composite -blend 70 ${SUBJECT_DIR}/QA/rest/Test/1.jpg ${SUBJECT_DIR}/QA/rest/Test/2.jpg ${SUBJECT_DIR}/QA/rest/Test/blend_70.jpg
