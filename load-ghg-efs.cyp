
//https://www.bts.gov/content/us-tonne-kilometers-freight-bts-special-tabulation
//1 tonne-kilometer = 0.684945 ton-miles.
//1.459972 tonne-kilometers = 1 ton mile
//f.GHG_CONVERSION_FACTOR_2022
// ton-miles*1.459972* "0.01305" kg CO2e of CO2 per tonne.km UOM


//load nodes, make property keys upper case along the way
LOAD CSV WITH HEADERS
FROM 'file:///Users/michaelmoore/Documents/GitHub/neo4j-us-commodity-flow/downloads/ghg-conversion-factors-2022-flat-format.csv' AS map
FIELDTERMINATOR ','
WITH  apoc.map.clean(map,[],[""]) AS mc
WITH {} AS m, [i IN keys(mc) | [toUpper(i),apoc.map.get(mc,i)] ] AS pairs
WITH apoc.map.setPairs(m,pairs) AS m
CREATE (f:Factor) SET f+=m;

MATCH (n:Factor)
WHERE n.SCOPE IS NULL DELETE n;

//L4
MATCH (n:Factor)
WHERE n.LEVEL_1 IS NOT NULL
AND n.LEVEL_2 IS NOT NULL
AND n.LEVEL_3 IS NOT NULL
AND n.LEVEL_4 IS NOT NULL
WITH COLLECT(n) AS factors
UNWIND factors AS f
MERGE (s:Scope {SCOPE: f.SCOPE})
WITH s,f
MERGE (l1:Level_1 {LEVEL_1: f.LEVEL_1})
WITH s,f,l1
MERGE (s)-[:HAS_LEVEL]->(l1)
MERGE (l2:Level_2 {LEVEL_2: f.LEVEL_2,LEVEL_1: f.LEVEL_1})
WITH f,l1,l2
MERGE (l1)-[:HAS_LEVEL]->(l2)
MERGE (l3:Level_3 {LEVEL_3: f.LEVEL_3,LEVEL_2: f.LEVEL_2,LEVEL_1: f.LEVEL_1})
WITH f,l2,l3
MERGE (l2)-[:HAS_LEVEL]->(l3)
MERGE (l4:Level_4 {LEVEL_4: f.LEVEL_4, LEVEL_3: f.LEVEL_3,LEVEL_2: f.LEVEL_2,LEVEL_1: f.LEVEL_1})
WITH f,l3,l4
MERGE (l3)-[:HAS_LEVEL]->(l4)
WITH f,l4
MERGE (l4)-[:HAS_FACTOR]-(f);

//L3
MATCH (n:Factor)
WHERE n.LEVEL_1 IS NOT NULL
AND n.LEVEL_2 IS NOT NULL
AND n.LEVEL_3 IS NOT NULL
AND n.LEVEL_4 IS NULL
WITH COLLECT(n) AS factors
UNWIND factors AS f
MERGE (s:Scope {SCOPE: f.SCOPE})
WITH s,f
MERGE (l1:Level_1 {LEVEL_1: f.LEVEL_1})
WITH s,f,l1
MERGE (s)-[:HAS_LEVEL]->(l1)
MERGE (l2:Level_2 {LEVEL_2: f.LEVEL_2,LEVEL_1: f.LEVEL_1})
WITH f,l1,l2
MERGE (l1)-[:HAS_LEVEL]->(l2)
MERGE (l3:Level_3 {LEVEL_3: f.LEVEL_3,LEVEL_2: f.LEVEL_2,LEVEL_1: f.LEVEL_1})
WITH f,l2,l3
MERGE (l2)-[:HAS_LEVEL]->(l3)
WITH f,l3
MERGE (l3)-[:HAS_FACTOR]-(f);

//L2
MATCH (n:Factor)
WHERE n.LEVEL_1 IS NOT NULL
AND n.LEVEL_2 IS NOT NULL
AND n.LEVEL_3 IS NULL
AND n.LEVEL_4 IS NULL
WITH COLLECT(n) AS factors
UNWIND factors AS f
MERGE (s:Scope {SCOPE: f.SCOPE})
WITH s,f
MERGE (l1:Level_1 {LEVEL_1: f.LEVEL_1})
WITH s,f,l1
MERGE (s)-[:HAS_LEVEL]->(l1)
MERGE (l2:Level_2 {LEVEL_2: f.LEVEL_2,LEVEL_1: f.LEVEL_1})
WITH f,l1,l2
MERGE (l1)-[:HAS_LEVEL]->(l2)
WITH f,l2
MERGE (l2)-[:HAS_FACTOR]-(f);

//L1
MATCH (n:Factor)
WHERE n.LEVEL_1 IS NOT NULL
AND n.LEVEL_2 IS NULL
AND n.LEVEL_3 IS NULL
AND n.LEVEL_4 IS NULL
WITH COLLECT(n) AS factors
UNWIND factors AS f
MERGE (s:Scope {SCOPE: f.SCOPE})
WITH s,f
MERGE (l1:Level_1 {LEVEL_1: f.LEVEL_1})
WITH s,f,l1
MERGE (s)-[:HAS_LEVEL]->(l1)
WITH f,l1
MERGE (l1)-[:HAS_FACTOR]-(f);


MATCH path = (s:Scope {SCOPE: 'Scope 3'})--(l:Level_1 {LEVEL_1: 'Freighting goods'})-[*]->(f:Factor {UOM: 'tonne.km', GHG_UNIT: 'kg CO2e of CO2'})
WHERE f.GHG_CONVERSION_FACTOR_2022 IS NOT NULL
AND (f.LEVEL_4 IN ["Average"," All dwt"] OR f.LEVEL_4 IS NULL)
AND (f.DESCRIPTION IN ["Unknown","Average laden"] OR f.DESCRIPTION IS NULL)
RETURN f.DESCRIPTION, f.GHG_CONVERSION_FACTOR_2022, f.GHG_UNIT, f.LEVEL_1, f.LEVEL_2, f.LEVEL_3, f.LEVEL_4


MATCH p=()-[r:SHIPMENT]->()
WITH r.MODE AS mode, r.TEMP_CNTL_YN as refrigerated, COUNT(r) as shipments
MATCH (m:Mode {MODE: mode})
RETURN m.MODE, m.DESCRIPTION, refrigerated, shipments ORDER BY m.MODE
