#!/bin/bash -x

QAType=$1
firstImage=$2
secondImage=$3
resultImage=$4
pngImage="`dirname ${resultImage}`/`basename ${resultImage} .gif`.png"
niftiImage="`dirname ${resultImage}`/`basename ${resultImage} .gif`.nii.gz"

#Make sure directory of resultImage exists
mkdir -p `dirname ${resultImage}`

#Make random directory
tempDir=`mktemp -d /tmp/MakeSlicerQA-XXXXX`
echo ${tempDir}
cp ${firstImage} ${tempDir}/
cp ${secondImage} ${tempDir}/

#slices
if [[ ${QAType} == *s* ]] || [[ ${QAType} == *S* ]]; then
    s1="-x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png"
    s2="sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png"
	# Make intermediate1.png
	/usr/share/fsl/5.0/bin/slicer ${firstImage} ${secondImage} -s 2 ${s1} -l ${FSLDIR}/etc/luts/renderhot.lut
	pngappend ${s2} intermediate1.png

	#Make intermediate2.png
	/usr/share/fsl/5.0/bin/slicer ${secondImage} ${firstImage} -s 2 ${s1} -l ${FSLDIR}/etc/luts/renderhot.lut
	pngappend ${s2} intermediate2.png


	#Make pngImage
	pngappend intermediate1.png - intermediate2.png ${pngImage}

	rm sl?.png intermediate?.png

elif [[ ${QAType} == *o* ]] || [[ ${QAType} == *o* ]]; then
	/usr/share/fsl/5.0/bin/overlay 1 1 ${firstImage} -a ${secondImage} 1 10 ${tempDir}/rendered_`basename ${niftiImage}`
	/mnt/stressdevlab/scripts/Preprocessing/slices ${tempDir}/rendered_`basename ${niftiImage}` -o ${pngImage}
	convert ${pngImage} ${resultImage}
fi


loc=`pwd`
if [[ ${loc} == *DTI* ]]; then
	mv ${tempDir}/intermediate2.png ${pngImage}
fi

#Convert pngImage to resultImage
convert ${pngImage} ${resultImage}

#Remove tempDir and pngImage
if [[ -d ${tempDir} ]]; then
	rm -r ${tempDir}
fi
rm ${pngImage}

