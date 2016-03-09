# The following SPARQL queries may be fired to the Getty's endpoint in order to
# download the latest version of the query table.

library(readr)

sparql_url <- function(query) {
  endpoint <- "http://vocab.getty.edu/sparql"
  escaped_query <- URLencode(query, reserved = TRUE)
  paste0(endpoint, ".csv?query=", escaped_query)
}

# Retrieve Table combining all IDs with both pref and alt names unified in one column, which can be used as a search mechanism
id_altname_query <- "
SELECT DISTINCT ?id ?alt_name
WHERE {
  ?artist skos:inScheme ulan: ;
      rdf:type gvp:PersonConcept ;
      dc:identifier ?id .

  { ?artist xl:altLabel [xl:literalForm ?alt_name] . } UNION
  { ?artist xl:prefLabel [xl:literalForm ?alt_name] . }
}"

id_altname <- read_csv(sparql_url(id_altname_query), col_types = "ic")

id_attributes_query <- "
SELECT DISTINCT ?id ?pref_name ?birth_year ?death_year ?nationality ?gender
  WHERE {
    ?artist skos:inScheme ulan: ;
      dc:identifier ?id ;
        rdf:type gvp:PersonConcept ;
        dc:identifier ?id ;
        xl:prefLabel [xl:literalForm ?pref_name] .

    OPTIONAL {
      ?artist foaf:focus [gvp:biographyPreferred ?bio] .
      ?bio gvp:estStart ?birth_year ;
           gvp:estEnd ?death_year .

      OPTIONAL {
        ?bio schema:gender [gvp:prefLabelGVP [gvp:term ?gender]] .
      }
    }

  OPTIONAL {
    ?artist foaf:focus [gvp:nationalityPreferred [xl:prefLabel [gvp:term ?nationality]]] .
    FILTER(langMatches(lang(?nationality), \"EN\"))
  }
}"

id_attributes <- read_csv(sparql_url(id_attributes_query), col_types = "iciicc")

library(dplyr)

query_table <- id_altname %>%
  left_join(id_attributes, by = "id") %>%
  mutate(
    # Strip caps and puncutation, since this alt_name column will be searched
    # via string distance
    alt_name = tolower(gsub("[[:punct:]]", "", alt_name))) %>%
  distinct()

library(devtools)

use_data(query_table, overwrite = TRUE)
