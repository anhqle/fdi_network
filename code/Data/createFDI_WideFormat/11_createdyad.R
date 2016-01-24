rm(list=ls())
source("_functions.R")
packs <- c("countrycode", "stringr", "psData", "WDI", "reshape2", "plyr", "dplyr")
f_install_and_load(packs)

# ---- Constants ----

source("_paths.R")
c_files <- list.files(path=c_datapath, pattern="*.csv")

# ---- Create the dyads from each country file ----

f_createdyad <- function(filename) {
  c_sender <- unlist(strsplit(filename, split="_"))[1]
  d <- read.csv(paste0(c_datapath, filename))
  d <- d %>%
    mutate(sender = c_sender) %>%
    rename(receiver = country)
  d <- d[ , c(ncol(d), 1:(ncol(d)-1))] # Reorder the column so that sender is first col
  return(d)
}

d_biFDI <- ldply(c_files, f_createdyad, .inform = TRUE)

# BIOT (British Indian Ocean Territory) listed but not converted
d_biFDI <- d_biFDI %>%
  mutate(sender = revalue(sender, replace = c("HGK" = "HKG"))) %>% # Hong Kong
  mutate(sender = countrycode(sender, "iso3c", "iso3c", warn=TRUE)) # standardize

# Serbia and Montenegro listed but not converted
d_biFDI <- d_biFDI %>%
  mutate(receiver = countrycode(receiver, "country.name", "iso3c", warn=TRUE))

# Remove missing (unconverted) sender and receiver (i.e. BIOT and Serbia & Mont)
d_biFDI  <- d_biFDI %>%
  filter(!is.na(sender), !is.na(receiver))

# ---- Create the FULL set of dyads from Polity countries ----
d_Politycountries <- PolityGet(vars = 'polity2', OutCountryID = "iso3c",
                               standardCountryName = TRUE) %>%
  filter(year >= 2001) %>%
  distinct(iso3c, country) %>%
  select(iso3c, country)
d_full <- expand.grid(sender=d_Politycountries$iso3c, receiver=d_Politycountries$iso3c,
                      stringsAsFactors=FALSE)

# ---- Join dyads and FULL set of dyads to pad the non-existing edge ----
d <- full_join(d_biFDI, d_full, by=c("sender", "receiver"))

# Show dyads that exist in FDI but not in Polity
# (mainly small islands, tax shelter)
tmp <- anti_join(d_biFDI, d_full, by = c("sender", "receiver"))

write.csv(d, file=paste0(c_outpath, "dyads.csv"), row.names=FALSE)

# ---- Merge with covariates ----
d_wdi <- WDI(indicator = c("NY.GDP.PCAP.KD", "NY.GDP.MKTP.KD"),
             extra = TRUE, start = 2001, end = 2012) %>%
  filter(region != "Aggregates") %>%
  rename(gdppc = NY.GDP.PCAP.KD,
         gdp = NY.GDP.MKTP.KD)

# Reshape from long to wide
d_wdi_m <- melt(d_wdi, id.vars = c("iso3c", "year"),
                measure.vars = c("gdppc", "gdp"))
d_wdi_c <- dcast(d_wdi_m, iso3c ~ variable + year)

# Join monadic covariates with dyadic dataframe
d <- left_join(d, d_wdi_c, by = c("sender" = "iso3c"))
d <- left_join(d, d_wdi_c, by = c("receiver" = "iso3c"))

# Rename to indicate sender and receiver covariate
names(d) <- str_replace(names(d), ".x$", ".sender")
names(d) <- str_replace(names(d), ".y$", ".receiver")

# Write to csv
write.csv(d, file=str_c(c_outpath, "dyads_withcovariates.csv"), row.names=FALSE)
