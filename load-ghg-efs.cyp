//load nodes
LOAD CSV WITH HEADERS
FROM 'file:///Users/michaelmoore/Documents/GitHub/neo4j-us-commodity-flow/data/ghg-conversion-factors-2022-flat-format.csv' AS map
FIELDTERMINATOR ','
WITH  apoc.map.clean(map,[],[""]) AS mc
CREATE (f:Factor) SET f+=mc;

MATCH (n:Factor)
WHERE n.Scope IS NULL DELETE n;

//L4
MATCH (n:Factor)
WHERE n.Level_1 IS NOT NULL
AND n.Level_2 IS NOT NULL
AND n.Level_3 IS NOT NULL
AND n.Level_4 IS NOT NULL
WITH COLLECT(n) AS factors
UNWIND factors AS f
MERGE (s:Scope {Scope: f.Scope})
WITH s,f
MERGE (l1:Level_1 {Level_1: f.Level_1})
WITH s,f,l1
MERGE (s)-[:HAS_LEVEL]->(l1)
MERGE (l2:Level_2 {Level_2: f.Level_2,Level_1: f.Level_1})
WITH f,l1,l2
MERGE (l1)-[:HAS_LEVEL]->(l2)
MERGE (l3:Level_3 {Level_3: f.Level_3,Level_2: f.Level_2,Level_1: f.Level_1})
WITH f,l2,l3
MERGE (l2)-[:HAS_LEVEL]->(l3)
MERGE (l4:Level_4 {Level_4: f.Level_4, Level_3: f.Level_3,Level_2: f.Level_2,Level_1: f.Level_1})
WITH f,l3,l4
MERGE (l3)-[:HAS_LEVEL]->(l4)
WITH f,l4
MERGE (l4)-[:HAS_FACTOR]-(f);

//L3
MATCH (n:Factor)
WHERE n.Level_1 IS NOT NULL
AND n.Level_2 IS NOT NULL
AND n.Level_3 IS NOT NULL
AND n.Level_4 IS NULL
WITH COLLECT(n) AS factors
UNWIND factors AS f
MERGE (s:Scope {Scope: f.Scope})
WITH s,f
MERGE (l1:Level_1 {Level_1: f.Level_1})
WITH s,f,l1
MERGE (s)-[:HAS_LEVEL]->(l1)
MERGE (l2:Level_2 {Level_2: f.Level_2,Level_1: f.Level_1})
WITH f,l1,l2
MERGE (l1)-[:HAS_LEVEL]->(l2)
MERGE (l3:Level_3 {Level_3: f.Level_3,Level_2: f.Level_2,Level_1: f.Level_1})
WITH f,l2,l3
MERGE (l2)-[:HAS_LEVEL]->(l3)
WITH f,l3
MERGE (l3)-[:HAS_FACTOR]-(f);

//L2
MATCH (n:Factor)
WHERE n.Level_1 IS NOT NULL
AND n.Level_2 IS NOT NULL
AND n.Level_3 IS NULL
AND n.Level_4 IS NULL
WITH COLLECT(n) AS factors
UNWIND factors AS f
MERGE (s:Scope {Scope: f.Scope})
WITH s,f
MERGE (l1:Level_1 {Level_1: f.Level_1})
WITH s,f,l1
MERGE (s)-[:HAS_LEVEL]->(l1)
MERGE (l2:Level_2 {Level_2: f.Level_2,Level_1: f.Level_1})
WITH f,l1,l2
MERGE (l1)-[:HAS_LEVEL]->(l2)
WITH f,l2
MERGE (l2)-[:HAS_FACTOR]-(f);

//L1
MATCH (n:Factor)
WHERE n.Level_1 IS NOT NULL
AND n.Level_2 IS NULL
AND n.Level_3 IS NULL
AND n.Level_4 IS NULL
WITH COLLECT(n) AS factors
UNWIND factors AS f
MERGE (s:Scope {Scope: f.Scope})
WITH s,f
MERGE (l1:Level_1 {Level_1: f.Level_1})
WITH s,f,l1
MERGE (s)-[:HAS_LEVEL]->(l1)
WITH f,l1
MERGE (l1)-[:HAS_FACTOR]-(f);
