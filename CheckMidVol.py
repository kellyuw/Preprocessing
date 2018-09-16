#CheckMidVol.py
#Checks original MidVol to determine if it is usable (i.e. not an outlier); picks new mid vol if not

import pandas as pd
import glob as glob
import os, sys

orig_mid_file = str(sys.argv[1])
final_mid_file = orig_mid_file.replace('Orig','Final')
if os.path.exists(orig_mid_file):
    with open(orig_mid_file, 'r') as orig_mid:
        orig_mid_vol = orig_mid.read().strip()
    outlier_vols_file = str(sys.argv[2])
    with open(outlier_vols_file, 'r') as outlier_vols:
        bad_vols = set([x.strip() for x in outlier_vols.readlines()])
    check_overlap = set([orig_mid_vol]).issubset(bad_vols)
    if check_overlap:
        new_mid_vol = str(int(orig_mid_vol) + 1)
        while set([new_mid_vol]).issubset(bad_vols):
            new_mid_vol = str(int(new_mid_vol) + 1)
    else:
        new_mid_vol = orig_mid_vol
    with open(final_mid_file, 'w') as ofile:
        ofile.write(new_mid_vol + '\n')
