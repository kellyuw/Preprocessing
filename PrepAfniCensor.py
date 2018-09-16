import pandas as pd
import glob as glob
import sys

ifile = sys.argv[1]
num_vols = int(sys.argv[2])
try:
    df = pd.read_csv(ifile, header = None)

    all_vals = []
    for x in range(num_vols):
        if x in df[0].values:
            all_vals += [0]
        else:
            all_vals += [1]
except pd.io.common.EmptyDataError:
    all_vals = [1 for x in range(num_vols)]

final_df = pd.DataFrame(all_vals)
final_df.to_csv(ifile.replace('.txt','.1D'), header = False, index = False)
