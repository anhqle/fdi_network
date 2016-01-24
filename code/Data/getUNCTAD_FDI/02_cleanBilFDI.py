import numpy as np
import pandas as pd
import os


def read_fdi_excel(filename, sheetname):
    d = pd.read_excel(filename, sheetname=sheetname)
    if d.shape[1] > 13 or d.shape[0] > 100:
        return read_fdi_largecountry(filename, sheetname=sheetname)
    else:
        return read_fdi_smallcountry(filename, sheetname=sheetname)

def read_fdi_largecountry(filename, sheetname, drop_aggregate=True):
    d = pd.read_excel(filename, sheetname=sheetname, skiprows=4)
    d = d.fillna('')
    # Collapse the first 5 columns into the 6th
    d.insert(6, 'country', pd.Series(d.iloc[:, :5].sum(axis=1)))
    d.drop(d.columns[0:6], axis=1, inplace=True)  # Drop the first 5 columns
    # Reconvert blank to NaN
    d = d.applymap(lambda x: np.nan if x == "" else x)
    # Drop all the NaN, which used to be blank cells in the original
    d.dropna(inplace=True)
    d = d.replace('..', np.nan)

    c_aggregates = ["World", "Region / economy", "Developed economies",
                    "Europe", "European Union", "Other developed Europe",
                    "North America", "Other developed countries",
                    "Developing economies", "Africa", "North Africa",
                    "Other Africa", "Asia",
                    "East Asia", "South-East Asia", "South Asia", "West Asia",
                    "Latin America and the Caribbean", "South America",
                    "Central America", "Caribbean", "Oceania",
                    "Transition economies", "South-East Europe", "CIS",
                    "Unspecified",
                    ("Source:  UNCTAD FDI/TNC database, based on data"
                     " from Danmarks Nationalbank.Caribbean")]
    if drop_aggregate:
        d = d[~d['country'].isin(c_aggregates)]

    return d


def read_fdi_smallcountry(filename, sheetname, drop_aggregate=True):
    d = pd.read_excel(filename, sheetname=sheetname, skiprows=4)
    d = d.rename(columns={'Reporting economy': 'country'})
    d = d.dropna().replace('..', np.nan)

    c_aggregates = ["Other Africa"]
    if drop_aggregate:
        d = d[~d['country'].isin(c_aggregates)]
    return d

# Test
read_fdi_excel('/home/anh/Dropbox/fdi_network/Data/UNCTAD/AFG_fdi.xls',
               sheetname=1)
read_fdi_excel('/home/anh/Dropbox/fdi_network/Data/UNCTAD/CYP_fdi.xls',
               sheetname=0)

# Clean the bilateral FDI data for real
outflow_dir = '/home/anh/Dropbox/fdi_network/Data/UNCTAD_outflow/'
inflow_dir = '/home/anh/Dropbox/fdi_network/Data/UNCTAD_inflow/'

for dir in [outflow_dir, inflow_dir]:
    if not os.path.exists(dir):
        os.makedirs(dir)

old_dir = '/home/anh/Dropbox/fdi_network/Data/UNCTAD/'
for filename in os.listdir(old_dir):
    if filename.endswith('xls'):
        print "working on " + old_dir + filename

        new_filename = inflow_dir + filename.split(".")[0] + ".csv"
        read_fdi_excel(old_dir + filename, sheetname=0) \
            .to_csv(new_filename,
                    na_rep='NA', encoding='utf-8', index=False)

        new_filename = outflow_dir + filename.split(".")[0] + ".csv"
        read_fdi_excel(old_dir + filename, sheetname=1) \
            .to_csv(new_filename,
                    na_rep='NA', encoding='utf-8', index=False)
