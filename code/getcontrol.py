# -*- coding: utf-8 -*-
"""
Created on Thu Oct  1 01:36:03 2015

@author: anh
"""
import pandas as pd
from pandas.io import wb

d = pd.read_csv('/home/anh/Dropbox/fdi_network/Data/dyads.csv')

d2 = wb.download(indicator='NY.GDP.PCAP.KD', country=['US', 'CA', 'MX'],
                 start=2005, end=2008)

print(d2)

%matplotlib inline                                                                      
%reset -f