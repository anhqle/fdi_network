####
if(Sys.info()["user"]=="janus829" | Sys.info()["user"]=="s7m"){
	source('~/Research/fdi_network/code/setup.R') }
####

############################
# Download file from POLCON site
conURL = 'http://mgmt5.wharton.upenn.edu/henisz/POLCON/polcon2012.zip'
conName = paste0(pathDataRaw, 'con.zip')
if(!file.exists(conName)) { download.file(conURL, conName) }

constraints = unzip(conName, 'polcon2012.dta') %>% read.dta()
############################

############################
# Clean constraints data
constraints <- constraints[constraints$year>=1960,1:10]
constraints <- constraints[!is.na(constraints$ccode),]

constraints$cnts_country <- as.character(constraints$cnts_country)
constraints$cnts_country[constraints$cnts_country=='CONGO (BRA)'] <- 'Congo, Republic of'
constraints$cnts_country[constraints$cnts_country=='CONGO (KIN)'] <- 'Congo, Democratic Republic of'
constraints$cnts_country[constraints$cnts_country=='CONGO DR'] <- 'Congo, Democratic Republic of'
constraints$cnts_country[constraints$cnts_country=='GERMAN DR'] <- "Germany Democratic Republic"

constraints$cname <- cname(constraints$cnts_country)
constraints[is.na(constraints$cname),'cname'] <- cname(
	constraints[is.na(constraints$cname),'polity_country'] )
constraints$cname[constraints$cnts_country=='VIETNAM REP'] <- 'S. VIETNAM'
constraints$cname[constraints$cnts_country=='YEMEN PDR'] <- 'S. YEMEN'
constraints$cname[constraints$cnts_country=="CZECHOS'KIA"] <- 'CZECH REPUBLIC'
constraints$cname[constraints$cnts_country=="YUGOSLAVIA"] <- 'SERBIA'
constraints <- constraints[constraints$cname!='HONG KONG',]

constraints$cnameYear <- paste(constraints$cname, constraints$year, sep='')

names(table(constraints$cnameYear)[table(constraints$cnameYear)>1]) # Dupe check

# Adding in codes from panel
constraints$ccode <- panel$ccode[match(constraints$cname,panel$cname)]
constraints$cyear <- paste(constraints$ccode, constraints$year, sep='')
table(constraints$cyear)[table(constraints$cyear)>1] # Dupe check
############################

############################
# Save
save(constraints, file=paste0(pathDataBin, 'constraints.rda'))
############################