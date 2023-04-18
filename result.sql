-- based on PostgreSQL syntax
-- you can find the result query at the bottom of this file
---------------------------------

-- create tables

CREATE TABLE table_A
(
	dimension_1 VARCHAR,
	dimension_2 VARCHAR,
	dimension_3 VARCHAR,
	measure_1 NUMERIC
);

CREATE TABLE table_B
(
	dimension_1 VARCHAR,
	dimension_2 VARCHAR,
	measure_2 NUMERIC
);

CREATE TABLE table_MAP
(
	dimension_1 VARCHAR,
	correct_dimension_2 VARCHAR
);


-- insert data into tables

INSERT INTO table_A (dimension_1, dimension_2, dimension_3, measure_1)
VALUES
('a', 'I', 'K', 1),
('a', 'J', 'L', 7),
('b', 'I', 'M', 2),
('c', 'J', 'N', 5);
SELECT * FROM table_A;

INSERT INTO table_B (dimension_1, dimension_2, measure_2)
VALUES
('a', 'J', 7),
('b', 'J', 10),
('d', 'J', 4);
SELECT * FROM table_B;

INSERT INTO table_MAP (dimension_1, correct_dimension_2)
VALUES
('a', 'W'),
('a', 'W'),
('b', 'X'),
('c', 'Y'),
('b', 'X'),
('d', 'Z');
SELECT * FROM table_MAP;


-- RESULT

WITH 
-- select distinct values from MAP table
distinct_table_MAP AS(
	SELECT DISTINCT dimension_1, correct_dimension_2 FROM table_MAP
),
-- update table A: map correct dimension 2
updated_table_A AS (
	SELECT a.dimension_1, map.correct_dimension_2 AS dimension_2, a.measure_1 
	FROM table_A a
	LEFT JOIN distinct_table_MAP map
	USING(dimension_1)
),
-- update table B: map correct dimension 2
updated_table_B AS(
	SELECT b.dimension_1, map.correct_dimension_2 as dimension_2, b.measure_2 
	FROM table_B b
	LEFT JOIN distinct_table_MAP map
	USING(dimension_1)
)
SELECT 
	dimension_1, 
	dimension_2, 
	-- aggregate and replace null values
	COALESCE(SUM(measure_1), 0) AS measure_1, 
	COALESCE(SUM(measure_2), 0) AS measure_2
-- retrieve each row from both table A and table B
FROM updated_table_A 
FULL OUTER JOIN updated_table_B
USING(dimension_1, dimension_2)
GROUP BY dimension_1, dimension_2
ORDER BY dimension_1, dimension_2;
