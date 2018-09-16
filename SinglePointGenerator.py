import os
import numpy as np
import pandas as pd
import argparse

#Pull the data in based on a parameter entered at the command line
parser = argparse.ArgumentParser()
parser.add_argument('--input', '-i', required=True, help='File containing list of outliers')
parser.add_argument('--vols', '-v', required=True, help='Number of volumes in timeseries')
parser.add_argument('--output', '-o', required=True, help='Name of output file matrix')
parser.add_argument('--outputpercent', '-p', required=True, help='Name of output file for percent of volumes')

args = parser.parse_args()

ifile = str(args.input)
vols = int(args.vols)
output = str(args.output)
outputpercent = str(args.outputpercent)


if os.stat(ifile).st_size > 0:
    try:
        df = pd.read_csv(ifile, header = None, delim_whitespace=True)
        badvols = list(df[0])
        cols = len(badvols)
        rows = vols
        singlepointmat = np.zeros((rows, cols))

        for i,j in enumerate(badvols):
            singlepointmat[j-1,i] = 1
    	np.savetxt(output,singlepointmat,fmt='%d',delimiter='\t',newline='\n')
    except pd.io.common.EmptyDataError:
        cols = 0
        rows = int(vols)
        open(output, 'a').close()

else:
    cols = 0
    rows = int(vols)
    open(output, 'a').close()


percent=(float(cols)/float(rows))*100
print 'Excluding ' + str(percent) + '% of volumes'
with open(str(outputpercent),'w') as f:
    f.write(str(percent))
