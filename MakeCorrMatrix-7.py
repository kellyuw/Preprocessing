import glob as glob
import pandas as pd
import os, sys

subject_dir = sys.argv[1]
subject = str(subject_dir.split('/')[-1])
project_dir = os.path.dirname(subject_dir)

warped_roi_ts = glob.glob(subject_dir + '/rest/yeo_labels/*h.7Networks*.txt')
custom_roi_ts = glob.glob(subject_dir + '/rest/custom_labels/*.txt')


ordered_cols = ['LH_Cont_Cing',
'RH_Cont_Cing',
'LH_Cont_OFC',
'LH_Cont_PFCd',
'LH_Cont_PFCl',
'RH_Cont_PFCl',
'LH_Cont_PFCmp',
'RH_Cont_PFCmp',
'LH_Cont_PFCv',
'RH_Cont_PFCv',
'LH_Cont_Par',
'RH_Cont_Par',
'LH_Cont_Temp',
'RH_Cont_Temp',
'LH_Cont_pCun',
'RH_Cont_pCun',
'LH_Default_PCC',
'RH_Default_PCC',
'LH_Default_PFC',
'RH_Default_PFCm',
'RH_Default_PFCv',
'LH_Default_PHC',
'LH_Default_Par',
'RH_Default_Par',
'LH_Default_Temp',
'RH_Default_Temp',
'LH_DorsAttn_FEF',
'RH_DorsAttn_FEF',
'LH_DorsAttn_Post',
'RH_DorsAttn_Post',
'LH_DorsAttn_PrCv',
'RH_DorsAttn_PrCv',
'LH_Limbic_OFC',
'RH_Limbic_OFC',
'LH_Limbic_TempPole',
'RH_Limbic_TempPole',
'LH_SalVentAttn_FrOper',
'RH_SalVentAttn_FrOper',
'LH_SalVentAttn_Med',
'RH_SalVentAttn_Med',
'LH_SalVentAttn_PFCl',
'RH_SalVentAttn_PFCl',
'RH_SalVentAttn_PFCv',
'LH_SalVentAttn_ParOper',
'RH_SalVentAttn_PrC',
'LH_SalVentAttn_TempOcc',
'RH_SalVentAttn_TempOccPar',
'LH_Vis',
'RH_Vis',
'LH_SomMot',
'RH_SomMot']

if len(custom_roi_ts) > 0:
    warped_roi_ts += custom_roi_ts

ordered_cols += [os.path.basename(x).split('.txt')[0] for x in glob.glob(subject_dir + '/rest/custom_labels/*.txt')]

def get_roi_df(x):
    if x not in custom_roi_ts:
        print(x)
        print(len(x.split('_')))
        if len(os.path.basename(x).split('_')) == 4:
            yeo_type, roi_hemi, roi_network, roi_raw_region = os.path.basename(x).split('_')
            name = '_'.join([roi_hemi, roi_network, roi_raw_region.replace('.txt','')])
        elif len(os.path.basename(x).split('_')) == 3:
            yeo_type, roi_hemi, roi_network = os.path.basename(x).split('_')
            name = '_'.join([roi_hemi, roi_network.replace('.txt','')])
    else:
        name = os.path.basename(x).replace('.txt','')
    df = pd.read_csv(x, names = [name])
    return(df)

t = pd.concat([get_roi_df(x) for x in warped_roi_ts], axis = 1)
c = t[ordered_cols].corr(method = 'pearson', min_periods = 1)
ofile = subject_dir + '/' + str(sys.argv[2])
c.to_csv(ofile)
