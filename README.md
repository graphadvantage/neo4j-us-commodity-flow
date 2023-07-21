# neodash-us-commodity-flow
NeoDash analysis of US Census 2017 CFS data

Quick start
* install Neo4j from https://neo4j.com/download-center/, install plugins for Apoc, Graph Data Science

* download and import the [neo4j.dump file](https://drive.google.com/file/d/1gR24H5ngbRvklwDPHpP1k94lqutO5DXN/view?usp=sharing) into a Neo4j 5.10 database

```
./bin/neo4j-admin load --force --database=neo4j --from=[PATH TO]/neo4j.dump
```

* install and launch NeoDash from the Neo4j desktop, connect to Neo4j and import dashboard.json from this repo or load it from the Neo4j database

Build

* download the [CFS-2017 Public Use shipments file](https://www2.census.gov/programs-surveys/cfs/datasets/2017/CFS%202017%20PUF%20CSV.zip)

* run the queries in load.cyp to ingest the data sets

* run the python notebook to create the aggregating relationships for Product, NAICS, Mode and HAZMAT from the raw :SHIPMENT relationships

* run the queries in gds-pagerank.cyp to compute Page Rank centrality for the CFS_AREA MSAs with respect to Product and NAICS for both import and export flows

Dependencies

copy /misc/apoc.conf to Neo4j /conf folder

install [Apoc](https://github.com/neo4j/apoc/releases), [Apoc Extended](https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases) and [Graph Data Science Plugins](https://github.com/neo4j/graph-data-science/releases)


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
