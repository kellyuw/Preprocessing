#!/bin/bash

#Takes in prefix (full path to subject rest directory) as input
#Uses diff and fslselectvols to remove outlier volumes from the bptf image

prefix=$1
#prefix='/mnt/stressdevlab/fear_pipeline/session1/1001/rest'
ifile="${prefix}/RestVW_bptf.nii.gz"
ofile="${prefix}/RestVW_bptf_good_vols.nii.gz"
temp_ofile="${prefix}/RestVW_bptf_all_vols.txt"
outlier_vols_f="${prefix}/Rest_FinalMidVol_all_outliers_with_vol_after_0pt5.txt"

numvols=`fslnvols ${ifile}`
numvols_minus_one=`echo "${numvols}-1" | bc`

rm ${temp_ofile}; touch ${temp_ofile}
for i in `seq 0 ${numvols_minus_one}`; do
  echo ${i} >> ${temp_ofile}
done

good_vols=`diff -y --suppress-common-lines ${temp_ofile} ${outlier_vols_f} | awk -F " " '{print $1}'`
good_vols_list=`echo ${good_vols} | sed -e 's|\ |,|g'`

fslselectvols -i ${ifile} -o ${ofile} --vols="${good_vols_list}"
rm ${temp_ofile}
