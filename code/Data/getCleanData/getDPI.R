####
if(Sys.info()["user"]=="janus829" | Sys.info()["user"]=="s7m"){
	source('~/Research/fdi_network/code/setup.R') }
####

############################
# Download file from INSCR site
polURL = 'http://siteresources.worldbank.org/INTRES/Resources/469232-1107449512766/DPI2012.dta'
polName = paste0(pathDataRaw, 'dpi.dta')
if(!file.exists(polName)) { download.file(polURL, polName) }

polData = read.dta(polName)
############################

############################
# Clean names
polData$countryname[polData$countryname=='Turk Cyprus']=NA
polData$countryname[polData$countryname=='PRC']='China'
polData$countryname[polData$countryname=='Dom. Rep.']='Dominican Republic'
polData$countryname[polData$countryname=='UAE']='United Arab Emirates'
polData$countryname[polData$countryname=='Cent. Af. Rep.']='Central African Republic'
polData$countryname[polData$countryname=='GDR']="Germany Democratic Republic"
polData$countryname[polData$countryname=='ROK']='Republic of Korea'
polData$countryname[polData$countryname=='PRK']='North Korea'
polData$countryname[polData$countryname=='Soviet Union']='USSR'
polData$countryname[polData$countryname=='S. Africa']='South Africa'
polData$countryname[polData$countryname=='Congo (DRC)']='Congo, Democratic Republic of'
polData$countryname[polData$countryname=='Yemen (AR)'] = 'Yemen Arab Republic'
polData$countryname[polData$countryname=='P. N. Guinea'] = 'Papua New Guinea'

# Add panel countrynames
polData$cname = cname(polData$countryname)

# Fix for Yemen and Yugoslavia
polData$cname[polData$countryname=='Yemen (PDR)'] = "S. YEMEN"
polData$cname[polData$countryname=='Yugoslavia'] = "SERBIA"

# Remove countries missing in cname
polData = polData[!is.na(polData$cname),]

# Add in country codes
polData$ccode = panel$ccode[match(polData$cname, panel$cname)]

# Create cyear variables
polData$cyear = paste0(polData$ccode, polData$year)
table(polData$cyear)[table(polData$cyear)>1]

# Clean up EXECRLC variable
polData = polData[,c('cyear','execrlc')]
polData$execrlc[polData$execrlc==0] = NA
polData$execrlc[polData$execrlc==-999] = NA
polData$execrlc[polData$execrlc==0] = NA

# Create binary party variables
polData$right = polData$execrlc
polData$right[polData$right %in% 2:3] = 0

polData$left = polData$execrlc
polData$left[polData$left %in% 1:2] = 0
polData$left[polData$left == 3] = 1

polData$left2=0
polData$left2[polData$execrlc==3] = 1
############################

############################
# Save
dpi = polData
save(dpi, file=paste0(pathDataBin, 'dpi.rda'))
############################