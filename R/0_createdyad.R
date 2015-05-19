rm(list=ls())
source("functions.R")
packs <- c("countrycode", "psData", "plyr", "dplyr")
f_install_and_load(packs)

if (Sys.info()["user"] == "anh") {
  c_datapath <- "~/Dropbox/fdi_network/Data//UNCTAD_outflow/"
  c_outpath <- "~/Dropbox/fdi_network/Data/"
}

c_files <- list.files(path=c_datapath, pattern="*.csv")

f_createdyad <- function(filename) {
  c_sender <- unlist(strsplit(filename, split="_"))[1]
  d <- read.csv(paste0(c_datapath, filename))
  d <- d %>%
    mutate(sender = c_sender) %>%
    rename(receiver = country)
  d <- d[ , c(ncol(d), 1:(ncol(d)-1))] # Reorder the column so that sender is first col
  return(d)
}

# Create the dyads from each country file and put into a big data frame
d_biFDI <- ldply(c_files, f_createdyad, .inform = TRUE)
d_biFDI <- d_biFDI %>%
  mutate(sender = countrycode(sender, "iso3c", "iso2c", warn=TRUE)) %>%
  mutate(receiver = countrycode(receiver, "country.name", "iso2c", warn=TRUE))

# Create the FULL set of dyads from Polity countries
d_Politycountries <- PolityGet(vars = 'polity2', OutCountryID = "iso2c", standardCountryName = TRUE) %>%
  filter(year >= 2001) %>%
  distinct(iso2c, country) %>%
  select(iso2c, country)
d_full <- expand.grid(sender=d_Politycountries$iso2c, receiver=d_Politycountries$iso2c,
                      stringsAsFactors=FALSE)

# Join dyads and FULL set of dyads to pad the non-existing edge
d <- full_join(d_biFDI, d_full, by=c("sender", "receiver"))

write.csv(d, file=paste0(c_outpath, "dyads.csv"), row.names=FALSE)
