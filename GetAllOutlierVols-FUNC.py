import os
import pandas as pd
import glob
import sys
import argparse

def convert_to_list(df):
    if df.shape[0] > df.shape[1]:
        return list(df[0])
    else:
        return list(df.T[0])


parser = argparse.ArgumentParser()
parser.add_argument('--fd', '-f', required=False, type=str, help='FD file from fsl_motion_outliers')
parser.add_argument('--dvars', '-d', required=False, type=str, help='DVARS file from fsl_motion_outliers')
parser.add_argument('--sn', '-s', required=False, type=str, help='Signal noise outliers file from ibicIDSN')
parser.add_argument('--output', '-o', required=True, help='Full path to output file')

ifiles = []
cmdInput = parser.parse_args()
if cmdInput.fd:
    fd_file = cmdInput.fd
    ifiles += [fd_file]
if cmdInput.dvars:
    dvars_file = cmdInput.dvars
    ifiles += [dvars_file]
if cmdInput.sn:
    sn_file = cmdInput.sn
    ifiles += [sn_file]

outlier_vols = []
for ifile in ifiles:
    if ifile != dvars_file:
        if os.stat(ifile).st_size > 1:
            outlier_vols += convert_to_list(pd.read_csv(ifile, delim_whitespace=True, header = None))
    else:
        if os.stat(ifile).st_size > 0:
            df = pd.read_csv(ifile, delim_whitespace = True, header = None)
            temp = df.sum(axis = 1)
            outlier_vols += list(temp[temp > 0].index)

if len(outlier_vols) > 0:
    all_outlier_vols = pd.DataFrame(sorted(list(set(outlier_vols))))
    all_outlier_vols[0].to_csv(cmdInput.output, header = False, index = False)
else:
    open(cmdInput.output, 'a').close()
