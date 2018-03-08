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
	print(outliers)
	nvols = int(subprocess.check_output(['fslval', rest_f, 'dim4']).strip('\n').strip(' '))

	combined = sorted([int(n) for n in set(outliers)])
	combined_plus_one = [int(n) + 1 for n in combined if (int(n)+1) < nvols]
	combined_plus_one_with_combined = sorted(set(combined + combined_plus_one))
	with file(idir + '/Rest_outlier_vols_with_vol_after.csv','w') as ofile:
	    for line in combined_plus_one_with_combined:
		ofile.write(str(line) + '\n')
	with file(idir + '/Rest_NumBadVols.txt','w') as ofile:
	    ofile.write(str(len(combined_plus_one_with_combined)) + '\n')
	print(combined_plus_one_with_combined)

	subprocess.check_call(['fslsplit', rest_f])
	outliers = combined_plus_one_with_combined

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

	with file(idir + '/Rest_outlier_vols_with_vol_after.csv','w') as ofile:
	    ofile.write('\n')
	with file(idir + '/Rest_NumBadVols.txt','w') as ofile:
	    ofile.write('0 ' + '\n')
	subprocess.check_call(['cp', rest_f, idir + '/Rest_scrubbed.nii.gz'])
