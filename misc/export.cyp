CALL db.labels() YIELD label
WITH label WHERE NOT label IN ["_Neodash_Dashboard","Total"]
WITH COLLECT(label) AS labels
UNWIND labels AS lbl
CALL {
    WITH lbl
    WITH lbl, 'MATCH (n:' +lbl+ ') RETURN COLLECT(n) AS data' AS query
    CALL apoc.cypher.run(query,{}) YIELD value
    WITH lbl, value.data AS data, 'file:///Users/michaelmoore/Documents/GitHub/neo4j-us-commodity-flow/'+lbl+'.csv' AS path
    CALL apoc.export.csv.data(data,[], path, {delim:'|', quotes:'none'}) YIELD file,rows
    RETURN lbl as exported, file,rows
}
RETURN exported, rows, file
