import pandas as pd
import matplotlib
import sys
import os
from ggplot import *

f = str(sys.argv[1])
task_dir = os.path.dirname(f)
subject = task_dir.split('/')[-2]
task = task_dir.split('/')[-1]
metric = f.split('_vals')[0].split('_')[-1]
run = os.path.basename(f).split(metric)[0][:-1]
title = '/'.join(task_dir.split('/')[:-3] + ['session1',str(subject),'QA',task] + [os.path.basename(f) + '.png'])
print(title)

if 'fd' in metric:
    max_y = 3
    title = title.replace('fd', 'framewise displacement')
elif 'dvars' in metric:
    max_y = 50


df = pd.read_csv(f)
df.columns = ['value']
df['volume'] = df.index.values
df['threshold'] = 1.5
df2 = pd.melt(df[['volume', 'value', 'threshold']], id_vars = ['volume'])
p = ggplot(df2, aes(x = 'volume', y = 'value', color = 'variable')) + geom_line(size = 4) + ggtitle (title) + labs(x = 'volume', y = 'value') + ylim(0,max_y)
p.save(str(title.replace(' ','_')))
quit()


