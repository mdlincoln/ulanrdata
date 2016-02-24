library(SPARQL)

# Data dumps retrieved from http://vocab.getty.edu and hosted locally
sparql_endpoint <- "localhost:3030/db/query"

prefixes <- "
PREFIX aat_source_rev: <http://vocab.getty.edu/aat/source/rev/>
PREFIX vann:  <http://purl.org/vocab/vann/>
PREFIX adms:  <http://www.w3.org/ns/adms#>
PREFIX schema: <http://schema.org/>
PREFIX dcat:  <http://www.w3.org/ns/dcat#>
PREFIX wgs:   <http://www.w3.org/2003/01/geo/wgs84_pos#>
PREFIX ulan_rev: <http://vocab.getty.edu/ulan/rev/>
PREFIX tgn_scopeNote: <http://vocab.getty.edu/tgn/scopeNote/>
PREFIX aat_scopeNote: <http://vocab.getty.edu/aat/scopeNote/>
PREFIX luc:   <http://www.ontotext.com/owlim/lucene#>
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX tgn_source: <http://vocab.getty.edu/tgn/source/>
PREFIX dc:    <http://purl.org/dc/elements/1.1/>
PREFIX vaem:  <http://www.linkedmodel.org/schema/vaem#>
PREFIX ulan_rel: <http://vocab.getty.edu/ulan/rel/>
PREFIX foaf:  <http://xmlns.com/foaf/0.1/>
PREFIX iso:   <http://purl.org/iso25964/skos-thes#>
PREFIX sd:    <http://www.w3.org/ns/sparql-service-description#>
PREFIX aat_rel: <http://vocab.getty.edu/aat/rel/>
PREFIX vdpp:  <http://data.lirmm.fr/ontologies/vdpp#>
PREFIX wv:    <http://vocab.org/waiver/terms/>
PREFIX gvp_lang: <http://vocab.getty.edu/language/>
PREFIX bio:   <http://purl.org/vocab/bio/0.1/>
PREFIX aat:   <http://vocab.getty.edu/aat/>
PREFIX owl:   <http://www.w3.org/2002/07/owl#>
PREFIX rr:    <http://www.w3.org/ns/r2rml#>
PREFIX aat_rev: <http://vocab.getty.edu/aat/rev/>
PREFIX ontogeo: <http://www.ontotext.com/owlim/geo#>
PREFIX cc:    <http://creativecommons.org/ns#>
PREFIX xl: <http://www.w3.org/2008/05/skos-xl#>
PREFIX tgn:   <http://vocab.getty.edu/tgn/>
PREFIX tgn_rev: <http://vocab.getty.edu/tgn/rev/>
PREFIX tgn_source_rev: <http://vocab.getty.edu/tgn/source/rev/>
PREFIX fmt:   <http://www.w3.org/ns/formats/>
PREFIX aat_contrib: <http://vocab.getty.edu/aat/contrib/>
PREFIX ulan_source_rev: <http://vocab.getty.edu/ulan/source/rev/>
PREFIX ulan_event: <http://vocab.getty.edu/ulan/event/>
PREFIX ulan_term: <http://vocab.getty.edu/ulan/term/>
PREFIX gvp:   <http://vocab.getty.edu/ontology#>
PREFIX tgn_rel: <http://vocab.getty.edu/tgn/rel/>
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
PREFIX aat_source: <http://vocab.getty.edu/aat/source/>
PREFIX sesame: <http://www.openrdf.org/schema/sesame#>
PREFIX tgn_contrib: <http://vocab.getty.edu/tgn/contrib/>
PREFIX ulan_scopeNote: <http://vocab.getty.edu/ulan/scopeNote/>
PREFIX wdrs:  <http://www.w3.org/2007/05/powder-s#>
PREFIX prov:  <http://www.w3.org/ns/prov#>
PREFIX ptop:  <http://www.ontotext.com/proton/protontop#>
PREFIX ulan:  <http://vocab.getty.edu/ulan/>
PREFIX void:  <http://rdfs.org/ns/void#>
PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
PREFIX ulan_contrib: <http://vocab.getty.edu/ulan/contrib/>
PREFIX voag:  <http://voag.linkedmodel.org/voag#>
PREFIX voaf:  <http://purl.org/vocommons/voaf#>
PREFIX dctype: <http://purl.org/dc/dcmitype/>
PREFIX rrx:   <http://purl.org/r2rml-ext/>
PREFIX dct:   <http://purl.org/dc/terms/>
PREFIX bibo:  <http://purl.org/ontology/bibo/>
PREFIX ulan_source: <http://vocab.getty.edu/ulan/source/>
PREFIX xsd:   <http://www.w3.org/2001/XMLSchema#>
PREFIX tgn_term: <http://vocab.getty.edu/tgn/term/>
PREFIX ulan_bio: <http://vocab.getty.edu/ulan/bio/>
PREFIX skos:  <http://www.w3.org/2004/02/skos/core#>
PREFIX aat_term: <http://vocab.getty.edu/aat/term/>
"

