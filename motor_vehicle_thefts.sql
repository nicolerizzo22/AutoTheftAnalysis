

-- OBJECTIVE #1: Identify WHEN vehicles are likely to be stolen
SELECT * FROM locations;

-- 1. Find the # of vehicles stolen each year
 SELECT YEAR(date_stolen) AS year_stolen, COUNT(vehicle_id) AS num_vehicles
 FROM stolen_vehicles
 GROUP BY year_stolen;
 
 -- 2. Find the # of vehicles stolen each month
SELECT MONTH(date_stolen) AS month_stolen, COUNT(vehicle_id) AS num_vehicles
FROM stolen_vehicles
GROUP BY month_stolen
ORDER BY month_stolen;

-- Include year to get better idea of missing data
SELECT YEAR(date_stolen) AS year_stolen, MONTH(date_stolen) AS month_stolen, 
	COUNT(vehicle_id) AS num_vehicles
FROM stolen_vehicles
GROUP BY year_stolen, month_stolen
ORDER BY year_stolen, month_stolen;

-- Dig deeper into month 4, where a steep drop occurs. 

SELECT YEAR(date_stolen) AS year_stolen, MONTH(date_stolen) AS month_stolen, 
	DAY(date_stolen) AS day_stolen, COUNT(vehicle_id) AS num_vehicles
FROM stolen_vehicles
WHERE MONTH(date_stolen) = 4
GROUP BY year_stolen, month_stolen, day_stolen
ORDER BY year_stolen, month_stolen, day_stolen;

-- The drop is because there is only 6 days worth of data in the 4th month (Apr)
-- Since this is NZ data, she said their summer is december thru march and that is prob what is happening 


-- 3. Find the # of vehicles stolen each day of the week
SELECT DAYOFWEEK(date_stolen) AS day_number, COUNT(vehicle_id) AS num_vehicles
FROM stolen_vehicles
GROUP BY DAYOFWEEK(date_stolen)
ORDER BY day_number;

-- 4. Replace the numeric week values with the full name of each day of the week
SELECT DAYOFWEEK(date_stolen) AS day_number, 
	CASE WHEN DAYOFWEEK(date_stolen) = 1 THEN 'Sunday'
    WHEN DAYOFWEEK(date_stolen) = 2 THEN 'Monday'
    WHEN DAYOFWEEK(date_stolen) = 3 THEN 'Tuesday'
    WHEN DAYOFWEEK(date_stolen) = 4 THEN 'Wednesday'
	WHEN DAYOFWEEK(date_stolen) = 5 THEN 'Thursday'
    WHEN DAYOFWEEK(date_stolen) = 6 THEN 'Friday'
    ELSE 'Saturday' END AS day_name,
COUNT(vehicle_id) AS num_vehicles
FROM stolen_vehicles
GROUP BY DAYOFWEEK(date_stolen), day_name
ORDER BY day_number;


-- there is an accompanying bar chart visual in Excel for this output

-- Objective #2 - Identify WHICH vehicles are likely to be stolen

SELECT * FROM stolen_vehicles;

-- 1. Find the vehicle types that are most often and least often stolen
SELECT vehicle_type, COUNT(vehicle_id) AS num_vehicles
FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY num_vehicles 
LIMIT 5;

-- (remove the DESC to get the least stolen)

-- 2. For each vehicle type, find the average age of the cars (in years) that are stolen
SELECT vehicle_type, ROUND(AVG(YEAR(date_stolen) - model_year), 2) AS avg_age
FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY avg_age DESC;

-- 3. For each vehicle type, find the percent of vehicles stolen that are luxury versus standard
-- that information is not in the stolen_vehicles table, need to review the make_details table
SELECT * FROM stolen_vehicles;
SELECT * FROM make_details;

-- LEFT JOIN the two tables on the 'make_id' field
SELECT *
FROM stolen_vehicles sv LEFT JOIN make_details md
	ON sv.make_id = md.make_id;

-- Prepare this data to get the percent 
SELECT vehicle_type, make_type
FROM stolen_vehicles sv LEFT JOIN make_details md
	ON sv.make_id = md.make_id;

