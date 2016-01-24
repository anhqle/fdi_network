####
if(Sys.info()["user"]=="janus829" | Sys.info()["user"]=="s7m"){
	source('~/Research/fdi_network/code/setup.R') }
####

###############################################################
# Load in datasets
dvData='kaopen.rda'
monData=c('icrg', 'worldBank', 'polity', 'constraints', 'dpi', 'gwto', 'gwf') %>% paste0('.rda')
dyData=c('colony','distMats','desta', 'imfTrade') %>% paste0('.rda')
###############################################################

###############################################################
# Merge monadic variables from icrg, worldBank, polity, constraints into kaopen
for(pkg in pathDataBin %>% paste0(c(dvData, monData)) ) { load( pkg ) }; rm(list='pkg')

# Merge kaopen and icrg
icrg = icrg[,c('cyear', names(icrg)[5:16])]
aData = merge(kaopen, icrg, by='cyear', all.x=TRUE, all.y=FALSE)

# Merge kaopen and worldbank
aData = merge(aData, worldBank, by='cyear', all.x=TRUE, all.y=FALSE)

# Merge kaopen and polity
polity = polity[,c('cyear', names(polity)[8:21])]
aData = merge(aData, polity, by='cyear', all.x=TRUE, all.y=FALSE)

# Merge kaopen and constraints
constraints = constraints[,c('cyear', names(constraints)[8:10])]
aData = merge(aData, constraints, by='cyear', all.x=TRUE, all.y=FALSE)

# Merge DPI
aData = merge(aData, dpi, by='cyear', all.x=TRUE, all.y=FALSE)

# Merge gwto
aData = merge(aData, gwto, by='cyear', all.x=TRUE, all.y=FALSE)

# Merge gwf
aData = merge(aData, gwf, by='cyear', all.x=TRUE, all.y=FALSE)

# Remove leftover datasets
rm(list=c(substr(dvData, 1, nchar(dvData)-4),
	substr(monData, 1, nchar(monData)-4)) )
###############################################################

###############################################################
# Create spatial variables
for(pkg in pathDataBin %>% paste0(dyData) ) { load( pkg ) }; rm(list='pkg')

# Create logged versions of trade from COW/IMF and aid
imfExpMatsFOBL = lapply(imfExpMatsFOB, function(mat){ return( log(mat + 1) ) })
imfImpMatsCIFL = lapply(imfImpMatsCIF, function(mat){ return( log(mat + 1) ) })
names(imfExpMatsFOBL) = names(imfExpMatsFOB)
names(imfImpMatsCIFL) = names(imfImpMatsCIF)

# Turn non-diagonal zero entries in min distance matrices to 1
minMats2 = lapply(minMats, function(x){ x = x + 1; diag(x) = 0; x; })
names(minMats2) = names(minMats)

# Add 2013 to distance matrices (just repeating 2012)
capMats$'2013' = capMats$'2012'
centMats$'2013' = centMats$'2012'
minMats2$'2013' = minMats2$'2012'

# Create spatial version of kaopen vars
vars = c('kaopen','ka_open')
wgtMats = list( 
	col=colMats,  # ends at 2012
	capD=capMats, centD=centMats, minD=minMats2,   # ends at 2012
	imfExp = imfExpMatsFOB, # ends at 2013
	imfExpL = imfExpMatsFOBL,  # ends at 2013
	imfImp = imfImpMatsCIF, # ends at 2013
	imfImpL = imfImpMatsCIFL, # ends at 2013
	ptaC = ptaCntMats, # ends at 2013
	pta = ptaMats # ends at 2013
	)
spNames = names(wgtMats) %>% paste0('_')
years = lapply(wgtMats, names)
inv = c(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE)

# Check to make sure right mats are being inverted
cbind(names(wgtMats), inv) %>% print()

for(ii in 1:length(wgtMats)){
	spData = spatialBuild(spatList=wgtMats[[ii]],
		varData=aData, years=1970:2013, variable=vars,
		sp_suffix=spNames[ii], invert=inv[ii] )
	spData$cyear = num(spData$cyear)
	aData = merge(aData, 
		spData[,c(1:length(vars),ncol(spData))],by='cyear',all.x=T)
	print(spNames[ii])	}
###############################################################

###############################################################
# Create EU (Germany, France, UK) export dependence variable
tData$expFOB[is.na(tData$expFOB)] = 0
tData = data.table( tData )
totExpBySender = tData[,list(sum=sum(expFOB)),by=list(ccode_1, year)]
totExpBySender[,cyear:=paste0(ccode_1,year)]
totExpBySender = data.frame( totExpBySender )
tData = data.frame( tData )

majEU = panel$ccode[match(c('GERMANY','FRANCE','UNITED KINGDOM'), panel$cname)]
expToEU = tData[which(tData$ccode_2 %in% majEU),]
expToEU = data.table( expToEU )
totExpToEU = expToEU[,list(sum=sum(expFOB)), by=list(ccode_1, year)]
totExpToEU[,cyear:=paste0(ccode_1,year)]
totExpToEU = data.frame( totExpToEU )

# merge together
totExpToEU$total = totExpBySender$sum[match(totExpToEU$cyear, totExpBySender$cyear)]
totExpToEU$euShare = totExpToEU$sum/totExpToEU$total
totExpToEU$euShare[is.na(totExpToEU$euShare)] = 0

# Merge bcak to aData
aData$euExpShare = totExpToEU$euShare[match(aData$cyear, totExpToEU$cyear)]
###############################################################

###############################################################
# Create lags

# Select vars to lag
noLag = c('cyear','CNTRY_NAME', 'COWCODE', 'country_name',
	'GWCODE', 'year', 'cname', 'ccode', 
	'kaopen', 'ka_open', 'gwf_nonautocracy')
toLag = setdiff(names(aData), noLag)

# Adjustments to id variables
aData$cyear = num(aData$cyear)
aData$ccode = num(aData$ccode)

# Make sure all variables to be lagged are numeric
sum(apply(aData[,toLag],2,class)=='numeric')/length(toLag)

# Lag selected variables 1 year
aData = lagData(aData, 'cyear', 'ccode', toLag, lag=1)
###############################################################

###############################################################
# Save
save(aData, file=paste0(pathDataBin,'analysisData.rda'))
###############################################################