# Retrieve ULAN ID / Preferred Name table
id_prefname_query <- "
SELECT DISTINCT ?id ?pref_name
WHERE {
  ?artist skos:inScheme ulan: ;
          rdf:type gvp:PersonConcept ;
          dc:identifier ?id ;
          xl:prefLabel [xl:literalForm ?pref_name] .
}"

id_prefname <- SPARQL(query = paste0(prefixes, id_prefname_query), url = sparql_endpoint, format = "csv", extra = list(output = "csv"))$results
id_prefname <- data.frame(id = as.integer(id_prefname$id), pref_name = as.character(id_prefname$pref_name), stringsAsFactors = FALSE)
save(id_prefname, file = "data/id_prefname.RData")

# Retrieve ULAN ID / Alternative Name table
id_altname_query <- "
SELECT DISTINCT ?id ?alt_name
WHERE {
  ?artist skos:inScheme ulan: ;
      rdf:type gvp:PersonConcept ;
      dc:identifier ?id ;
      xl:altLabel [xl:literalForm ?alt_name] .
}"

id_altname <- SPARQL(query = paste0(prefixes, id_altname_query), url = sparql_endpoint, format = "csv", extra = list(output = "csv"))$results
id_altname <- data.frame(id = as.integer(id_altname$id), alt_name = as.character(id_altname$alt_name), stringsAsFactors = FALSE)
save(id_altname, file = "data/id_altname.RData")

id_attributes_query <- "
SELECT DISTINCT ?id ?birth ?death ?nationality
  WHERE {
    ?artist skos:inScheme ulan: ;
      dc:identifier ?id ;
        rdf:type gvp:PersonConcept .

    OPTIONAL {
      ?artist foaf:focus [gvp:biographyPreferred ?bio] .
      ?bio gvp:estStart ?birth ;
           gvp:estEnd ?death .
    }

  OPTIONAL {
    ?artist foaf:focus [gvp:nationalityPreferred [xl:prefLabel [gvp:term ?nationality]]] .
    FILTER(langMatches(lang(?nationality), \"EN\"))
  }
}"

id_attributes <- SPARQL(query = paste0(prefixes, id_attributes_query), url = sparql_endpoint, format = "csv", extra = list(output = "csv"))$results
id_attributes <- data.frame(id = as.integer(id_attributes$id), birth = id_attributes$birth, death = id_attributes$death, nationality = as.character(id_attributes$nationality), stringsAsFactors = FALSE)
save(id_attributes, file = "data/id_attributes.RData")

library(dplyr)

query_table <- id_attributes %>%
  inner_join(id_altname, by = "id") %>%
  bind_rows(id_prefname %>% rename(alt_name = pref_name)) %>%
  inner_join(id_prefname, by = "id") %>%
  mutate(alt_name = tolower(gsub("[[:punct:]]", "", alt_name))) %>%
  distinct()
save(query_table, file = "data/query_table.RData")
