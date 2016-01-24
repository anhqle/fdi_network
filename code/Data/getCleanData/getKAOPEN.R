####
if(Sys.info()["user"]=="janus829" | Sys.info()["user"]=="s7m"){
	source('~/Research/fdi_network/code/setup.R') }
####

############################
# Download file from Chinn-Ito website
kaoURL = 'http://web.pdx.edu/~ito/kaopen_2013.dta'
kaoName = paste0(pathDataRaw, 'kaopen_2013.dta')
if(!file.exists(kaoName)) { download.file(kaoURL, kaoName) }

kaopen = read.dta(kaoName)
############################

############################
# Process kaopen data

# Clean up country names
kaopen$country_name[kaopen$country_name=='S? Tom\267and Principe'] = 'Sao Tome'

# Convert to common countryname using countrycode
kaopen$cname = cname(kaopen$country_name)

# Add in ccodes from panel
kaopen$ccode = panel$ccode[match(kaopen$cname, panel$cname)]

# Drop small countries (Aruba, Netherlands Antilles and Hong Kong)
kaopen = kaopen[!is.na(kaopen$ccode),]

# Add ccode + year variable
kaopen$cyear = paste0(kaopen$ccode, kaopen$year)
############################

############################
# Create global measure of kaopen by year
meanNA = function(x){ mean(x, na.rm=TRUE) }
kaopen$kaopenWrld = with( data=kaopen, ave( kaopen, year, FUN=meanNA ) )
kaopen$ka_openWrld = with( data=kaopen, ave( ka_open, year, FUN=meanNA ) )
############################

############################
# Save kaopen data
kaopen=kaopen[,c('country_name','cname','ccode','year','cyear','kaopen','ka_open','kaopenWrld','ka_openWrld')]
save(kaopen, file=paste0(pathDataBin, 'kaopen.rda'))
############################