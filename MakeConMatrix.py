import pandas as pd

ifile = '/mnt/stressdevlab/fear_pipeline/Test/MakeConMatrix/FirstRun_Bins.fsf'

with open(ifile, 'r') as i:
    lines = i.readlines()

    con_lines = [x.split(' ') for x in lines if 'con_orig' in x and 'ncon_orig' not in x]
    all_vals = []

    for x in con_lines:
        val_loc = (x[1].split('orig')[1].strip(')').split('.'))
        val = x[2].strip('\n')
        all_vals += [[val_loc[0], val_loc[1], val]]

    con_names = [x.split(') ')[1].split('\n')[0].strip('"') for x in lines if 'conname_orig' in x]
    cons = {num:name for num, name in enumerate(con_names,1)}
    print(cons)

    ev_names = [x.split(') ')[1].split('\n')[0].strip('"') for x in lines if 'evtitle' in x]
    evs = {num:name for num, name in enumerate(ev_names,1)}
    print(evs)

con_df = pd.DataFrame.from_dict(cons, orient = 'index')
con_df.columns = ['ContrastName']
con_df.reset_index(inplace = True)
con_df['con_num'] = con_df['index'].apply(lambda x: str(x))

df = pd.DataFrame.from_records(all_vals)
df['con_num'] = df[0].apply(lambda x: str(x))
t = df.pivot('con_num', 1, 2).reset_index()
t.columns =  ['con_num'] + ev_names
f = t.merge(con_df, on = 'con_num')
f['ContrastNum'] = f['con_num'].apply(lambda x: int(x))

final_cols = ['ContrastNum','ContrastName'] + ev_names
final_df = f[final_cols]
final_df.sort_values('ContrastNum').to_csv(ifile.replace('.fsf', '_Contrast_Matrix.csv'), sep = ',', header = True, index = False)
