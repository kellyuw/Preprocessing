#!/bin/bash

iFile=$1
oFile=$2
sliceInterval=$3

echo Input File: $iFile Output File: $oFile

rm -rf kTempImages; mkdir kTempImages

for direction in x y z; do

	#Set vars
	if [ $direction	== x ]; then
		numSlices=`fslval $iFile dim1`
	elif [ $direction == y ]; then
		numSlices=`fslval $iFile dim2`
	elif [ $direction == z ]; then
		numSlices=`fslval $iFile dim3`
	fi

	if [[ ${numSlices} == "1" ]] ; then
		sliceMin=1
		sliceMax=$(printf %0.f $(echo $numSlices))
		makeAll="Yes"
	else
		sliceMin=$(printf %0.f $(echo "$numSlices*0.15" | bc))
		sliceMax=$(printf %0.f $(echo "$numSlices-$sliceMin" | bc))
		makeAll="No"
	fi

	echo Number of Slices = $numSlices Direction = $direction

	echo Making images in $direction direction ...
	for i in `seq $sliceMin $sliceInterval $sliceMax`; do

		formattedI=`printf %03.f $i`
		/usr/share/fsl/5.0/bin/slicer $iFile -${direction} -${i} kTempImages/ksl${formattedI}"_"${direction}.png				
	done

	if [[ ${makeAll} == "No" ]] ; then
		montage kTempImages/ksl*${direction}.png -geometry +0+0 -background black ${oFile}"_"${direction}.png
	fi

done

#remove other images
if [[ ${makeAll} == "No" ]] ; then
		rm -rf kTempImages
else
	mkdir -p `dirname ${oFile}`/AllImages
	mv kTempImages `dirname ${oFile}`/AllImages
fi
