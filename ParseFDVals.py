## Parses file with unthresholded FD values (from motion_outliers) based on specific threshold

import pandas as pd
import sys
import os

#Get file with unthresholded FD values (ifile) and threshold (e.g. 0.5, 1.0, 1.5)
ifile = str(sys.argv[1])
thresh = float(sys.argv[2])

#Make threshold more friendly for filename
safe_thresh = str(thresh).replace('.','pt')
suffix = str('_' + safe_thresh + '_num_outliers'  + '.txt')

#Get run name from unthresholded FD value filename
if 'ExtinctionRecall' in ifile:
	prefix = '_'.join(os.path.basename(ifile).split('_')[:3])
else:
	prefix = os.path.basename(ifile).split('_')[0]

#If bptf in file, then we should save output file differently (to avoid overwriting)
if 'bptf' not in ifile:
	outlier_vol_ofile = os.path.dirname(ifile) + '/' + prefix + '_fd_' + safe_thresh + '_outlier_vols.txt'
	num_outlier_vol_ofile = os.path.dirname(ifile) + '/' + prefix + '_fd_' + safe_thresh + '_num_outliers.txt'
else:
	outlier_vol_ofile = os.path.dirname(ifile) + '/' + prefix + '_bptf_fd_' + safe_thresh + '_outlier_vols.txt'
	num_outlier_vol_ofile = os.path.dirname(ifile) + '/' + prefix + '_bptf_fd_' + safe_thresh + '_num_outliers.txt'

print(prefix)
print(ifile)
print(outlier_vol_ofile)
print(num_outlier_vol_ofile)

#Read in raw/unthresholed fd values and filter to include only those >= threshold
df = pd.read_csv(ifile, header = None)
outliers = df[df[0] >= float(thresh)]
print(outliers)

#Calculate number of fd outliers
outlier_vols = list(outliers.index.values)
num_outliers = len(outlier_vols)

#Save number of fd outliers
with open(num_outlier_vol_ofile, 'w') as o:
	o.write(str(num_outliers) + '\n')

#Write out outlier volume numbers
if num_outliers > 0:
	with open(outlier_vol_ofile, 'w') as o:
		for i in range(num_outliers):
			o.write(str(outlier_vols[i]) + '\n')
else:
	with open(outlier_vol_ofile, 'w') as o:
		o.write(str(''))