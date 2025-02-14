library(tidyverse)
# library(arrow)
library(duckdb)

zip_bestanden <- list.files("data-raw", pattern = "\\.zip$", full.names = TRUE)

walk(zip_bestanden, ~unzip(.x, 
                           files = unzip(.x, list = TRUE) %>% filter(str_detect(Name, "csv$")) %>% pull(Name),
                           exdir = "data-raw/wkp_bestanden"))


meetwaarden_csv <- list.files("data-raw/wkp_bestanden", pattern = "Meetwaarden", full.names = TRUE)
meetpunten_csv <- list.files("data-raw/wkp_bestanden", pattern = "Meetobjecten", full.names = TRUE)

db <- duckdb(dbdir = "C:/R/wkp_data/data/wkp_data.duckdb")
con <- DBI::dbConnect(db)

kolom_types_mw <- tibble::tribble(
                                    ~kolom,     ~type,
                          "Rapportagejaar", "INTEGER",
                                "Meetjaar", "INTEGER",
                     "Waterbeheerder.code", "VARCHAR",
                     "Waterbeheerder.naam", "VARCHAR",
                    "Meetobject.namespace", "VARCHAR",
                     "Meetobject.lokaalid", "VARCHAR",
                         "Meetobject.code", "VARCHAR",
                               "Namespace", "VARCHAR",
                   "Monster.Identificatie", "VARCHAR",
                        "Monster.lokaalid", "VARCHAR",
                "MonsterCompartiment.code", "VARCHAR",
                             "Orgaan.code", "VARCHAR",
                     "Orgaan.omschrijving", "VARCHAR",
                          "Organisme.naam", "VARCHAR",
               "Organisme.naam_nederlands", "VARCHAR",
              "Bemonsteringsapparaat.code", "VARCHAR",
      "Bemonsteringsapparaat.omschrijving", "VARCHAR",
                      "Monsterophaaldatum",    "DATE",
                       "Monsterophaaltijd",    "TIME",
                      "GeometriePunt.X_RD",  "DOUBLE",
                      "GeometriePunt.Y_RD",  "DOUBLE",
                     "Meetwaarde.lokaalid", "VARCHAR",
                          "Resultaatdatum",    "DATE",
                           "Resultaattijd",    "TIME",
                              "Begindatum",    "DATE",
                               "Begintijd",    "TIME",
                               "Einddatum",    "DATE",
                                "Eindtijd",    "TIME",
                           "Typering.code", "VARCHAR",
                   "Typering.omschrijving", "VARCHAR",
                          "Grootheid.code", "VARCHAR",
                  "Grootheid.omschrijving", "VARCHAR",
                          "Parameter.code", "VARCHAR",
                  "Parameter.omschrijving", "VARCHAR",
                     "Parameter.CASnummer", "VARCHAR",
                           "Biotaxon.naam", "VARCHAR",
                "Biotaxon.naam_nederlands", "VARCHAR",
                            "Eenheid.code", "VARCHAR",
                    "Eenheid.omschrijving", "VARCHAR",
                       "Hoedanigheid.code", "VARCHAR",
               "Hoedanigheid.omschrijving", "VARCHAR",
                      "Levensstadium.code", "VARCHAR",
              "Levensstadium.omschrijving", "VARCHAR",
                       "Lengteklasse.code", "VARCHAR",
               "Lengteklasse.omschrijving", "VARCHAR",
                           "Geslacht.code", "VARCHAR",
                   "Geslacht.omschrijving", "VARCHAR",
                  "Verschijningsvorm.code", "VARCHAR",
          "Verschijningsvorm.omschrijving", "VARCHAR",
                         "Levensvorm.code", "VARCHAR",
                 "Levensvorm.omschrijving", "VARCHAR",
                             "Gedrag.code", "VARCHAR",
                     "Gedrag.omschrijving", "VARCHAR",
                "AnalyseCompartiment.code", "VARCHAR",
        "AnalyseCompartiment.omschrijving", "VARCHAR",
            "Waardebewerkingsmethode.code", "VARCHAR",
    "Waardebewerkingsmethode.omschrijving", "VARCHAR",
             "Waardebepalingsmethode.code", "VARCHAR",
     "Waardebepalingsmethode.omschrijving", "VARCHAR",
            "LocatieTypeWaardeBepaling.id", "VARCHAR",
  "LocatieTypeWaardeBepaling.omschrijving", "VARCHAR",
                           "Limietsymbool", "VARCHAR",
                         "Numeriekewaarde",  "DOUBLE",
                     "Alfanumeriekewaarde", "VARCHAR",
                  "Kwaliteitsoordeel.code", "VARCHAR",
          "Kwaliteitsoordeel.omschrijving", "VARCHAR"
  ) %>% 
  deframe()

kolom_types_mp <- 
  tibble::tribble(
                                ~kolom,     ~type,
                      "Rapportagejaar", "INTEGER",
                            "Meetjaar", "INTEGER",
                 "Waterbeheerder.code", "VARCHAR",
                 "Waterbeheerder.naam", "VARCHAR",
                           "Namespace", "VARCHAR",
                       "Identificatie", "VARCHAR",
                     "Meetobject.code", "VARCHAR",
                        "Omschrijving", "VARCHAR",
                         "Toelichting", "VARCHAR",
                  "GeometriePunt.X_RD",  "DOUBLE",
                  "GeometriePunt.Y_RD",  "DOUBLE",
                   "KRWwatertype.code", "VARCHAR",
           "KRWwatertype.omschrijving", "VARCHAR",
             "WatergangCategorie.code", "VARCHAR",
     "WatergangCategorie.omschrijving", "VARCHAR",
     "HoortbijGeoobject.identificatie", "VARCHAR",
                       "Wegingsfactor",  "DOUBLE",
       "LigtInGeoobject.identificatie", "VARCHAR",
          "Monitoringobjectsoort.code", "VARCHAR",
  "Monitoringobjectsoort.omschrijving", "VARCHAR",
                    "Landgebruik.code", "VARCHAR",
            "Landgebruik.omschrijving", "VARCHAR",
             "GeoobjectCodeVoorganger", "VARCHAR",
                  "DatumInGebruikname",    "DATE",
              "DatumBuitenGebruikname",    "DATE"
  ) %>% deframe()


# duckdb_read_csv(con, name = "meetwaarden", files = meetwaarden_csv, delim = ";", col.types = kolom_types)
walk(meetwaarden_csv, ~duckdb_read_csv(con, name = "meetwaarden", files = .x, delim = ";", col.types = kolom_types_mw))
walk(meetpunten_csv, ~duckdb_read_csv(con, name = "meetpunten", files = .x, delim = ";", col.types = kolom_types_mp))
# 
# tabel <- function(tabelnaam){
#   dplyr::tbl(con, tabelnaam) 
#   
# }
# tabel("meetwaarden") %>% filter(Parameter.code == "imdcpd") %>% collect %>% View()



