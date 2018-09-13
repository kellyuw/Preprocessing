#!/bin/bash -X

#Initialize variables
TimeStart=$(date +"%s")
FS_Dir=$1

if [[ ${FS_Dir} == *fear_pipeline* ]]; then
	Subject=$2
	Session=$3
	Project_Dir="/mnt/stressdevlab/fear_pipeline"
	Subject_Dir=${Project_Dir}/session${Session}/${Subject}
	FS_Subject=${Subject}_${Session}
elif [[ ${FS_Dir} == *stress_pipeline* ]]; then
	Subject=$2
	Month=$3
	Project_Dir="/mnt/stressdevlab/stress_pipeline"
	Subject_Dir=${Project_Dir}/month${Month}/${Subject}
	FS_Subject=${Subject}_${Month}
elif [[ ${FS_Dir} == *HOME* ]]; then
	Subject=$2
	Project_Dir="/mnt/stressdevlab/HOME_pipeline"
	Subject_Dir=${Project_Dir}/${Subject}
	FS_Subject=${Subject}
elif [[ ${FS_Dir} == *PING* ]]; then
	Subject=$2
	Project_Dir="/mnt/stressdevlab/PING/NewRestingState/New"
	Subject_Dir=${Project_Dir}/${Subject}
	FS_Subject=${Subject}
else
	Subject=$2
	Project_Dir=`dirname ${FS_Dir}`
	Subject_Dir="${Project_Dir}/${Subject}"
	FS_Subject=${Subject}
fi

Standard_Dir=${Project_Dir}/Standard



ANTSpath=/usr/local/ANTs-2.1.0-rc3/bin/

export ANTSPATH=${ANTSpath}
export SUBJECTS_DIR=${FS_Dir}

#Check that all brains have been recon-all'ed in FreeSurfer
echo "Checking that all subjects have completed FreeSurfer recon-all process successfully..."
FS_Subject_Dir=`ls -d ${FS_Dir}/${FS_Subject}`
if [[ ! -e  ${FS_Subject_Dir}/mri/aseg.mgz ]] ; then
	echo "Error: ${FS_Subject} does not appear to have completed recon-all process successfully (missing mri/aseg.mgz file)"
	exit
fi

#Create register.dat if it does not already exist
if [[ ! -e ${FS_Subject_Dir}/register.dat ]] ; then
	echo "Creating register.dat for ${FS_Subject}"
	tkregister2 --mov ${FS_Subject_Dir}/mri/T1.mgz --noedit --s ${FS_Subject} --regheader --reg ${FS_Subject_Dir}/register.dat
fi

#Make labels2 directory if it doesn't already exist
if [[ ! -d ${FS_Subject_Dir}/labels2 ]] ; then
	echo "Creating ${FS_Subject_Dir}/labels2 for ${FS_Subject}"
	mkdir -p ${FS_Subject_Dir}/labels2
fi

#Make yeo_labels directory if it doesn't already exist
if [[ ! -d ${Subject_Dir}/freesurfer/yeo_labels/LIA_masks ]] ; then
	echo "Creating ${Subject_Dir}/freesurfer/yeo_labels"
	mkdir -p ${Subject_Dir}/freesurfer/yeo_labels
fi


