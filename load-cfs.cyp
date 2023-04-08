//https://www.census.gov/data/datasets/2017/econ/cfs/historical-datasets.html
//https://www.census.gov/data/tables/2017/econ/cfs/aff-2017.html
//https://mcdc.missouri.edu/geography/sumlevs/index.html
//https://github.com/TuunicoApp/US_Census_Maps
//https://www.census.gov/programs-surveys/cfs/technical-documentation/geographies.html


//load Shipments, as rels from/to Metro Areas
LOAD CSV WITH HEADERS
FROM 'file:////Users/michaelmoore/Documents/GitHub/neo4j-us-commodity-flow/data/CFS_2017_PUF_CSV.csv' AS map
FIELDTERMINATOR ','
WITH  apoc.map.clean(map,[],['']) AS s
CALL {
  WITH s
  MERGE (o:MetroArea {CFS_AREA: s.ORIG_CFS_AREA})
  WITH s,o
  MERGE (d:MetroArea {CFS_AREA: s.DEST_CFS_AREA})
  WITH s,o,d
  CREATE (o)-[r:SHIPMENT {SHIPMT_ID: s.SHIPMT_ID}]->(d)
  SET r+=s,
  r.SHIPMT_DIST_ROUTED = toInteger(s.SHIPMT_DIST_ROUTED),
  r.SHIPMT_DIST_GC = toInteger(s.SHIPMT_DIST_GC),
  r.SHIPMT_WGHT = toInteger(s.SHIPMT_WGHT),
  r.WGT_FACTOR = toInteger(s.WGT_FACTOR),
  r.SHIPMT_VALUE = toInteger(s.SHIPMT_VALUE),
  r.SCTG = 'SCTG_'+ s.SCTG,
  r.MODE = 'MODE_'+ s.MODE
} IN TRANSACTIONS OF 1000 ROWS;

// create text indexes on SHIPMENT rels for later aggregation lookups
CREATE TEXT INDEX SCTG FOR ()-[r:SHIPMENT]-() ON (r.SCTG);
CREATE TEXT INDEX NAICS FOR ()-[r:SHIPMENT]-() ON (r.NAICS);
CREATE TEXT INDEX MODE FOR ()-[r:SHIPMENT]-() ON (r.MODE);

//load Metrics
LOAD CSV WITH HEADERS
FROM 'file:///Users/michaelmoore/Documents/GitHub/neo4j-us-commodity-flow/data/Metric.csv' AS map
FIELDTERMINATOR '|'
WITH apoc.map.clean(map,['_id','_start','_end','_type','_id','_labels'],['']) AS mc
MERGE (n:Metric {METRIC: mc.METRIC});

//load MetroAreas
LOAD CSV WITH HEADERS
FROM 'file:///Users/michaelmoore/Documents/GitHub/neo4j-us-commodity-flow/data/MetroArea.csv' AS map
FIELDTERMINATOR '|'
WITH apoc.map.clean(map,['_id','_start','_end','_type','_id','_labels'],['']) AS mc
MERGE (n:MetroArea {CFS_AREA: mc.CFS_AREA});

//load Modes
LOAD CSV WITH HEADERS
FROM 'file:///Users/michaelmoore/Documents/GitHub/neo4j-us-commodity-flow/data/Mode.csv' AS map
FIELDTERMINATOR '|'
WITH apoc.map.clean(map,['_id','_start','_end','_type','_id','_labels'],['']) AS mc
MERGE (n:Mode {MODE: mc.MODE});

//load NAICS
LOAD CSV WITH HEADERS
FROM 'file:///Users/michaelmoore/Documents/GitHub/neo4j-us-commodity-flow/data/NAICS.csv' AS map
FIELDTERMINATOR '|'
WITH apoc.map.clean(map,['_id','_start','_end','_type','_id','_labels'],['']) AS mc
MERGE (n:NAICS {NAICS: mc.NAICS});

