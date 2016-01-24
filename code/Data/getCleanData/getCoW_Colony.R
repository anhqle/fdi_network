####
if(Sys.info()["user"]=="janus829" | Sys.info()["user"]=="s7m"){
	source('~/Research/fdi_network/code/setup.R') }
####

############################
# Download file from ICOW site
colURL = 'http://www.paulhensel.org/Data/colhist.zip'
colName = paste0(pathDataRaw, 'colony.zip')
if(!file.exists(colName)) { download.file(colURL, colName) }

colonyFull = unzip(colName, 'ICOW Colonial History 1.0/coldata100.dta') %>% read.dta()
unlink(paste0(getwd(), '/ICOW Colonial History 1.0'), 
	force=TRUE, recursive=TRUE)
############################

############################
# add year of split
colonyFull$indYear = num( substr(colonyFull$inddate, 0, 4) ) 

# Clean colony dataset
colony = colonyFull[,c('state','name','colruler','indYear')] # Subset to relevant vars

# colruler
colony$cnameRuler = countrycode(colony$colruler, 'cown', 'country.name')

# Remove NAs
colony = colony[!is.na(colony$cnameRuler),]

# Add cname for ruled
colony$cnameRuled = countrycode(colony$state,'cown','country.name')
colony$cnameRuled[colony$cnameRuled=='Yugoslavia'] = 'SERBIA'

# Remova NAs
colony = colony[!is.na(colony$cnameRuled),]

# Add countrycodes
colony$ccodeRuler = panel$ccode[match(colony$cnameRuler,panel$cname)]
colony$ccodeRuled = panel$ccode[match(colony$cnameRuled,panel$cname)]
############################

############################
# Transform to dyadic dataset
tmp = colony; tmp$indYear[tmp$indYear<1960] = 1960
ruled = unique(colony$ccodeRuled)
rulers = unique(colony$ccodeRuler)
colDyad = expand.grid(ccode_1=ruled, ccode_2=rulers, year=1960:2012)
colDyad = colDyad[colDyad$ccode_1!=colDyad$ccode_2,]

# Add colony variable to dyadic+year df
colDyad$colony = 0
for(ii in 1:nrow(colony)){
	obs = colony[ii,]
	colDyad$colony[
		colDyad$ccode_1==obs$ccodeRuled & 
		colDyad$ccode_2==obs$ccodeRuler & 
		colDyad$year>=obs$indYear] = 1
}
############################

############################
# Build adjacency matrices
colMats <- DyadBuild(variable='colony', dyadData=colDyad, 
    time=1960:2012, panel=panel, directed=TRUE)
############################

############################
# Save
save(colony, colMats,
	file=paste0(pathDataBin, 'colony.rda'))
############################