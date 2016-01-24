####
if(Sys.info()["user"]=="janus829" | Sys.info()["user"]=="s7m"){
	source('~/Research/fdi_network/code/setup.R') }
####

###############################################################
# Get distance matrices in parallel
# Parameters for parallelization
cl = makeCluster(8)
registerDoParallel(cl)
yrs = 1960:2012

# Get capdist mats
print('Collecting capital distance matrices...')
capMats = foreach(yr = yrs, .packages=c("cshapes")) %dopar% {
	distmatrix(as.Date(paste0(yr, "-1-1")), type="capdist", useGW=TRUE)
}

# Get centdist mats
print('Collecting centroid distance matrices...')
centMats = foreach(yr = yrs, .packages=c("cshapes")) %dopar% {
	distmatrix(as.Date(paste0(yr, "-1-1")), type="centdist", useGW=TRUE)
}

# Get mindist mats
print('Collecting minimum distance matrices...')
minMats = foreach(yr = yrs, .packages=c("cshapes")) %dopar% {
	distmatrix(as.Date(paste0(yr, "-1-1")), type="mindist", useGW=TRUE)
}

# Free my clusters
stopCluster(cl)
###############################################################

###############################################################
# Clean up each
# Convert GW codes to panel codes
matchPanelCode = function(x){
	pcodes=panel$ccode[match(rownames(x), panel$GWCODE)]
	rownames(x)=colnames(x)=pcodes
	return(x) }

capMats = lapply(capMats, matchPanelCode)
centMats = lapply(centMats, matchPanelCode)
minMats = lapply(minMats, matchPanelCode)

# Label years
names(capMats) = yrs; names(centMats) = yrs; names(minMats) = yrs
###############################################################

###############################################################
# Save to binaries
save(capMats, centMats, minMats, file=paste0(pathDataBin,'distMats.rda'))
###############################################################