# Build adjacency matrices from dyadic data
# Dyad data must identify countries by variables  
# ccode_1 & ccode_2 and the time aspect by a variable called year
# time is a simple vector of years
# panel is a dataset with country codes
DyadBuild <- function(variable, dyadData, time, panel=panel, directed=FALSE){

	countryList <- lapply(time, function(x) FUN=panel[panel$year==x,'ccode'])
	names(countryList) <- time

	Mats <- list()
	for(ii in 1:length(time)){
	  countries <- countryList[[ii]]
	  yearMatrix <- matrix(0, nrow=length(countries), ncol=length(countries))
	  rownames(yearMatrix) <- colnames(yearMatrix) <- countries
	  
	  dyadData <- dyadData[,c('ccode_1','ccode_2','year',variable)]
	  dyadData <- data.matrix(dyadData)
	  data <- matrix(dyadData[which(dyadData[,'year'] %in% time[ii]),], ncol=4, 
	                 dimnames=list(NULL, c('ccode_1','ccode_2','year',variable)))
	  
	  for(jj in 1:nrow(yearMatrix)){
	    slice <- matrix(data[which(data[,'ccode_1'] %in% countries[jj]), c('ccode_2',variable)], ncol=2, 
	                    dimnames=list(NULL, c('ccode_2',variable)))
	    rownames(slice) <- slice[,'ccode_2']
	    x <- intersect(countries, as.vector(slice[,'ccode_2']))
	    slice2 <- matrix(slice[as.character(x),], ncol=2, 
	                     dimnames=list(NULL, c('ccode_2',variable)))
	    rownames(slice2) <- slice2[,'ccode_2']
	    
	    yearMatrix[as.character(countries[jj]), rownames(slice2)] <- slice2[,variable]
	    if(directed==FALSE){yearMatrix[rownames(slice2), as.character(countries[jj])] <- slice2[,variable]}
	  }

	  # Remove NAs
	  yearMatrix[is.na(yearMatrix)] = 0
	  
	  Mats[[ii]] <- yearMatrix
	  print(time[ii])
	}

	names(Mats) <- time
	Mats
}

# Build dyad dataset from monadic data
# This only works if the units listed in countrylist exactly
# match the units listed in the monad dataset
# Monad data must identify country by a variable called 
# ccode and the time aspect by a variable called by year
# time is a simple vector of years
# countryList is a list containing ccodes for each year
DyadBuild_fMonad <- function(variable, oper,
	monadData, time, countryList){
	monadData <- monadData[,c('ccode','year',variable)]
	monadData <- data.matrix(monadData)
	rownames(monadData) <- monadData[,'ccode']

	undirectMats <- list()

	for(ii in 1:length(time)){
		countries <- countryList[[ii]]
		yearMatrix <- matrix(0, nrow=length(countries), ncol=length(countries))
		rownames(yearMatrix) <- colnames(yearMatrix) <- countries

		data <- monadData[which(monadData[,'year'] %in% time[ii]), ]

		for(jj in 1:nrow(yearMatrix)){
			cntryRating <- data[as.character(countries[jj]),variable]
			others <- data[as.character(countries),variable]
			if(oper=='absdiff'){relates <- abs(cntryRating-others)}
			if(oper=='same'){relates <- as.numeric(cntryRating==others)}
			yearMatrix[jj,] <- relates
		}

		diag(yearMatrix) <- 0
		undirectMats[[ii]] <- yearMatrix
		print(time[ii]) 
	}
		names(undirectMats) <- time
		undirectMats
}

# Create spatially weighted variables
# Requires access to SM created panel dataset
# In the dataset with the variables to be weighted it is 
# necessary to have country identifier given by ccode and
# time identifier given by year
spatialBuild <- function(spatList, varData, years, variable, sp_suffix, invert=FALSE){
	spatData <- NULL

	for(i in 1:length(years)){
		spatMat <- spatList[[i]]
		# rownames for matrices
		distNames <- as.numeric(rownames(spatMat))
		ndistNames <- panel$ccode[match(distNames, panel$GWCODE)]
		rownames(spatMat) <- ndistNames; colnames(spatMat) <- ndistNames

		# Invert
		if(invert){spatMat <- 1/spatMat; spatMat[spatMat==Inf] <- 0}

		# Applying row standardized weights
		dmatDenom <- apply(spatMat,1,sum)
		dmatDenom[dmatDenom==0] <- 1
		spatMat_rowst <- spatMat/dmatDenom
		
		# Bringing in fdi dataset
		spat_vars <- c('ccode', variable)
		dataYear <- varData[varData$year==years[i], spat_vars]
		dataYear <- dataYear[which(dataYear$ccode %in% ndistNames),]
		o <- as.character(dataYear$ccode)
		
		spatMat_rowst <- spatMat_rowst[o,o]
		# data rows with NAs that are in distance matrix
		# this is equivalent to just dropping them from teh 
		# spatial variable calculation
		dataYear[is.na(dataYear)] <- 0
		
		for(j in 1:nrow(spatMat_rowst)){
			row_weights <- NULL
			row_weights <- t(t(dataYear[,c(2:ncol(dataYear))]) %*%  spatMat_rowst[j,])
			row_weights2 <- NULL
			row_weights2 <- cbind(row_weights, years[i], dataYear$ccode[j])
			spatData <- rbind(spatData, row_weights2)
		}
	print(years[i])}
	spatData <- data.frame(spatData, row.names=NULL)
	spatData[,1:length(vars)] = apply(spatData[,1:length(vars)], 2, num)

	names(spatData) <- c(
		paste(sp_suffix,names(spatData)[1:(length(spat_vars)-1)],sep=''),
		'year','ccode')
	spatData$cyear <- paste(spatData$ccode, spatData$year, sep='') 
	spatData
}
