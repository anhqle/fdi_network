####
if(Sys.info()["user"]=="janus829" | Sys.info()["user"]=="s7m"){
	source('~/Research/fdi_network/code/setup.R') }
####

############################
# Download file from ICOW site
gwfURL = 'http://sites.psu.edu/dictators/wp-content/uploads/sites/12570/2015/04/GWF-Autocratic-Regimes-1.2.zip'
gwfName = paste0(pathDataRaw, 'gwf.zip')
if(!file.exists(gwfName)) { download.file(gwfURL, gwfName) }

gwf = unzip(gwfName, 'GWF Autocratic Regimes 1.2/GWF_AllPoliticalRegimes.dta') %>% read.dta()
unlink(paste0(getwd(), '/GWF Autocratic Regimes 1.2'), 
	force=TRUE, recursive=TRUE)
############################

############################
# Process gwf data

# Clean up gwf_country names
gwf$gwf_country[gwf$gwf_country=='Luxemburg'] = 'Luxembourg'
gwf$gwf_country[gwf$gwf_country=='Soviet Union'] = 'Russia'
gwf$gwf_country[gwf$gwf_country=='Congo/Zaire']='Congo, Democratic Republic of'
gwf$gwf_country[gwf$gwf_country=='UAE'] = 'United Arab Emirates'

# Use countrycode to get matching countrynames
gwf$cname = cname(gwf$gwf_country)

# Clean up matched countrynames
gwf$cname[gwf$gwf_country=='Germany East'] = 'German Democratic Republic'
gwf$cname[gwf$cname=='Czechoslovakia'] = 'CZECH REPUBLIC'
gwf$cname[gwf$cname=='Yugoslavia'] = 'SERBIA'

# Bring in ccodes from panel
gwf$ccode = panel$ccode[match(gwf$cname, panel$cname)]

# Add ccode + year variable
gwf$cyear = paste0(gwf$ccode, gwf$year)

# Remove dupes
toDrop = c('Czechoslovakia 89-93', 'South Yemen 67-90', 'South Vietnam 54-63', 'South Vietnam 63-75')
gwf$drop = 0
gwf$drop[which(gwf$gwf_casename %in% toDrop)] = 1
gwf = gwf[gwf$drop == 0, ]
############################

############################
# Save
gwf = gwf[,c('cyear','gwf_party', 'gwf_military', 'gwf_monarchy', 'gwf_personal', 'gwf_nonautocracy')]
save(gwf, file=paste0(pathDataBin, 'gwf.rda'))
############################