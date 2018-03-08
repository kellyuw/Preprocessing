import subprocess
import os, sys

#Different source
#https://webcache.googleusercontent.com/search?q=cache:gVRbKOOCtYEJ:https://www.jiscmail.ac.uk/cgi-bin/webadmin%3FA2%3Dfsl%3B9ffadc97.1109+&cd=1&hl=en&ct=clnk&gl=us

ifile = str(sys.argv[1])
ofile = '/'.join(ifile.split('/')[:-2]) + '/rest/Rest_bptf.nii.gz'
print(ifile)
print(ofile)
tr = subprocess.check_output(['fslval', ifile, 'pixdim4'])
#sigma[vol] = filter_width[secs]/(2*TR[secs])
#https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=FSL;bad22e29.1709

lp_sigma = (1/0.01)/(float(2.00) * float(tr))
hp_sigma = (1/0.08)/(float(2.00) * float(tr))

print('** RestingState-bptf.py **')
print(tr)
print(lp_sigma, hp_sigma)

x = subprocess.check_call(['fslmaths', ifile, '-Tmean', ofile.replace('bptf','Tmean')])
y = subprocess.check_call(['fslmaths', ifile, '-bptf', str(hp_sigma), str(lp_sigma), ofile])
z = subprocess.check_call(['fslmaths', ofile, '-add', ofile.replace('bptf','Tmean'), ofile])
