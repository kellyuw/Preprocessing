import glob as glob
import pandas as pd
import os, sys

subject_dir = sys.argv[1]
subject = str(subject_dir.split('/')[-1])
project_dir = os.path.dirname(subject_dir)

warped_roi_ts = glob.glob(subject_dir + '/rest/yeo_labels/*h.17Networks*.txt')
custom_roi_ts = glob.glob(subject_dir + '/rest/custom_labels/*.txt')


ordered_cols = ['LH_ContA_Cinga',
'RH_ContA_Cinga',
'LH_ContA_IPS',
'RH_ContA_IPS',
'RH_ContA_PFCd',
'LH_ContA_PFCd',
'LH_ContA_PFCl',
'RH_ContA_PFCl',
'LH_ContA_PFClv',
'RH_ContA_Temp',
'LH_ContA_Temp',
'LH_ContB_IPL',
'RH_ContB_IPL',
'LH_ContB_PFCd',
'LH_ContB_PFCl',
'RH_ContB_PFCld',
'LH_ContB_PFClv',
'RH_ContB_PFClv',
'LH_ContB_PFCmp',
'RH_ContB_PFCmp',
'LH_ContB_Temp',
'RH_ContB_Temp',
'LH_ContC_Cingp',
'RH_ContC_Cingp',
'RH_ContC_pCun',
'LH_ContC_pCun',
'LH_DefaultA_IPL',
'RH_DefaultA_IPL',
'RH_DefaultA_PCC',
'LH_DefaultA_PCC',
'LH_DefaultA_PFCd',
'RH_DefaultA_PFCd',
'RH_DefaultA_PFCm',
'LH_DefaultA_PFCm',
'RH_DefaultA_Temp',
'RH_DefaultB_AntTemp',
'LH_DefaultB_IPL',
'RH_DefaultB_PFCd',
'LH_DefaultB_PFCd',
'LH_DefaultB_PFCl',
'RH_DefaultB_PFCv',
'LH_DefaultB_PFCv',
'LH_DefaultB_Temp',
'RH_DefaultB_Temp',
'RH_DefaultC_IPL',
'LH_DefaultC_IPL',
'LH_DefaultC_PHC',
'RH_DefaultC_PHC',
'LH_DefaultC_Rsp',
'RH_DefaultC_Rsp',
'RH_DorsAttnA_ParOcc',
'LH_DorsAttnA_ParOcc',
'LH_DorsAttnA_SPL',
'RH_DorsAttnA_SPL',
'RH_DorsAttnA_TempOcc',
'LH_DorsAttnA_TempOcc',
'LH_DorsAttnB_FEF',
'RH_DorsAttnB_FEF',
'RH_DorsAttnB_PostC',
'LH_DorsAttnB_PostC',
'RH_DorsAttnB_PrCv',
'LH_DorsAttnB_PrCv',
'LH_DorsAttnB_TempOcc',
'RH_DorsAttnB_TempOcc',
'RH_Limbic_OFC',
'LH_Limbic_OFC',
'LH_Limbic_TempPole',
'RH_Limbic_TempPole',
'RH_SalVentAttnA_FrMed',
'LH_SalVentAttnA_FrMed',
'RH_SalVentAttnA_Ins',
'LH_SalVentAttnA_Ins',
'RH_SalVentAttnA_ParMed',
'LH_SalVentAttnA_ParMed',
'LH_SalVentAttnA_ParOper',
'RH_SalVentAttnA_ParOper',
'RH_SalVentAttnA_PrC',
'LH_SalVentAttnA_PrCv',
'RH_SalVentAttnA_PrCv',
'RH_SalVentAttnB_Cinga',
'LH_SalVentAttnB_IPL',
'RH_SalVentAttnB_IPL',
'LH_SalVentAttnB_OFC',
'RH_SalVentAttnB_PFCd',
'LH_SalVentAttnB_PFCd',
'LH_SalVentAttnB_PFCl',
'RH_SalVentAttnB_PFCl',
'RH_SalVentAttnB_PFClv',
'LH_SalVentAttnB_PFCmp',
'RH_SalVentAttnB_PFCmp',
'LH_SalVentAttnB_PFCv',
'RH_SalVentAttnB_PFCv',
'LH_SomMotA',
'RH_SomMotA',
'RH_SomMotB_Aud',
'LH_SomMotB_Aud',
'LH_SomMotB_Cent',
'RH_SomMotB_Cent',
'RH_SomMotB_Ins',
'LH_SomMotB_Ins',
'RH_SomMotB_S2',
'LH_SomMotB_S2',
'RH_TempPar',
'LH_TempPar',
'RH_VisCent_ExStr',
'LH_VisCent_ExStr',
'LH_VisCent_Striate',
'LH_VisPeri_ExStrInf',
'RH_VisPeri_ExStrInf',
'RH_VisPeri_ExStrSup',
'LH_VisPeri_ExStrSup',
'LH_VisPeri_Striate',
'RH_VisPeri_Striate']

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
