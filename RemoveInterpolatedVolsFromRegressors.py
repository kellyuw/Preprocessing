#Combines csf, wm, gs, and mc parameters (all with temp derivs) to make RestVW_nuisance_regressors.txt
#Additionally, removes rows from RestVW_nuisance_regressors.txt that are associated with scrubbed volumes to create RestVW_nuisance_regressors_clean.txt
#Takes in as input: prefix (full path to subject rest directory)

import pandas as pd
import sys, os
import glob as glob


#prefix = '/mnt/stressdevlab/fear_pipeline/1001/session1/rest/'
prefix = str(sys.argv[1])

csf_f = prefix + '/RestVW_csf_with_temp_deriv.txt'
wm_f = prefix + '/RestVW_wm_with_temp_deriv.txt'
gs_f = prefix + '/RestVW_gs_with_temp_deriv.txt'
mc_f = prefix + '/RestVW_mc_with_temp_deriv.txt'
nvols_f = prefix + '/Rest_NumVols.txt'
outlier_vols_f = prefix + '/Rest_FinalMidVol_all_outliers_with_vol_after_0pt5.txt'
all_reg_f = prefix + '/RestVW_nuisance_regressors.txt'
good_reg_f = prefix + '/RestVW_nuisance_regressors_clean.txt'

outlier_vols = pd.read_csv(outlier_vols_f, header = None)[0]
nvols = pd.read_csv(nvols_f, header = None).values[0]
print(outlier_vols)
print(nvols)

all_reg = pd.concat([pd.read_csv(x, sep = '\t', header = None) for x in [csf_f,wm_f,gs_f,mc_f]], axis = 1)
all_reg.to_csv(all_reg_f, sep = '\t', header = None, index = False)
good_reg = all_reg.ix[[i for i in range(nvols) if i not in outlier_vols]]
good_reg.to_csv(good_reg_f, sep = '\t', header = None, index = False)
