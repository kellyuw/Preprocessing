import pandas as pd
import os, sys

ifile = str(sys.argv[1])

if 'bptf' in ifile:
    ofile = '/'.join(ifile.split('/')[:-1] + ['Rest_mean_fd_clean.txt'])
else:
    ofile = '/'.join(ifile.split('/')[:-1] + ['Rest_mean_fd_raw.txt'])

if os.stat(ifile).st_size > 1:
    df = pd.read_csv(ifile, header = None)
    mean_fwd = df.mean(0)[0]

else:
    mean_fwd = 0

with file(ofile, 'w') as f:
    f.write(str(mean_fwd) + ' \n')
