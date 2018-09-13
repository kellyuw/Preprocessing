#!/bin/bash
#MakeOverlay.sh

Background=$1
Overlay=$2
Output=$3

if [[ `pwd` == *PING* ]]; then
  Subject=`echo ${Background} | awk -F "/" '{print $6}'`
else
  echo "Can't determine project directory"
  exit
fi

echo "BACKGROUND: ${Background}"
echo "OVERLAY: ${Overlay}"
echo "OUTPUT: ${Output}"

MHA=${Output}/`basename ${Overlay} .nii.gz`.mha
ConvertScalarImageToRGB 3 ${Overlay} ${MHA} none green


CogX=`fslstats ${Overlay} -C | awk -F " " '{print $1}'`
StartX=`awk "BEGIN {printf \"%.0f\n\", ${CogX}-5}"`
StopX=`awk "BEGIN {printf \"%.0f\n\", ${CogX}+5}"`

CogY=`fslstats ${Overlay} -C | awk -F " " '{print $2}'`
StartY=`awk "BEGIN {printf \"%.0f\n\", ${CogY}-5}"`
StopY=`awk "BEGIN {printf \"%.0f\n\", ${CogY}+5}"`

mkdir -p `dirname $Output`

CreateTiledMosaic -i ${Background} -r ${MHA} -a 0.5 -d 0 -f 0x1 -s [5,${StartX},${StopX}] -o ${Output}/`basename ${Overlay} .nii.gz`_1.png
CreateTiledMosaic -i ${Background} -r ${MHA} -a 0.5 -d 1 -f 0x1 -s [5,${StartY},${StopY}] -o ${Output}/`basename ${Overlay} .nii.gz`_2.png
montage ${Output}/`basename ${Overlay} .nii.gz`_1.png ${Output}/`basename ${Overlay} .nii.gz`_2.png -mode concatenate -tile x1 ${Output}/`basename ${Overlay} .nii.gz`.png
