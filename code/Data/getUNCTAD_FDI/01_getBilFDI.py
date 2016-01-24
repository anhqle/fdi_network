import urllib2
import os
import BeautifulSoup
import csv
import time

# Helpful functions
def openSoup(x):
	"""Opens URL and create soup"""
	return BeautifulSoup.BeautifulSoup(urllib2.urlopen(x).read())

def interPull(x, a, b, adj=None):
	"""Returns the text between strings a and b"""
	if adj is None: 
		adj=len(a)
	return x[x.find(a)+adj:x.find(b)]

# Load in base webpage
base = 'http://unctad.org/en/Pages/DIAE/FDI%20Statistics/FDI-Statistics-Bilateral.aspx'
soup = openSoup(base)

# Extract xls urls
urlText = soup.findAll('select', {'id':'FDIcountriesxls'})

# Parse and organize xls urls
cntries=[]
urls=[]
for ii in urlText[0]:
	if isinstance(ii, BeautifulSoup.Tag):
		urls.append( ii.get('value') )
		cntries.append(  ii.text )

# Download excel files to directory
os.chdir('/Users/janus829/Dropbox/Research/fdi_network/Data/UNCTAD')
base = 'http://unctad.org/'
for ii in range(len(urls))[1:len(cntries)]:
	xlsURL = base + urls[ii]
	xlsName = interPull(urls[ii], '4d3_', '.xls') + '_fdi.xls'
	file(xlsName, 'wb').write(urllib2.urlopen(xlsURL).read())
	time.sleep(2) 