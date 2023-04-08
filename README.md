# neodash-us-commodity-flow
NeoDash analysis of US Census 2017 CFS data

Quick start

* aggregated shipments = > import the [totals dump file](https://drive.google.com/file/d/1aMLFukdmp7GmX2EQljDqIHddal5DIDgw/view?usp=share_link) into a Neo4j 5.5 database

-or-

* all 6M shipments => import the [shipments dump file](https://drive.google.com/file/d/1qFGvkC4K55wIterbh_q_KklW1bCMfsVy/view?usp=share_link) into a Neo4j 5.5 database

-next-

* open NeoDash from the Neo4j desktop, connect to Neo4j and import dashboard.json from this repo (you can save your changes back to Neo4j)

Build

* download the [CFS-2017 Public Use shipments file](https://www2.census.gov/programs-surveys/cfs/datasets/2017/CFS%202017%20PUF%20CSV.zip)

* run the queries in load.cyp to ingest the data sets

* run the python notebooks to create the aggregating relationships for Product, NAICS and Mode from the raw :SHIPMENT relationship

* run the queries in gds-pagerank.cyp to compute Page Rank centrality for the CFS_AREA MSAs with respect to Product and NAICS for both import and export flows

WIP - GHG emissions


Dependencies

copy /misc/apoc.conf to Neo4j /conf folder

Install APOC and Graph Data Science Plugins

Neo4j Settings (neo4j.conf) configurations

```
# This setting constrains all `LOAD CSV` import files to be under the `import` directory. Remove or comment it out to
# allow files to be loaded from anywhere in the filesystem; this introduces possible security problems. See the
# `LOAD CSV` section of the manual for details.
#server.directories.import=import


# Java Heap Size: by default the Java heap size is dynamically calculated based
# on available system resources. Uncomment these lines to set specific initial
# and maximum heap size.
server.memory.heap.initial_size=4g
server.memory.heap.max_size=4g

# The amount of memory to use for mapping the store files.
# The default page cache memory assumes the machine is dedicated to running
# Neo4j, and is heuristically set to 50% of RAM minus the Java heap size.
server.memory.pagecache.size=4g

```

comment out any lines at the bottom of neo4j.conf that conflict with these settings.