-- To change the text field to a number,  assign a 1 to 'Luxury' vehicles
-- and 0 to 'non-luxury' using a CASE statement
SELECT vehicle_type, CASE WHEN make_type = 'Luxury' THEN 1
						ELSE 0 END AS luxury
FROM stolen_vehicles sv LEFT JOIN make_details md
	ON sv.make_id = md.make_id;

-- To get the denominator value we need a count of vehicles, add the all_cars column 
SELECT vehicle_type, CASE WHEN make_type = 'Luxury' THEN 1
						ELSE 0 END AS luxury,
                        1 AS all_cars
FROM stolen_vehicles sv LEFT JOIN make_details md
	ON sv.make_id = md.make_id;
    
-- Create a CTE with previous results table in order to perform calculations on it
WITH lux_standard AS (SELECT vehicle_type, CASE WHEN make_type = 'Luxury' THEN 1
						ELSE 0 END AS luxury,
                        1 AS all_cars
FROM stolen_vehicles sv LEFT JOIN make_details md
	ON sv.make_id = md.make_id)
    
    
    SELECT vehicle_type, ROUND(SUM(luxury) / SUM(all_cars), 2) * 100 AS pct_lux 
    FROM lux_standard
    GROUP BY vehicle_type
    ORDER BY pct_lux DESC;
    
-- Not surprising, convertibles and sports cars have the highest percent of stolen vehicles. 
-- Another way to get the denominator with out adding the all_cars column would be to simply COUNT the luxury column, same result. 

-- 4. Create a table where the rows represent the top 10 vehicle types, the columns represent the top 7 vehicle colors,
-- (plus 1 column for all other colors) and the values are the number of vehicles stolen.
-- First, review the data contained in the stolen_vehicles table

SELECT * FROM stolen_vehicles;


'Silver', '1272'
'White', '934'
'Black', '589'
'Blue', '512'
'Red', '390'
'Grey', '378'
'Green', '224'
'Other'

-- Query to return the top 7 colors, all other colors will be in 'Other'
SELECT color, COUNT(vehicle_id) AS num_vehicles
FROM stolen_vehicles
GROUP BY color
ORDER BY num_vehicles;

-- Create the pivot table using CASE statement to assign column names 
SELECT vehicle_type, 
	CASE WHEN color = 'Silver' THEN 1 ELSE 0 END AS silver,
    CASE WHEN color = 'White' THEN 1 ELSE 0 END AS white,
    CASE WHEN color = 'Black' THEN 1 ELSE 0 END AS black,
    CASE WHEN color = 'Blue' THEN 1 ELSE 0 END AS blue,
    CASE WHEN color = 'Red' THEN 1 ELSE 0 END AS red,
    CASE WHEN color = 'Grey' THEN 1 ELSE 0 END AS grey,
    CASE WHEN color = 'Green' THEN 1 ELSE 0 END AS green,
	CASE WHEN color IN ('Gold', 'Brown', 'Yellow', 'Orange', 'Purple', 'Cream', 'Pink') THEN 1 ELSE 0 END AS other
FROM stolen_vehicles;

-- Add them up using SUM, only show top 10
SELECT vehicle_type, COUNT(vehicle_id) AS num_vehicles,
	SUM(CASE WHEN color = 'Silver' THEN 1 ELSE 0 END) AS silver,
    SUM(CASE WHEN color = 'White' THEN 1 ELSE 0 END) AS white,
    SUM(CASE WHEN color = 'Black' THEN 1 ELSE 0 END) AS black,
    SUM(CASE WHEN color = 'Blue' THEN 1 ELSE 0 END) AS blue,
    SUM(CASE WHEN color = 'Red' THEN 1 ELSE 0 END) AS red,
    SUM(CASE WHEN color = 'Grey' THEN 1 ELSE 0 END) AS grey,
    SUM(CASE WHEN color = 'Green' THEN 1 ELSE 0 END) AS green,
	SUM(CASE WHEN color IN ('Gold', 'Brown', 'Yellow', 'Orange', 'Purple', 'Cream', 'Pink') 
    THEN 1 ELSE 0 END) AS other
FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY num_vehicles DESC
LIMIT 10;

-- Exported results and created a heat map in Excel to highlight the largest amounts


-- Objective #3 - Identify WHERE vehicles are likely to be stolen

-- 1. Find the number of vehicles that were stolen in each region (review table data)
SELECT * FROM stolen_vehicles;
SELECT * FROM locations;

-- Join the two tables on 'location_id' field
SELECT *
FROM stolen_vehicles sv LEFT JOIN locations loc
	ON sv.location_id = loc.location_id;



-- Filter & group the data 
SELECT loc.region, COUNT(vehicle_id) AS num_vehicles
FROM stolen_vehicles sv LEFT JOIN locations loc
	ON sv.location_id = loc.location_id
GROUP BY loc.region
ORDER BY num_vehicles DESC;

-- 2. Combine the previous output with the population and density statistics for each region
SELECT loc.region, COUNT(sv.vehicle_id) AS num_vehicles, loc.population, loc.density	
FROM stolen_vehicles sv LEFT JOIN locations loc
	ON sv.location_id = loc.location_id
GROUP BY loc.region, loc.population, loc.density
ORDER BY num_vehicles DESC;



-- 3. Do the types of vehicles stolen in the 3 most dense regions differ from the 3 least dense regions?
-- First, find the 3 most and 3 least dense regions. 

SELECT loc.region, COUNT(sv.vehicle_id) AS num_vehicles, loc.population, loc.density	
FROM stolen_vehicles sv LEFT JOIN locations loc
	ON sv.location_id = loc.location_id
GROUP BY loc.region, loc.population, loc.density
ORDER BY loc.density DESC
LIMIT 3;


'Columbus', '1638', '1695200', '343.09'
'Dalton', '92', '54500', '129.15'
'Johns Creek', '420', '543500', '67.52'

'Brunswick', '139', '246000', '7.89'
'Savannah', '176', '52100', '6.21'
'Hinesville', '26', '102400', '3.28'

SELECT sv.vehicle_type, COUNT(sv.vehicle_id) AS num_vehicles
FROM stolen_vehicles sv LEFT JOIN locations loc
	ON sv.location_id = loc.location_id
    WHERE loc.region IN ('Columbus', 'Dalton', 'Johns Creek')
    GROUP BY sv.vehicle_type
    ORDER BY num_vehicles DESC
    LIMIT 3;

-- output here shows Stationwagons, Saloons and Hatchbacks were the 3 most popular type of vehicle stolen in the 3 most dense regions.

SELECT sv.vehicle_type, COUNT(sv.vehicle_id) AS num_vehicles
FROM stolen_vehicles sv LEFT JOIN locations loc
	ON sv.location_id = loc.location_id
    WHERE loc.region IN ('Brunswick', 'Savannah', 'Hinesville')
    GROUP BY sv.vehicle_type
    ORDER BY num_vehicles DESC
    LIMIT 3;

-- output here shows Stationwagons, Saloons and Utilities were the 3 most popular type of vehicle stolen in the 3 least dense regions.

-- since the queries have the same fields, to see both sets of results, combine the two separate queries with a UNION, 
-- add in descriptor column for easy visual identification & limit to top 5 for an even clearer result set

(SELECT 'High Density', sv.vehicle_type, COUNT(sv.vehicle_id) AS num_vehicles
FROM stolen_vehicles sv LEFT JOIN locations loc
	ON sv.location_id = loc.location_id
WHERE loc.region IN ('Columbus', 'Dalton', 'Johns Creek')
GROUP BY sv.vehicle_type
ORDER BY num_vehicles DESC
LIMIT 5)

UNION

(SELECT 'Low Density', sv.vehicle_type, COUNT(sv.vehicle_id) AS num_vehicles
FROM stolen_vehicles sv LEFT JOIN locations loc
	ON sv.location_id = loc.location_id
WHERE loc.region IN ('Brunswick', 'Savannah', 'Hinesville')
GROUP BY sv.vehicle_type
ORDER BY num_vehicles DESC
LIMIT 5);

-- 4. Create a scatterplot of population vs. density