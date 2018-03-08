import pandas as pd
import sys

ifile = str(sys.argv[1])

if 'par' in ifile:
    ofile = ifile.replace('.par','_with_temp_deriv.txt')
elif 'txt' in ifile:
    ofile = ifile.replace('.txt','_with_temp_deriv.txt')
df = pd.read_csv(ifile, delim_whitespace=True, header = None)
df = df.dropna(how = 'any', axis = 0)
df2 = pd.DataFrame([0 for x in df.columns]).T
df3 = df.shift(periods = -1, axis = 0).fillna(0)
df3.reset_index(drop = True, inplace = True)

temp_deriv = pd.DataFrame()
for i in df.columns:
    temp_deriv[i] = df3[i] - df[i]

temp_deriv = pd.concat([df2,temp_deriv], axis = 0).reset_index(drop = True)
new_par = pd.concat([df, temp_deriv], axis = 1)
new_par.drop(new_par.index[len(new_par)-1], inplace = True)
new_par.to_csv(ofile, header = False, index = False, sep = '\t',float_format='%.6f')
