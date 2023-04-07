# neodash-us-commodity-flow
NeoDash analysis of US Census 2017 CFS data

Quick start

* import the [dump file](https://drive.google.com/file/d/1qFGvkC4K55wIterbh_q_KklW1bCMfsVy/view?usp=share_link) into a Neo4j 5.5 database

* open NeoDash, connect to Neo4j and import dashboard.json from this repo (you can save your changes back to Neo4j)

Build

* run the queries in load.cyp to ingest the data sets

* run the python notebooks to create the aggregating relationships for Product, NAICS and Mode from the raw :SHIPMENT relationship

* run the queries in gds.cyp to compute Page Rank centrality for the CFS_AREA MSAs with respect to Product and NAICS for both import and export flows

WIP - GHG emissions
