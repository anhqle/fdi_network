####
if(Sys.info()["user"]=="janus829" | Sys.info()["user"]=="s7m"){
	source('~/Research/fdi_network/code/setup.R') }
####

############################
# Download file from INSCR site
polURL = 'http://www.systemicpeace.org/inscr/p4v2014.sav'
polName = paste0(pathDataRaw, 'polity14.sav')
if(!file.exists(polName)) { download.file(polURL, polName) }

polData = read.spss(polName, to.data.frame=TRUE)
############################

############################
# Process polity data

# Remove pre 1960 observations
polData = polData[polData$year >= 1960, ]

# Match country names with panel dataset
polData$country = char(polData$country) %>% trim()
polData$country[polData$country=='UAE']='United Arab Emirates'
polData$country[polData$country=='Congo Kinshasa']='Congo, Democratic Republic of'
polData$country[polData$country=='Germany East']="Germany Democratic Republic"

# Convert to matching countrycodes
polData$cname=cname(polData$country)

# Other country name fixes
polData$cname[polData$country=='Yemen South']="S. YEMEN"
polData$cname[polData$country=='Vietnam South']="S. VIETNAM"
polData[polData$country=='Yugoslavia', 'cname']='SERBIA'
polData[polData$country=='Czechoslovakia', 'cname']='CZECH REPUBLIC'
polData[polData$country=='Germany Democratic Republic', 'cname']="German Democratic Republic"
polData[polData$country=='South Sudan', 'cname']='SOUTH SUDAN'
  
# Construct id from year + name
polData$cnameYear=paste0(polData$cname, polData$year)

# Drop repeat country observations
polData$drop=0
polData[polData$scode=='ETH' & polData$year==1993, 'drop']=1
polData[polData$scode=='GMY' & polData$year==1990, 'drop']=1
polData[polData$scode=='YGS' & polData$year==1991, 'drop']=1
polData[polData$scode=='YGS' & polData$year==2006, 'drop']=1
polData[polData$scode=='SDN' & polData$year==2011, 'drop']=1
polData[polData$scode=='DRV' & polData$year==1976, 'drop']=1
polData[polData$scode=='YAR' & polData$year==1990, 'drop']=1
polData=polData[polData$drop==0,]; polData=polData[,1:(ncol(polData)-1)]

# Check for Dupes
names(table(polData$cnameYear)[table(polData$cnameYear)>1]) # Dupe check

# Adding in codes from panel
polData$ccode=panel$ccode[match(polData$cname,panel$cname)]
polData$cyear=paste(polData$ccode, polData$year, sep='')
table(polData$cyear)[table(polData$cyear)>1] # Dupe check
############################

############################
# Adjust scale of polity 2
polData$polity2 = polData$polity2 + 11
############################

############################
# Save cleaned polity data
polity=polData
save(polity, file=paste0(pathDataBin, 'polity.rda'))
############################