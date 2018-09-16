import subprocess
import os, sys
import glob as glob
from operator import itemgetter
from itertools import groupby
import pandas as pd

rest_f = str(sys.argv[1])
outliers_f = str(sys.argv[2])
idir = os.path.dirname(rest_f)


if os.stat(outliers_f).st_size > 1:
	outliers = pd.read_csv(outliers_f, header = None)[0]
	nvols = int(subprocess.check_output(['fslval', rest_f, 'dim4']).strip('\n').strip(' '))

	subprocess.check_call(['fslsplit', rest_f])

	#Get lists of outlier sequences
	for k,g in groupby(enumerate(outliers), lambda (i,x):i-x):
	    o = map(itemgetter(1), g)
	    if o[-1] < (int(nvols)-1):
		last = 'vol' + str(o[-1]+1).zfill(4) + '.nii.gz'
	    else:
		last = 'vol' + str(o[-1]).zfill(4) + '.nii.gz'
	    print(last)
	    if o[0] != 0:
		first = 'vol' + str(o[0]-1).zfill(4) + '.nii.gz'
	    else:
		first = 'vol' + str(o[0]).zfill(4) + '.nii.gz'
	    for i in o:
		temp = 'vol' + str(i).zfill(4) + 'temp.nii.gz'
		interp_cmd = ['fslmaths',first,'-add',last,'-div',str(2),temp]
		print(interp_cmd)
		subprocess.check_call(interp_cmd)

	for i in outliers:
	    img = 'vol' + str(i).zfill(4) + '.nii.gz'
	    os.remove('vol' + str(i).zfill(4) + '.nii.gz')

	merge_cmd = ['fslmerge', '-a', idir + '/Rest_scrubbed.nii.gz'] + sorted([f for f in glob.glob('vol0[0-9]*.nii.gz')])
	print(merge_cmd)
	subprocess.check_call(merge_cmd)

	#Clean up
	for f in glob.glob('vol0[0-9]*.nii.gz'):
	    os.remove(f)
else:
	nvols = int(subprocess.check_output(['fslval', rest_f, 'dim4']).strip('\n').strip(' '))
	subprocess.check_call(['cp', rest_f, idir + '/Rest_scrubbed.nii.gz'])
