####
if(Sys.info()["user"]=="janus829" | Sys.info()["user"]=="s7m"){
	source('~/Research/fdi_network/code/setup.R') }
####

# Get list of cleaning scripts
files = list.files( paste0(gpth, 'R/Data/getCleanData/') ) # get cleaning files
files = files[substrRight(files, 2) == '.R'] # only R files
cleanSripts = paste0( paste0(gpth, 'R/Data/getCleanData/'), files )

# Parameters for parallelization
cl = makeCluster(8)
registerDoParallel(cl)

# Run cleaning scripts in paralle
foreach(script = cleanSripts) %dopar% { source(script) }

# Free my clusters
stopCluster(cl)