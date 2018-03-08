import os
import pandas as pd
import glob
import sys

def convert_to_list(df):
    if df.shape[0] > df.shape[1]:
        return list(df[0])
    else:
        return list(df.T[0])

ofile = str(sys.argv[1])
prefix = ofile.split('all_outliers')[0]

outlier_vols = []
for s in ['fd_1pt0_outlier_vols.txt', 'SN_outliers.txt']:
    ifile = prefix + s
    print(ifile)
    if os.stat(ifile).st_size > 1:
	print(os.stat(ifile).st_size)
        outlier_vols += convert_to_list(pd.read_csv(ifile, delim_whitespace=True, header = None))

for s in ['dvars_spike_vols']:
    ifile = prefix + s
    if os.stat(ifile).st_size > 0:
        df = pd.read_csv(ifile, delim_whitespace = True, header = None)
        temp = df.sum(axis = 1)
        outlier_vols += list(temp[temp > 0].index)

if len(outlier_vols) > 0:
    all_outlier_vols = pd.DataFrame(sorted(list(set(outlier_vols))))
    all_outlier_vols[0].to_csv(ofile, header = False, index = False)
else:
    open(ofile, 'a').close()