for hemi in lh rh ; do
	Hemi=`echo ${hemi} | tr [a-z] [A-Z]`

	#Try to get network labels into native space
	mri_surf2surf --srcsubject fsaverage5 --trgsubject ${FS_Subject} --hemi ${hemi} --sval-annot /mnt/stressdevlab/scripts/Atlases/Yeo_JNeurophysiol11_SplitLabels/fsaverage5/label/${hemi}.Yeo2011_7Networks_N1000.split_components.annot --tval `dirname ${FS_Subject_Dir}`/${FS_Subject}/labels2/${hemi}.Yeo2011_7Networks_N1000.annot
	mri_surf2surf --srcsubject fsaverage5 --trgsubject ${FS_Subject} --hemi ${hemi} --sval-annot /mnt/stressdevlab/scripts/Atlases/Yeo_JNeurophysiol11_SplitLabels/fsaverage5/label/${hemi}.Yeo2011_17Networks_N1000.split_components.annot --tval `dirname ${FS_Subject_Dir}`/${FS_Subject}/labels2/${hemi}.Yeo2011_17Networks_N1000.annot

	#Convert annontations to individual labels
	mri_annotation2label --subject ${FS_Subject} --hemi ${hemi} --outdir ${FS_Subject_Dir}/labels2/${hemi}.Yeo2011_7Networks_N1000.split_components/ --annotation ${FS_Subject_Dir}/labels2/${hemi}.Yeo2011_7Networks_N1000.annot
	mri_annotation2label --subject ${FS_Subject} --hemi ${hemi} --outdir ${FS_Subject_Dir}/labels2/${hemi}.Yeo2011_17Networks_N1000.split_components/ --annotation ${FS_Subject_Dir}/labels2/${hemi}.Yeo2011_17Networks_N1000.annot


	#Make aseg-in-rawavg.mgz if doesn't already exist
	if [[ ! -f ${FS_Subject_Dir}/labels2/aseg-in-rawavg.mgz ]] ; then
		echo "Creating ${FS_Subject_Dir}/labels2/aseg-in-rawavg.mgz for ${Subject}_${Session}"
		mri_label2vol --seg ${FS_Subject_Dir}/mri/aseg.mgz --reg ${FS_Subject_Dir}/register.dat --o ${FS_Subject_Dir}/labels2/aseg-in-rawavg.mgz --temp ${FS_Subject_Dir}/mri/aseg.mgz
	fi

	for label in `ls ${FS_Subject_Dir}/labels2/${hemi}.Yeo2011_7Networks_N1000.split_components/*.label`; do
		roi_name=`basename ${label} .label`

		#Convert labels to volumes
		if [[ ! -f ${FS_Subject_Dir}/labels2/${roi_name}.mgz ]]; then
		mri_label2vol --label ${label} --temp ${FS_Subject_Dir}/labels2/aseg-in-rawavg.mgz --reg ${FS_Subject_Dir}/register.dat --proj frac 0 1 .1 --fillthresh 0.5 --hemi ${hemi} --subject ${FS_Subject} --o ${FS_Subject_Dir}/labels2/${roi_name}.mgz
		fi

		#Convert mgz volumes to NIFTI (LIA)
		if [[ ! -f ${Subject_Dir}/freesurfer/yeo_labels/${roi_name}.nii.gz ]]; then
			mri_convert ${FS_Subject_Dir}/labels2/${roi_name}.mgz ${Subject_Dir}/freesurfer/yeo_labels/${roi_name}.nii.gz
			fslreorient2std ${Subject_Dir}/freesurfer/yeo_labels/${roi_name}.nii.gz ${Subject_Dir}/freesurfer/yeo_labels/${roi_name}.nii.gz
		fi
	done

	for label in `ls ${FS_Subject_Dir}/labels2/${hemi}.Yeo2011_17Networks_N1000.split_components/*.label`; do
		roi_name=`basename ${label} .label`

		#Convert labels to volumes
		if [[ ! -f ${FS_Subject_Dir}/labels2/${roi_name}.mgz ]]; then
		mri_label2vol --label ${label} --temp ${FS_Subject_Dir}/labels2/aseg-in-rawavg.mgz --reg ${FS_Subject_Dir}/register.dat --proj frac 0 1 .1 --fillthresh 0.5 --hemi ${hemi} --subject ${FS_Subject} --o ${FS_Subject_Dir}/labels2/${roi_name}.mgz
		fi

		#Convert mgz volumes to NIFTI (LIA)
		if [[ ! -f ${Subject_Dir}/freesurfer/yeo_labels/${roi_name}.nii.gz ]]; then
			mri_convert ${FS_Subject_Dir}/labels2/${roi_name}.mgz ${Subject_Dir}/freesurfer/yeo_labels/${roi_name}.nii.gz
			fslreorient2std ${Subject_Dir}/freesurfer/yeo_labels/${roi_name}.nii.gz ${Subject_Dir}/freesurfer/yeo_labels/${roi_name}.nii.gz
		fi

	done

done
exit
