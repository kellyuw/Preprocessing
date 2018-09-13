#FindVolsToScrub.py
#Takes in data about all outlier volumes and produces output file of volumes to scrub (bad vol + vol after for each outlier volume)

import os, sys
import glob as glob
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
else:
	with file(idir + '/Rest_outlier_vols_with_vol_after.csv','w') as ofile:
		ofile.write(str('\n'))
