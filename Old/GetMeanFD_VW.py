import pandas as pd
import os, sys

ifile = str(sys.argv[1])

if 'bptf' in ifile:
    ofile = '/'.join(ifile.split('/')[:-1] + ['RestVW_mean_fd_clean.txt'])
# non-VW version of this code has a raw/clean 2 versions. VW version uses same raw file; this just re-computes the clean

if os.stat(ifile).st_size > 1:
    df = pd.read_csv(ifile, header = None)
    mean_fwd = df.mean(0)[0]

else:
    mean_fwd = 0

with file(ofile, 'w') as f:
    f.write(str(mean_fwd) + ' \n')
