import os
import pandas as pd
import glob
import sys
import subprocess

ofile = str(sys.argv[1])
fd_outliers_file = str(sys.argv[2])
dvars_spike_file = str(sys.argv[3])
rest_f = str(sys.argv[4])
rdir = os.path.dirname(rest_f)
nvols = int(subprocess.check_output(['fslval', rest_f, 'dim4']).strip('\n').strip(' '))

#Get DVARS outlier vols
dvars_single_point = pd.read_csv(dvars_spike_file, delim_whitespace = True, header = None)
orig_outlier_vols = []
temp = dvars_single_point.sum(axis = 1)
orig_outlier_vols += list(temp[temp > 0].index)

#Get FD outlier vols
with open(fd_outliers_file, 'r') as fd:
    fd_outliers = [x.strip('\n') for x in fd.readlines()]
orig_outlier_vols += [int(x) for x in fd_outliers]

if len(orig_outlier_vols) > 0:
    if 'rest' in fd_outliers_file:
        orig_outliers_plus_one = [int(n) + 1 for n in orig_outlier_vols if (int(n)+1) < nvols]
        all_scrub_vols = sorted(set(orig_outlier_vols + orig_outliers_plus_one))
    else:
        all_scrub_vols = sorted(set(orig_outlier_vols))
    df = pd.DataFrame(all_scrub_vols)
    df.to_csv(ofile, index  = False, header = False)
else:
    open(ofile, 'a').close()