//load Products
LOAD CSV WITH HEADERS
FROM 'file:///Users/michaelmoore/Documents/GitHub/neo4j-us-commodity-flow/data/Product.csv' AS map
FIELDTERMINATOR '|'
WITH apoc.map.clean(map,['_id','_start','_end','_type','_id','_labels'],['']) AS mc
MERGE (n:Product {SCTG: mc.SCTG});

// load Totals node (for NeoDash parameter 'ALL')
MERGE (n:Total:Product:NAICS:Mode)
SET n.SUBGRAPH = 'TOTAL_2017_SHIPMENTS', n.DESCRIPTION ='ALL', n.YEAR = '2017'

//load States
LOAD CSV WITH HEADERS
FROM 'file:///Users/michaelmoore/Documents/GitHub/neo4j-us-commodity-flow/data/State.csv' AS map
FIELDTERMINATOR '|'
WITH apoc.map.clean(map,['_id','_start','_end','_type','_id','_labels'],['']) AS mc
MERGE (n:State {GEOID: mc.GEOID});

//join States to Metros
MATCH (n:MetroArea),(s:State)
WHERE n.STATE = s.GEOID
MERGE (s)-[:HAS_MSA]->(n)
WITH n,s
SET n.STUSPS = s.STUSPS, n.NAME = s.NAME;

//create 2017 annual totals, for every combination of MetroAreas
//calculations are from the cfs_2017_puf_users_guide.pdf
CALL apoc.periodic.iterate("
MATCH (n:MetroArea)
WITH COLLECT(n) AS metros
UNWIND metros AS o
UNWIND metros AS d
RETURN o,d
","
MATCH (o)-[s:SHIPMENT]->(d)
WHERE NOT (o)-[:TOTAL_2017_SHIPMENTS]->(d)
WITH o,d,s,
s.WGT_FACTOR * s.SHIPMT_VALUE AS value,
s.WGT_FACTOR * (s.SHIPMT_WGHT*1.0)/2000 AS tonnage,
s.WGT_FACTOR * (s.SHIPMT_WGHT*1.0)/2000 * s.SHIPMT_DIST_ROUTED AS ton_miles,
s.WGT_FACTOR * s.SHIPMT_DIST_ROUTED AS wgt_miles,
s.WGT_FACTOR AS factor,
s.SHIPMT_DIST_ROUTED AS dist_routed,
s.SHIPMT_DIST_GC AS dist_routed_gc
WITH o,d,
COUNT(s) AS TOTAL_ANN_SHIPMENTS,
SUM(factor) AS sum_wgt_factor,
ROUND(SUM(value)) AS TOTAL_ANN_VALUE,
ROUND(SUM(tonnage)) AS TOTAL_ANN_TONNAGE,
ROUND(SUM(ton_miles)) AS TOTAL_ANN_TON_MILES,
ROUND(SUM(wgt_miles)) AS TOTAL_ANN_WGT_MILES,
ROUND(SUM(dist_routed)) AS TOTAL_ANN_MILES,
ROUND(SUM(dist_routed_gc)) AS TOTAL_ANN_MILES_GC
CREATE (o)-[r:TOTAL_2017_SHIPMENTS]->(d)
SET
r.TOTAL_ANN_SHIPMENTS = TOTAL_ANN_SHIPMENTS,
r.TOTAL_ANN_VALUE = TOTAL_ANN_VALUE,
r.TOTAL_ANN_TONNAGE = TOTAL_ANN_TONNAGE,
r.TOTAL_ANN_TON_MILES = TOTAL_ANN_TON_MILES,
r.TOTAL_ANN_WGT_MILES = TOTAL_ANN_WGT_MILES,
r.TOTAL_ANN_MILES = TOTAL_ANN_MILES,
r.TOTAL_ANN_MILES_GC = TOTAL_ANN_MILES_GC,
r.TOTAL_AVG_MILES_PER_SHIPMENT = ROUND((TOTAL_ANN_WGT_MILES*1.0)/sum_wgt_factor)
", {batchSize:10000, iterateList:true, parallel:false});

// now run the jupyter notebooks to compute the annual summaries by NAICS, Product and Mode
