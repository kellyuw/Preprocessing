import pandas as pd
import sys

ifile = str(sys.argv[1])
ofile = ifile.replace('.par','12p.par')
df = pd.read_csv(ifile, delim_whitespace=True, header = None)
df2 = pd.DataFrame([0 for x in df.columns]).T
df3 = df.shift(periods = -1, axis = 0).fillna(0)

temp_deriv = pd.DataFrame()
for i in df.columns:
    temp_deriv[i] = df3[i] - df[i]
temp_deriv = pd.concat([df2,temp_deriv], axis = 0).reset_index(drop = True)
new_par = pd.concat([df, temp_deriv], axis = 1)
new_par.to_csv(ofile, header = False, index = False, sep = '\t')