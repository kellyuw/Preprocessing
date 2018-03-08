import pandas as pd
import glob as glob
import sys

f = sys.argv[1]
pct_thresh = sys.argv[2]
cln_thresh = str(pct_thresh).replace('.','pt')

scaled_pct_thresh = float(pct_thresh) / 100.00
high = 1 + scaled_pct_thresh
low = 1 - scaled_pct_thresh
print(high)
print(low)

#f = '/mnt/stressdevlab/PING/RestingState/P0099/rest/Rest_standardized_dvars.txt'
df = pd.read_csv(f, header = None, delim_whitespace = True)
outliers = df[(df[df.columns[2]] > high) | (df[df.columns[2]] < low)]
outliers.reset_index(inplace = True)
outliers[['index']].to_csv(f.replace('standardized_dvars.txt','dvars_outlier_vols_' + cln_thresh + '.txt'), index = False, header = False)
