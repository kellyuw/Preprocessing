import os
import pandas as pd
import glob
import sys
import subprocess

def convert_to_list(df):
    if df.shape[0] > df.shape[1]:
        return list(df[0])
    else:
        return list(df.T[0])

ofile = str(sys.argv[1])
fd = str(sys.argv[2])
dvars = str(sys.argv[3])
rest_f = str(sys.argv[4])
nvols = int(subprocess.check_output(['fslval', rest_f, 'dim4']).strip('\n').strip(' '))

orig_outlier_vols = []
for s in [fd]:
    ifile = s
    print(ifile)
    if os.stat(ifile).st_size > 1:
	print(os.stat(ifile).st_size)
        orig_outlier_vols += convert_to_list(pd.read_csv(ifile, delim_whitespace=True, header = None))
        print(orig_outlier_vols)

for s in [dvars]:
    ifile = s
    if os.stat(ifile).st_size > 0:
        df = pd.read_csv(ifile, delim_whitespace = True, header = None)
        temp = df.sum(axis = 1)
        orig_outlier_vols += list(temp[temp > 0].index)

if len(orig_outlier_vols) > 0:
    orig_outliers_plus_one = [int(n) + 1 for n in orig_outlier_vols if (int(n)+1) < nvols]
	all_scrub_vols = sorted(set(orig_outlier_vols + orig_outliers_plus_one))
    df = pd.DataFrame(all_scrub_vols)
    print(df)

else:
    open(ofile, 'a').close()
