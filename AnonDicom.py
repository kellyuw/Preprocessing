#Details related to original script
'''
    DicomNoMeta.py
    For University Hospital in Krakow DICOMs
    Jan Witowski / Garage of Complexity
    Usage: DicomNoMeta.py <path>
    Anonymizes all personal data

		Relevant blog post: http://jwitowski.com/dicom-anonymization-meta-data-processing/
		Original code: https://gist.github.com/jwitos/a3572674217505db7788
'''

import dicom
import glob
import os, sys
from os.path import join, expanduser

if len(sys.argv)==1:
	print("Define path")
	sys.exit(0)

subject = sys.argv[1]
xnatsubject = str("BEIP_" + subject)
#os.chdir(dicomPath)
subjectDir = str("/mnt/stressdevlab/beip/subjects/" + subject)

for dicomPath in glob.glob(subjectDir + "/DICOM/*/*"):
	anonDicomPath = dicomPath.replace("DICOM","ANONDICOM")
	
	if not os.path.exists(anonDicomPath):
		print(anonDicomPath)
		os.makedirs(anonDicomPath)

	meta = str("Project: BEIP; Subject: " + xnatsubject + "; Session: " + xnatsubject)
	print meta

	for dFile in glob.glob(dicomPath + "/*"):
		anonDFile = dFile.replace("DICOM","ANONDICOM")
		print(anonDFile)

		df = dicom.read_file(dFile)

		df[0x0010, 0x0010].value = subject 	# patient's name
		df[0x0010, 0x0020].value = xnatsubject # patient's ID
		df[0x0010, 0x0030].value = "UNKNOWN" 	# patient's birth date
		df[0x0008, 0x1030].value = "BEIP" # project ID

		df.save_as(anonDFile)


