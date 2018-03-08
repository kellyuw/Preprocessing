from collections import defaultdict
from xml.etree import cElementTree as ET
import csv
import pandas as pd
import sys
import os

def etree_to_dict(t):
	d = {t.tag: {} if t.attrib else None}
	children = list(t)
	if children:
		dd = defaultdict(list)
		for dc in map(etree_to_dict, children):
			for k, v in dc.iteritems():
				dd[k].append(v)
		d = {t.tag: {k:v[0] if len(v) == 1 else v for k, v in dd.iteritems()}}
	if t.attrib:
		d[t.tag].update(('@' + k, v) for k, v in t.attrib.iteritems())
	if t.text:
		text = t.text.strip()
		if children or t.attrib:
			if text:
			  d[t.tag]['#text'] = text
		else:
			d[t.tag] = text
	return d

def parse_block(v,bname):
	try:
		for j in v['subparameter']:
			fd[bname + ' '+ j['@name']] = j['@value']
	except TypeError:
		d[bname + ' ' + v['subparameter']['@name']] = v['subparameter']['@value']
		fd[v['subparameter']['@name']] = v['subparameter']['@value']
	if bname not in v['@name']:
		fd[bname + ' ' + v['@name']] = v['@value']
	else:
		fd[v['@name']] = v['@value']

#fname = '/mnt/stressdevlab/ExamCards/NARSAD/ExamCard_to_XML_201611282319411603321.xml'
fname = sys.argv[1]
tree = ET.parse(fname)
e = tree.getroot()
d = etree_to_dict(e)

def parse_card(p):
	for i in range(0,3):
		for v in p['group'][i]['parameter']:
			if 'subparameter' in v.keys():
				if 'FOV' in v['@name']:
					for j in v['subparameter']:
						fd['FOV ' + j['@name']] = j['@value']
						fd['FOV ' + v['@name'].split(' ')[-2] + ' (mm)'] = v['@value']
				elif 'Voxel size' in v['@name']:
					fd['Voxel size ' + v['subparameter']['@name']] = v['subparameter']['@value']
					fd['Voxel size ' + v['@name'].split(' ')[-2] + ' (mm)'] = v['@value']
				elif 'TR' in v['@name']:
					fd['Contrast TR (mm)' + v['subparameter']['@name']] = v['subparameter']['@value']
					fd['Contrast ' + v['@name'] + 'type'] = v['@value']
				elif 'TE' in v['@name']:
					fd['Contrast TE (mm)' + v['subparameter']['@name']] = v['subparameter']['@value']
					fd['Contrast ' + v['@name'] + 'type'] = v['@value']
				else:
					parse_block(v,v['@name'])
			else:
				fd[v['@name']] = v['@value']
	print_results(p['@id'],fd)


def print_results(name, results):
	print name
	ofile = os.path.dirname(fname) + '/ParsedExamCard.csv'
	if 'BlipA' in name:
		ofile.replace('.csv','BlipA.csv')
	elif 'BlipP' in name:
		ofile.replace('.csv','BlipP.csv')
	print name
	with open(ofile, 'wb') as csv_file:
		writer = csv.writer(csv_file)
		for key, value in sorted(results.items()):
		   writer.writerow([key, value])
		   #print key + ':' + value
	print_phase_encoding(ofile)


def print_phase_encoding(ifile):
	ofile = ifile.replace('.csv','_PhaseEncoding.txt')
	df = pd.read_csv(ifile, header = None)
	df.columns = ['Parameter','ParameterValue']
	df[df['Parameter'].str.contains('fat shift direction')]['ParameterValue'].to_csv(ofile, index = False, header = False)


for p in d['dump']['folder']['examcard']['protocol']:
	if 'DTI' in p['@id'] and 'B0' not in p['@id']:
		if 'BlipP' in p['@id']:
			fd = {}
			parse_card(p)
			print '**********'
			print p['@id']

