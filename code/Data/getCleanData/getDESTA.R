####
if(Sys.info()["user"]=="janus829" | Sys.info()["user"]=="s7m"){
	source('~/Research/fdi_network/code/setup.R') }
####

####
# Download file from ICOW site
destaURL = 'http://www.designoftradeagreements.org/wp-content/uploads/DESTA_dyadic27March15.xlsx'
destaName = paste0(pathDataRaw, 'desta.xlsx')
if(!file.exists(destaName)) { download.file(destaURL, destaName) }
desta = read.xlsx(destaName, sheet=1)	
####

####
# Add panel countrynames
cntry = c(desta$country1, desta$country2) %>% unique() %>% data.frame(cntry = .)
cntry$cname = cname(cntry$cntry)
cntry$ccode = panel$ccode[match(cntry$cname, panel$cname)]
cntry = na.omit(cntry) # Removes countries not in panel

# Add in ccodes to desta dataset
desta$ccode_1 = cntry$ccode[match(desta$country1, cntry$cntry)]
desta$ccode_2 = cntry$ccode[match(desta$country2, cntry$cntry)]

# Subset to relev variables in desta
desta = desta[,c('ccode_1','ccode_2','Year','Name')]
names(desta)[3] = 'year'
desta = na.omit(desta) # removes countries not in panel
####

####
# Create frame to merge desta with 
# First create the standard frame
frame = expand.grid(ccode_1=cntry$ccode, ccode_2=cntry$ccode, year=1960:2012)
frame = frame[frame$ccode_1 != frame$ccode_2, ]

# Remove countries that pop up before actual existence according to panel
frame$tmp = paste0(frame$ccode_1, frame$year)
frame = frame[which(frame$tmp %in% intersect(frame$tmp, panel$ccodeYear)),]
frame$tmp = paste0(frame$ccode_2, frame$year)
frame = frame[which(frame$tmp %in% intersect(frame$tmp, panel$ccodeYear)),]
frame = frame[,-which(names(frame)=='tmp')]
frame$id = paste(frame$ccode_1, frame$ccode_2, frame$year, sep='_')

# Create count of PTAs by year
slice = desta[desta$id %in% '100_130',]
slice = desta
sliceExp = lapply(1:nrow(slice), function(i){
	expand.grid(
		num( slice[i,paste0('ccode_',1:2)] ), 
		num( slice[i,paste0('ccode_',1:2)] ),
		slice[i,'year']:2012) 
	}) %>% do.call('rbind',.) %>% .[.[,1] != .[,2],]
cnts = paste(sliceExp[,1],sliceExp[,2],sliceExp[,3],sep='_') %>% table() %>% cbind() %>% data.frame() 
cnts$id = rownames(cnts) ; names(cnts)[1] = 'cnt' ; rownames(cnts) = NULL
cnts$idD = unlist(lapply(strsplit(cnts$id, '_'), function(i) paste(i[1], i[2], sep='_')))

# Merge in PTA variable into frame
frame$ptaCnt = cnts$cnt[match(frame$id, cnts$id)]
frame$ptaCnt[is.na(frame$ptaCnt)] = 0
frame$pta = ifelse(frame$ptaCnt>=1, 1, 0)
####

####
# Create adjacency matrices
ptaCntMats <- DyadBuild(variable='ptaCnt', dyadData=frame, 
	time=1960:2012, panel=panel, directed=FALSE)
ptaMats <- DyadBuild(variable='pta', dyadData=frame, 
	time=1960:2012, panel=panel, directed=FALSE)
####

####
# Save
destaFrame = frame
save(destaFrame, ptaCntMats, ptaMats, file=paste0(pathDataBin, 'desta.rda'))
####