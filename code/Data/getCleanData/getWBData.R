####
if(Sys.info()["user"]=="janus829" | Sys.info()["user"]=="s7m"){
	source('~/Research/fdi_network/code/setup.R') }
####

############################
# Download WB data using WDI package

# File name to store data
fName = paste0(pathDataRaw, 'worldBankVars.csv')
wbVars = c(
	'NY.GDP.MKTP.KD', # GDP, constant 05 US
	'NY.GDP.PCAP.KD', # GDP per capita, constant 05 US
	'NY.GDP.MKTP.KD.ZG', # GDP growth
	'SP.POP.TOTL', # Population
	'BX.KLT.DINV.CD.WD', # Net FDI inflows, current US
	'NE.TRD.GNFS.ZS', # Trade/GDP
	'NE.IMP.GNFS.ZS', # Imports of goods and services (% of GDP)
	'BX.KLT.DINV.WD.GD.ZS', # Foreign direct investment, net inflows (% of GDP)
	'NE.EXP.GNFS.ZS', # Exports of goods and services (% of GDP)
	'DT.ODA.ODAT.GN.ZS' # Net ODA received (% of GNI)
	)

# Call WDI website
wbData = WDI(country='all', 
	indicator=wbVars, 
	start=1960, end=2014, extra=TRUE )
write.csv(wbData, file=fName)

# Change names
wbVarsClean = c('gdp', 'gdpCap', 'gdpGr', 'pop', 'fdi', 'tradeGDP', 'impGDP', 'fdiGDP', 'expGDP', 'aidGNI')
names(wbData)[4:(length(wbVars)+3)] = wbVarsClean
############################

############################
# Process WB data

# Create matching countrynames
wbData$cname = countrycode(wbData$iso2c, 'iso2c', 'country.name')

# Drop aggregated WB units
wbData = wbData[!is.na(wbData$cname),]

# Create country + year id
wbData$cnameYear = paste0(wbData$cname, wbData$year)

# Check duplicates
table(wbData$cnameYear)[table(wbData$cnameYear)>1]

# Add countrycodes
wbData$ccode = panel$ccode[match(wbData$cname, panel$cname)]

# Drop small islands mostly
wbData = wbData[!is.na(wbData$ccode),]

# Create ccode + year id
wbData$cyear = paste0(wbData$ccode, wbData$year)

# Check duplicates
table(wbData$cyear)[table(wbData$cyear)>1]
############################

############################
# Create logged version of vars
wbData$gdpLog = log(wbData$gdp)
wbData$gdpCapLog = log(wbData$gdpCap)
wbData$popLog = log(wbData$pop)
wbData$fdiLog = log( wbData$fdi + abs(min(wbData$fdi, na.rm=TRUE)) + 1 )
############################

############################
# Save
worldBank = wbData[,c('cyear', wbVarsClean, 'gdpLog', 'gdpCapLog', 'popLog', 'fdiLog')]
save(worldBank, file=paste0(pathDataBin, 'worldBank.rda'))
############################