import pandas as pd
import os, sys
import subprocess
import shutil
from nipype.interfaces.fsl import Merge
from nipype.interfaces.fsl import Split

subject_dir = str(sys.argv[1])
outlier_vols_file = str(sys.argv[2])
bptf = subject_dir + '/rest/RestVW_bptf.nii.gz'
ofile = bptf.replace('bptf','bptf_good_vols')


def wait10():
	wproc = subprocess.Popen(['sleep','10'])
	wproc.wait()

if os.stat(outlier_vols_file).st_size > 1:
	os.chdir(subject_dir)
	df = pd.read_csv(outlier_vols_file, header = None)
	outlier_vols = [x for x in df[0]]

	nvols = int(subprocess.check_output(['cat', subject_dir + '/rest/Rest_NumVols.txt']).strip('\n').strip(' ').split('.')[0])
	tr = int(subprocess.check_output(['cat', subject_dir + '/rest/Rest_TR.txt']).strip('\n').strip(' ').split('.')[0])
	print(nvols, tr)
	print(len(outlier_vols))
	print('Length outliers: ' + str(len(outlier_vols)))

	proc = subprocess.Popen(['fslsplit',str(bptf)])
	proc.wait()

	s = []
	for i in range(nvols):
		if i not in outlier_vols:
			s += ['vol' + str(i).zfill(4) + '.nii.gz']

	merger = Merge()
	merger.inputs.in_files = s
	merger.inputs.dimension = 't'
	merger.inputs.tr = tr
	merger.run()
	wait10()

	for j in s:
		os.remove(j)

	temp_ofile = os.path.join(subject_dir,s[0].replace('.nii.gz','_merged.nii.gz'))

	if os.path.exists(temp_ofile):
		os.rename(temp_ofile, 'RestVW_bptf_good_vols.nii.gz')

