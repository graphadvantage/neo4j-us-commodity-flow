//PageRank MetroAreas by Product Annual Value (cypher Projection - export direction)
CALL apoc.meta.stats() YIELD relTypesCount
WITH keys(relTypesCount) AS rels
MATCH (n:Product)
WHERE n.SUBGRAPH in rels
WITH n.SUBGRAPH as rel
CALL {
    WITH rel

    CALL gds.graph.project.cypher(
    rel,
    'MATCH (n:MetroArea) RETURN id(n) AS id, labels(n) AS labels',
    'MATCH (n)-[r:'+rel+']->(m) RETURN id(n) AS source, id(m) AS target, type(r) AS type, r.TOTAL_ANN_VALUE AS VALUE',
    {}) YIELD graphName

    CALL gds.pageRank.stream(graphName, {relationshipWeightProperty: 'VALUE'}) YIELD nodeId, score

    CALL apoc.get.nodes([nodeId]) YIELD node AS n
    WITH graphName,n,score
    MATCH (p:Product {SUBGRAPH: graphName})
    MERGE (p)-[r:CENTRALITY {SUBGRAPH: graphName}]->(n)
    SET r.DESCRIPTION = p.DESCRIPTION,
    r.SCTG = p.SCTG,
    r.PAGERANK_EXPORT = score

    WITH DISTINCT graphName
    CALL gds.graph.drop(graphName) YIELD graphName AS graph

    RETURN graph

    }
RETURN graph

//PageRank MetroAreas by Product Annual Value (cypher Projection - import direction)
CALL apoc.meta.stats() YIELD relTypesCount
WITH keys(relTypesCount) AS rels
MATCH (n:Product)
WHERE n.SUBGRAPH in rels
WITH n.SUBGRAPH as rel
CALL {
    WITH rel

    CALL gds.graph.project.cypher(
    rel,
    'MATCH (n:MetroArea) RETURN id(n) AS id, labels(n) AS labels',
    'MATCH (n)<-[r:'+rel+']-(m) RETURN id(n) AS source, id(m) AS target, type(r) AS type, r.TOTAL_ANN_VALUE AS VALUE',
    {}) YIELD graphName

    CALL gds.pageRank.stream(graphName, {relationshipWeightProperty: 'VALUE'}) YIELD nodeId, score

    CALL apoc.get.nodes([nodeId]) YIELD node AS n
    WITH graphName,n,score
    MATCH (p:Product {SUBGRAPH: graphName})
    MERGE (p)-[r:CENTRALITY {SUBGRAPH: graphName}]->(n)
    SET r.DESCRIPTION = p.DESCRIPTION,
    r.SCTG = p.SCTG,
    r.PAGERANK_IMPORT = score

    WITH DISTINCT graphName
    CALL gds.graph.drop(graphName) YIELD graphName AS graph

    RETURN graph

    }
RETURN graph

//PageRank MetroAreas by NAICS Annual Value (cypher Projection - export direction)
CALL apoc.meta.stats() YIELD relTypesCount
WITH keys(relTypesCount) AS rels
MATCH (n:NAICS)
WHERE n.SUBGRAPH in rels
WITH n.SUBGRAPH as rel
CALL {
    WITH rel

    CALL gds.graph.project.cypher(
    rel,
    'MATCH (n:MetroArea) RETURN id(n) AS id, labels(n) AS labels',
    'MATCH (n)-[r:'+rel+']->(m) RETURN id(n) AS source, id(m) AS target, type(r) AS type, r.TOTAL_ANN_VALUE AS VALUE',
    {}) YIELD graphName

    CALL gds.pageRank.stream(graphName, {relationshipWeightProperty: 'VALUE'}) YIELD nodeId, score

    CALL apoc.get.nodes([nodeId]) YIELD node AS n
    WITH graphName,n,score
    MATCH (p:NAICS {SUBGRAPH: graphName})
    MERGE (p)-[r:CENTRALITY {SUBGRAPH: graphName}]->(n)
    SET r.DESCRIPTION = p.DESCRIPTION,
    r.NAICS = p.NAICS,
    r.PAGERANK_EXPORT = score

    WITH DISTINCT graphName
    CALL gds.graph.drop(graphName) YIELD graphName AS graph

    RETURN graph

    }
RETURN graph

//PageRank MetroAreas by NAICS Annual Value (cypher Projection - import direction)
CALL apoc.meta.stats() YIELD relTypesCount
WITH keys(relTypesCount) AS rels
MATCH (n:NAICS)
WHERE n.SUBGRAPH in rels
WITH n.SUBGRAPH as rel
CALL {
    WITH rel

    CALL gds.graph.project.cypher(
    rel,
    'MATCH (n:MetroArea) RETURN id(n) AS id, labels(n) AS labels',
    'MATCH (n)<-[r:'+rel+']-(m) RETURN id(n) AS source, id(m) AS target, type(r) AS type, r.TOTAL_ANN_VALUE AS VALUE',
    {}) YIELD graphName

    CALL gds.pageRank.stream(graphName, {relationshipWeightProperty: 'VALUE'}) YIELD nodeId, score

    CALL apoc.get.nodes([nodeId]) YIELD node AS n
    WITH graphName,n,score
    MATCH (p:NAICS {SUBGRAPH: graphName})
    MERGE (p)-[r:CENTRALITY {SUBGRAPH: graphName}]->(n)
    SET r.DESCRIPTION = p.DESCRIPTION,
    r.NAICS = p.NAICS,
    r.PAGERANK_IMPORT = score

    WITH DISTINCT graphName
    CALL gds.graph.drop(graphName) YIELD graphName AS graph

    RETURN graph

    }
RETURN graph
