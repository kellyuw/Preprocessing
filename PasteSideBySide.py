import pandas as pd
import sys

file1 = sys.argv[1]
file2 = sys.argv[2]
ofile = sys.argv[3]

df1 = pd.read_csv(file1, delim_whitespace = True, header = None)
df2 = pd.read_csv(file2, delim_whitespace = True, header = None)
of = pd.concat([df1,df2], axis=1)

of.to_csv(ofile, sep = ' ', index = False, header = False)