####
if(Sys.info()["user"]=="janus829" | Sys.info()["user"]=="s7m"){
	source('~/Research/fdi_network/code/setup.R') }
####

####
# csv files with export data
imfPath = paste0(pathDataRaw, 'IMF_DoT/')
expFiles = list.files(imfPath) %>% .[grepl('Value of Exports', .)]
impFilesCIF = list.files(imfPath) %>% .[grepl('Value of Imports, CIF', .)]
impFilesFOB = list.files(imfPath) %>% .[grepl('Value of Imports, FOB', .)]
####

####
# Create directed dyadic datasets
# Function to process IMF DOT csv Sheets
processIMF = function(file, path=imfPath, verbose=TRUE){
	if(verbose){print(paste0('Processing ', file, '  ...'))}
	slice = read.csv(paste0(path, file), header=FALSE)
	names(slice) = paste(
		char(unlist(slice[1,])), 
		char(unlist(slice[2,])), sep='_')
	slice = slice[c(-1,-2),]
	names(slice)[1] = 'j'
	slice = melt(slice, id='j')
	ids = strsplit(char(slice$variable), '_')
	slice$i = unlist(lapply(ids, function(x) x[1]))
	slice$t = unlist(lapply(ids, function(x) x[2]))
	slice = slice[,c('i', 'j', 't', 'value')]
	slice$j = slice$j %>% char()
	slice$value = num(slice$value)

	# Drop i - i
	slice = slice[which(slice$i != slice$j), ]

	# Return object
	return(slice)
}

expData = lapply(expFiles, function(f){ processIMF(f) }) %>% do.call('rbind', .)
impDataCIF = lapply(impFilesCIF, function(f){ processIMF(f) }) %>% do.call('rbind', .)
impDataFOB = lapply(impFilesFOB, function(f){ processIMF(f) }) %>% do.call('rbind', .)
imfData = list(expData, impDataCIF, impDataFOB); rm(list=c('expData', 'impDataCIF', 'impDataFOB'))
names(imfData) = c('exp', 'impCIF', 'impFOB')
####

####
# Cleaning 
# Get cntries list from imf data
imfCntries = lapply(imfData, function(x) { c(x$i, x$j) %>% unique() } ) %>% unlist() %>% unique() %>% data.frame()
names(imfCntries) = 'name'
imfCntries$cname = cname(imfCntries$name)
imfCntries$ccode = panel$ccode[match(imfCntries$cname, panel$cname)]
imfCntries = na.omit(imfCntries) # Remove countries not in panel frame

# Subset imfData list items by countries in imfCntries
imfData = lapply(imfData, function(x){
	# Add ccode
	x$ccode_1 = imfCntries$ccode[match(x$i, imfCntries$name)]
	x$ccode_2 = imfCntries$ccode[match(x$j, imfCntries$name)]
	x$id = paste(x$ccode_1, x$ccode_2, x$t, sep='_')
	# Remove NAs
	x = x[!is.na(x$ccode_1),]
	x = x[!is.na(x$ccode_2),]
	return(x) 
	} )

####
# Merge together imf variables into standard frame

# First create the standard frame
tData = expand.grid(i=imfCntries$ccode, j=imfCntries$ccode, t=1960:2013)
tData = tData[tData$i != tData$j, ]

# Remove countries that pop up before actual existence according to panel
tData$tmp = paste0(tData$i, tData$t)
tData = tData[which(tData$tmp %in% intersect(tData$tmp, panel$ccodeYear)),]
tData$tmp = paste0(tData$j, tData$t)
tData = tData[which(tData$tmp %in% intersect(tData$tmp, panel$ccodeYear)),]
tData = tData[,-which(names(tData)=='tmp')]
tData$id = paste(tData$i, tData$j, tData$t, sep='_')

# Merge
tData$expFOB = imfData$'exp'$value[match(tData$id, imfData$'exp'$id)]
tData$impFOB = imfData$'impFOB'$value[match(tData$id, imfData$'impFOB'$id)]
tData$impCIF = imfData$'impCIF'$value[match(tData$id, imfData$'impCIF'$id)]

# Cleanup
names(tData)[1:3] = c('ccode_1', 'ccode_2', 'year')
####

####
# Create adjacency matrices
imfExpMatsFOB <- DyadBuild(variable='expFOB', dyadData=tData, 
	time=1960:2013, panel=panel, directed=TRUE)
imfImpMatsFOB <- DyadBuild(variable='impFOB', dyadData=tData, 
	time=1960:2013, panel=panel, directed=TRUE)
imfImpMatsCIF <- DyadBuild(variable='impCIF', dyadData=tData, 
	time=1960:2013, panel=panel, directed=TRUE)
####

####
# Save data
save(tData, imfExpMatsFOB, imfImpMatsCIF, imfImpMatsCIF, 
	file=paste0(pathDataBin, 'imfTrade.rda'))
####