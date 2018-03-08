import pandas as pd
import sys

infile = sys.argv[1]
df = pd.read_csv(infile, sep = '\t')
df.T.to_csv(infile + '.T', header = False, index = True)