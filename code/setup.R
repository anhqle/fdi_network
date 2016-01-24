# Clear workspace
rm(list=ls())

####################################
# Set up paths
if(Sys.info()["user"]=="janus829" | Sys.info()["user"]=="s7m"){
	dpth='~/Dropbox/Research/fdi_network/'
	gpth='~/Research/fdi_network/'
	pathDataRaw=paste0(dpth, 'data/components/')
	pathDataBin=paste0(dpth, 'data/binaries/')
	pathGraphics=paste0(dpth, 'graphics/')
	pathResults=paste0(dpth, 'results/') }

if (Sys.info()["user"] == "anh") {
  c_datapath <- "~/Dropbox/fdi_network/Data//UNCTAD_outflow/"
  c_outpath <- "~/Dropbox/fdi_network/Data/"
}
####################################

####################################
# Load helpful libraries
loadPkg=function(toLoad){
	for(lib in toLoad){
	  if(!(lib %in% installed.packages()[,1])){ 
	    install.packages(lib, repos='http://cran.rstudio.com/') }
	  library(lib, character.only=TRUE)
	} }

toLoad=c(
	'foreign', 'openxlsx', # Loading foreign files
	'httr', 'XML', # Loading files from web
	'lubridate', # date management
	'cshapes', 'WDI', # R pkgs to get data
	'countrycode', # Matching countries
	'data.table', 'reshape2', 'doBy', # Data manip
	'foreach', 'doParallel', # Parallelization
	'ggplot2', 'grid', 'xtable', 'tikzDevice',  # plotting/output
	'Amelia', 'MASS', 'lmtest', # Stats
	'magrittr' # other
	)

loadPkg(toLoad)

## gg theme
theme_set(theme_bw())

# ## Please note version of each package in sessInfo.tex, especially countrycode
# sessFile = file(paste0(gpth, 'code/sessInfo.tex'))
# sessionInfo() %>% toLatex(., locale=FALSE) %>% writeLines(., con=sessFile)
# close(sessFile)
####################################

####################################
# Helpful functions
char = function(x) { as.character(x) }
num = function(x) { as.numeric(char(x)) }
cname = function(x) { countrycode(x, 'country.name', 'country.name') }
trim = function (x) { gsub("^\\s+|\\s+$", "", x) }
substrRight = function(x, n){ substr(x, nchar(x)-n+1, nchar(x)) }

# Relational Data Helper Functions
source(paste0(gpth, 'code/helperFunctions/relDataHelpers.R'))

# Time Series Data Helper Functions
source(paste0(gpth, 'code/helperFunctions/tsDataHelpers.R'))
####################################

####################################
# Load panel dataset
load(paste0(pathDataBin, 'panel.rda'))
####################################

####################################
# vector of objects from setup file
setupObjects = c(ls(), 'setupObjects')
####################################