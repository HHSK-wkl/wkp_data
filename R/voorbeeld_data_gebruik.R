library(tidyverse)
library(duckdb)

db <- duckdb(dbdir = "C:/R/wkp_data/data/wkp_data.duckdb")
con <- DBI::dbConnect(db)

meetwaarden <- dplyr::tbl(con, "meetwaarden")
meetpunten <- dplyr::tbl(con, "meetpunten")

imidacloprid <- 
  meetwaarden %>% 
  filter(Parameter.code == "imdcpd") %>% 
  group_by(Meetjaar, Waterbeheerder.naam) %>% 
  summarise(aantal_metingen = n(),
            aantal_meetpunten = n_distinct(Meetobject.lokaalid))

imidacloprid %>% 
  ggplot(aes(Meetjaar, aantal_meetpunten)) +
  geom_col() +
  facet_wrap(~Waterbeheerder.naam)
