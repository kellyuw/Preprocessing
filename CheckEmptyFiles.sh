#!/bin/bash -X

FSF=$1
EVFiles=`cat ${FSF} | grep custom | awk -F " " '{print $3}' | sed 's|"||g'`
echo "EVNum,EVName" > `dirname ${FSF}`/`basename ${FSF} .fsf | awk -F "." '{print $1}'`_EmptyEVFiles.txt
echo "EVNum,EVName" > `dirname ${FSF}`/`basename ${FSF} .fsf | awk -F "." '{print $1}'`_NonEmptyEVFiles.txt


for EV in ${EVFiles}; do
	EVNum=`cat ${FSF} | grep ${EV} | awk -F " " '{print $2}' | grep -o '[0-9]*'`
	EVFullName=`basename ${EV}`
	EVName=`echo ${EVFullName} | awk -F "." '{print $1}'`
	echo ${EVName}

	if [[ ${EV} == *txt* ]]; then
		EmptyEV=`echo ${EV} | sed 's|\.txt|-EMPTY\.txt|g'`
	else
		EmptyEV=`echo ${EV} | sed 's|\.csv|-EMPTY\.csv|g'`
	fi

	if [[ ! -s ${EV} ]]; then
		echo "Found new EmptyEV ${EV}"
		touch ${EmptyEV}
	fi

	if [[ -f ${EmptyEV} ]] ||  [[ ! -f ${EV} ]]; then
		sed "s|set\ fmri(shape${EVNum})\ 3|set\ fmri(shape${EVNum})\ 10|g" ${FSF} > ${FSF}.Temp
		mv ${FSF}.Temp ${FSF}
		echo "${EVNum},${EVName}" >> `dirname ${FSF}`/`basename ${FSF} .fsf | awk -F "." '{print $1}'`_EmptyEVFiles.txt
	else
		echo "${EVNum},${EVName}" >> `dirname ${FSF}`/`basename ${FSF} .fsf | awk -F "." '{print $1}'`_NonEmptyEVFiles.txt
	fi

done
