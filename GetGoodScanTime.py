import sys

subject_dir = str(sys.argv[1])

vals = {}
for f in ['NumVols','TR','NumBadVols']:
    with file(subject_dir + '/rest/Rest_' + f + '.txt', 'r') as ifile:
        vals.update({(f, float(ifile.readlines()[0].strip('\n')))})
TotalGoodTimeInSec = ((vals['NumVols'] - vals['NumBadVols']) * vals['TR'])
with file(subject_dir + '/rest/Rest_TotalGoodScanTimeInSec.txt', 'w') as ofile:
    ofile.write(str(TotalGoodTimeInSec) + ' \n')
