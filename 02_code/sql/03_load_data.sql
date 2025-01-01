# Insert data into the borough table ;
INSERT INTO nyc_parking.borough (borough)
SELECT		DISTINCT boroname
FROM		nyc_parking.road_stg ;

# Insert data into the street table ;
INSERT INTO nyc_parking.street (borough_id, street_name)
SELECT		DISTINCT
			b.borough_id, 
			s.full_stree
FROM		nyc_parking.road_stg s
LEFT JOIN	nyc_parking.borough b
ON			b.borough = s.boroname 
WHERE		UPPER(s.boroname) = 'BROOKLYN' AND
			CAST(s.rw_type AS UNSIGNED) < 5 ;

# Insert data into the block table
INSERT INTO nyc_parking.block (physicalid, street_id, geometry, rw_type, st_width, trafdir, segment_ty, shape_length, bike_lane, bike_trafd, frm_lvl_co, to_lvl_co, status, date_time_modif, date_time_created, post_direct, post_modified, post_type, pre_direct, pre_modified, pre_type)
SELECT		DISTINCT 
			CAST(physicalid AS UNSIGNED)															#INT UNSIGNED NOT NULL # Primary key
			,s.street_id 																			#INT UNSIGNED # Foreign key to street data
			,ST_GeomFromText(geometry_wkt, 2263) AS geometry 												#LINESTRING
			,rw_type																				#TINYINT
			,CAST(st_width AS UNSIGNED)																#SMALLINT
			,trafdir																				#ENUM('TW', 'TF', 'FT', 'NV')
			,segment_ty																				#ENUM('U', 'T', 'R', 'E', 'S', 'B', 'C')
			,CAST(r.shape_leng AS DECIMAL(10,5))
			,CAST(r.bike_lane AS UNSIGNED)															#TINYINT
			,r.bike_trafd																			#ENUM('TW', 'TF', 'FT')
			,CAST(r.frm_lvl_co AS UNSIGNED)															#TINYINT
			,CAST(r.to_lvl_co AS UNSIGNED) 															#TINYINT
			,CAST(r.status AS UNSIGNED)																#TINYINT
			,CONCAT(CAST(r.date_modif AS DATE), ' ', CAST(r.time_modif AS TIME)) AS date_time_modif	#DATETIME
			,CONCAT(CAST(r.date_creat AS DATE), ' ', CAST(r.time_creat AS TIME)) AS date_time_creat	#DATETIME
			,r.post_direc																			#ENUM('N', 'E', 'S', 'W', 'NE', 'NW', 'SE', 'SW')
			,r.post_modif																			#VARCHAR(12)
			,r.post_type																			#VARCHAR(5)
			,r.pre_direct																			#ENUM('N', 'E', 'S', 'W', 'NE', 'NW', 'SE', 'SW')
			,r.pre_modifi																			#VARCHAR(6)
			,r.pre_type																				#VARCHAR(5)
FROM		nyc_parking.road_stg r
LEFT JOIN	nyc_parking.street s
ON			r.full_stree = s.street_name 
WHERE		UPPER(r.boroname) = 'BROOKLYN' AND
			CAST(r.rw_type AS UNSIGNED) < 5 AND
            physicalid IN (	SELECT		physicalid
							FROM		nyc_parking.road_stg
							GROUP BY	physicalid
							HAVING		COUNT(*) = 1) ;

# Insert data into the curb table ;
INSERT INTO nyc_parking.curb (physicalid, curb_side, geometry)
SELECT		DISTINCT
			physicalid,
			'L' AS curb_side,
            ST_geomfromtext(l_curb_wkt, 2263) AS geometry
FROM 		nyc_parking.road_stg
WHERE		UPPER(boroname) = 'BROOKLYN' AND
			CAST(rw_type AS UNSIGNED) < 5 AND
            physicalid IN (SELECT physicalid FROM nyc_parking.road_stg GROUP BY physicalid HAVING COUNT(*) = 1)
UNION ALL
SELECT		DISTINCT
			physicalid,
			'R' AS curb_side,
            ST_geomfromtext(r_curb_wkt, 2263)
FROM 		nyc_parking.road_stg
WHERE		UPPER(boroname) = 'BROOKLYN' AND
			CAST(rw_type AS UNSIGNED) < 5 AND
            physicalid IN (SELECT physicalid FROM nyc_parking.road_stg GROUP BY physicalid HAVING COUNT(*) = 1) ;

# Insert data into the sign order table
INSERT INTO nyc_parking.sign_order (order_number, record_type, order_type, street_id, side_of_street)
SELECT		DISTINCT
			r.order_number,
            r.record_type,
            r.order_type,
            s.street_id,
            r.side_of_street
FROM		nyc_parking.street s
LEFT JOIN	nyc_parking.sign_stg r
ON			s.street_name = r.full_stree AND borough_id = 5
WHERE		UPPER(r.borough) = 'BROOKLYN' AND
			r.sign_description LIKE '%SANITATION BROOM SYMBOL%' ;
            
# Insert data into the sign description table
INSERT INTO nyc_parking.sign_description (sign_code, sign_description, sign_design_voided_on_date)
SELECT		DISTINCT
			s.sign_code,
            s.sign_description,
			STR_TO_DATE(s.sign_design_voided_on_date, '%m/%d/%Y') AS sign_design_voided_on_date
FROM		nyc_parking.sign_stg s
WHERE		UPPER(borough) = 'BROOKLYN' AND
			sign_description LIKE '%SANITATION BROOM SYMBOL%' ;

# Insert data into the restrictions table
INSERT INTO nyc_parking.restrict (monday, tuesday, wednesday, thursday, friday, saturday, sunday, start_time, end_time)
WITH temp AS (
SELECT		*,
			REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(sign_description), 'NOON', '12:00PM') , ' TO ', '-'), 'MIDNIGHT', '12:00AM') , 'AM ', 'AM-') , 'PM ', 'PM-') AS desc_new,
			CASE 
				WHEN 	UPPER(sign_description) LIKE '%MONDAY%' OR 
						UPPER(sign_description) LIKE '%MON%' THEN 1
				ELSE	0
			END AS monday,
			CASE 
				WHEN 	UPPER(sign_description) LIKE '%TUESDAY%' OR 
						UPPER(sign_description) LIKE '%TUES%' OR 
						UPPER(sign_description) LIKE '%TUE%' THEN 1
				ELSE	0
			END AS tuesday,
			CASE 
				WHEN 	UPPER(sign_description) LIKE '%WEDNESDAY%' OR 
						UPPER(sign_description) LIKE '%WED%' THEN 1
				ELSE	0
			END AS wednesday,
			CASE 
				WHEN 	UPPER(sign_description) LIKE '%THURSDAY%' OR 
						UPPER(sign_description) LIKE '%THURS%' OR 
                        UPPER(sign_description) LIKE '%THURS%' OR 
						UPPER(sign_description) LIKE '%THU%' THEN 1
				ELSE	0
			END AS thursday,
			CASE 
				WHEN 	UPPER(sign_description) LIKE '%FRIDAY%' OR 
						UPPER(sign_description) LIKE '%FRI%' THEN 1
				ELSE	0
			END AS friday,
			CASE 
				WHEN 	UPPER(sign_description) LIKE '%SATURDAY%' OR 
						UPPER(sign_description) LIKE '%SAT%' THEN 1
				ELSE	0
			END AS saturday,
			CASE 
				WHEN 	UPPER(sign_description) LIKE '%SUNDAY%' OR 
						UPPER(sign_description) LIKE '%SUN%' THEN 1
				ELSE	0
			END AS sunday
FROM		nyc_parking.sign_description
),

temp_time AS (
SELECT		sign_code,
			sign_description,
            desc_new,
            ## Invert day of the week columns
			CASE WHEN desc_new LIKE '%EXCEPT%' THEN NOT monday ELSE monday END AS monday,
			CASE WHEN desc_new LIKE '%EXCEPT%' THEN NOT tuesday ELSE tuesday END AS tuesday,
			CASE WHEN desc_new LIKE '%EXCEPT%' THEN NOT wednesday ELSE wednesday END AS wednesday,
			CASE WHEN desc_new LIKE '%EXCEPT%' THEN NOT thursday ELSE thursday END AS thursday,
			CASE WHEN desc_new LIKE '%EXCEPT%' THEN NOT friday ELSE friday END AS friday,
			CASE WHEN desc_new LIKE '%EXCEPT%' THEN NOT saturday ELSE saturday END AS saturday,
			CASE WHEN desc_new LIKE '%EXCEPT%' THEN NOT sunday ELSE sunday END AS sunday,
			
            # Extract start/end time/symbol
			TRIM(REGEXP_SUBSTR(desc_new, '\\b\\d{1,2}[:]{0,1}\\d{0,2}(?=[APM]{0,2}-)')) AS start_time, 
			TRIM(REGEXP_SUBSTR(desc_new, '(?<=\\d{1,2}[:]{0,1}\\d{0,2})([APM]{2})(?=-)')) AS start_symbol,
			TRIM(REGEXP_SUBSTR(desc_new, '(?<=-)(\\d{1,2}[:]{0,1}\\d{0,2})(?=[APM]{0,2})')) AS end_time,
			TRIM(REGEXP_SUBSTR(desc_new, '(?<=-\\d{1,2}[:]{0,1}\\d{0,2})([APM]{2})')) AS end_symbol    
FROM		temp ),

temp3 AS (
SELECT		sign_code,
			sign_description,
            desc_new,
            monday,
            tuesday,
            wednesday,
            thursday,
            friday,
            saturday,
            sunday,
            CASE WHEN start_time NOT LIKE '%:%' THEN CONCAT(start_time, ':00') ELSE start_time END AS start_time,
            start_symbol,
            CASE WHEN end_time NOT LIKE '%:%' THEN CONCAT(end_time, ':00') ELSE end_time END AS end_time,
            end_symbol
FROM		temp_time )

SELECT		DISTINCT 
			monday, 
			tuesday, 
            wednesday, 
            thursday, 
            friday, 
            saturday, 
            sunday, 
            CASE 
				WHEN UPPER(start_symbol) = 'AM' AND start_time != '12:00' THEN CAST(start_time AS time)
				WHEN UPPER(start_symbol) = 'AM' AND start_time  = '12:00' THEN '00:00:00'
                WHEN UPPER(start_symbol) = 'PM' AND start_time != '12:00' THEN ADDTIME(CAST(start_time AS time), '12:00:00')
                WHEN UPPER(start_symbol) = 'PM' AND start_time  = '12:00' THEN '12:00:00'
			END AS start_time_new,
            CASE
				WHEN UPPER(end_symbol) = 'AM' AND end_time != '12:00' THEN CAST(end_time AS time)
				WHEN UPPER(end_symbol) = 'AM' AND end_time  = '12:00' THEN '11:59:59'
                WHEN UPPER(end_symbol) = 'PM' AND end_time != '12:00' THEN ADDTIME(CAST(end_time AS time), '12:00:00')
                WHEN UPPER(end_symbol) = 'PM' AND end_time  = '12:00' THEN '12:00:00'
			END AS end_time_new
FROM		temp3 ;

# Insert retriction ID into the sign description table
UPDATE 		nyc_parking.sign_description sd
JOIN		( 
WITH temp AS (
SELECT		*,
			# Make initial replacements to make parsing the text easier
			REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(sign_description), 'NOON', '12:00PM') , ' TO ', '-'), 'MIDNIGHT', '12:00AM') , 'AM ', 'AM-') , 'PM ', 'PM-') AS desc_new,
			CASE # Identify signs that apply to Monday
				WHEN 	UPPER(sign_description) LIKE '%MONDAY%' OR 
						UPPER(sign_description) LIKE '%MON%' THEN 1
				ELSE	0
			END AS monday,
			CASE # Identify signs that apply to Thursday
				WHEN 	UPPER(sign_description) LIKE '%TUESDAY%' OR 
						UPPER(sign_description) LIKE '%TUES%' OR 
						UPPER(sign_description) LIKE '%TUE%' THEN 1
				ELSE	0
			END AS tuesday,
			CASE # Identify signs that apply to Wednesday
				WHEN 	UPPER(sign_description) LIKE '%WEDNESDAY%' OR 
						UPPER(sign_description) LIKE '%WED%' THEN 1
				ELSE	0
			END AS wednesday,
			CASE # Identify signs that apply to Thursday
				WHEN 	UPPER(sign_description) LIKE '%THURSDAY%' OR 
						UPPER(sign_description) LIKE '%THURS%' OR 
                        UPPER(sign_description) LIKE '%THURS%' OR 
						UPPER(sign_description) LIKE '%THU%' THEN 1
				ELSE	0
			END AS thursday,
			CASE # Identify signs that apply to Friday
				WHEN 	UPPER(sign_description) LIKE '%FRIDAY%' OR 
						UPPER(sign_description) LIKE '%FRI%' THEN 1
				ELSE	0
			END AS friday,
			CASE # Identify signs that apply to Monday
				WHEN 	UPPER(sign_description) LIKE '%SATURDAY%' OR 
						UPPER(sign_description) LIKE '%SAT%' THEN 1
				ELSE	0
			END AS saturday,
			CASE 
				WHEN 	UPPER(sign_description) LIKE '%SUNDAY%' OR 
						UPPER(sign_description) LIKE '%SUN%' THEN 1
				ELSE	0
			END AS sunday
FROM		nyc_parking.sign_description
),

temp_time AS (
SELECT		sign_code,
			sign_description,
            desc_new,
            ## Invert day of the week columns when the sign contains the word 'EXCEPT'
			CASE WHEN desc_new LIKE '%EXCEPT%' THEN NOT monday ELSE monday END AS monday,
			CASE WHEN desc_new LIKE '%EXCEPT%' THEN NOT tuesday ELSE tuesday END AS tuesday,
			CASE WHEN desc_new LIKE '%EXCEPT%' THEN NOT wednesday ELSE wednesday END AS wednesday,
			CASE WHEN desc_new LIKE '%EXCEPT%' THEN NOT thursday ELSE thursday END AS thursday,
			CASE WHEN desc_new LIKE '%EXCEPT%' THEN NOT friday ELSE friday END AS friday,
			CASE WHEN desc_new LIKE '%EXCEPT%' THEN NOT saturday ELSE saturday END AS saturday,
			CASE WHEN desc_new LIKE '%EXCEPT%' THEN NOT sunday ELSE sunday END AS sunday,
			
            # Extract start/end time/symbol
			TRIM(REGEXP_SUBSTR(desc_new, '\\b\\d{1,2}[:]{0,1}\\d{0,2}(?=[APM]{0,2}-)')) AS start_time, 
			TRIM(REGEXP_SUBSTR(desc_new, '(?<=\\d{1,2}[:]{0,1}\\d{0,2})([APM]{2})(?=-)')) AS start_symbol,
			TRIM(REGEXP_SUBSTR(desc_new, '(?<=-)(\\d{1,2}[:]{0,1}\\d{0,2})(?=[APM]{0,2})')) AS end_time,
			TRIM(REGEXP_SUBSTR(desc_new, '(?<=-\\d{1,2}[:]{0,1}\\d{0,2})([APM]{2})')) AS end_symbol    
FROM		temp ),

temp3 AS (
SELECT		sign_code,
			sign_description,
            desc_new,
            monday,
            tuesday,
            wednesday,
            thursday,
            friday,
            saturday,
            sunday,
            CASE WHEN start_time NOT LIKE '%:%' THEN CONCAT(start_time, ':00') ELSE start_time END AS start_time,
            start_symbol,
            CASE WHEN end_time NOT LIKE '%:%' THEN CONCAT(end_time, ':00') ELSE end_time END AS end_time,
            end_symbol
FROM		temp_time )

SELECT		sign_code, 
			monday, 
			tuesday, 
            wednesday, 
            thursday, 
            friday, 
            saturday, 
            sunday, 
            CASE 
				WHEN UPPER(start_symbol) = 'AM' AND start_time != '12:00' THEN CAST(start_time AS time)
				WHEN UPPER(start_symbol) = 'AM' AND start_time  = '12:00' THEN '00:00:00'
                WHEN UPPER(start_symbol) = 'PM' AND start_time != '12:00' THEN ADDTIME(CAST(start_time AS time), '12:00:00')
                WHEN UPPER(start_symbol) = 'PM' AND start_time  = '12:00' THEN '12:00:00'
			END AS start_time,
            CASE
				WHEN UPPER(end_symbol) = 'AM' AND end_time != '12:00' THEN CAST(end_time AS time)
				WHEN UPPER(end_symbol) = 'AM' AND end_time  = '12:00' THEN '11:59:59'
                WHEN UPPER(end_symbol) = 'PM' AND end_time != '12:00' THEN ADDTIME(CAST(end_time AS time), '12:00:00')
                WHEN UPPER(end_symbol) = 'PM' AND end_time  = '12:00' THEN '12:00:00'
			END AS end_time
FROM		temp3) ed
ON 			sd.sign_code = ed.sign_code
JOIN 		nyc_parking.restrict r 
ON 			r.monday = ed.monday AND
            r.tuesday = ed.tuesday AND
            r.wednesday = ed.wednesday AND
            r.thursday  = ed.thursday AND
            r.friday = ed.friday AND
            r.saturday = ed.saturday AND
            r.sunday = ed.sunday AND
            r.start_time = ed.start_time AND
            r.end_time = ed.end_time
SET 		sd.restrict_id = r.restrict_id ;

# Insert data into the sign table
INSERT INTO nyc_parking.sign (order_number, sign_code, geometry)
SELECT		DISTINCT
			order_number,
            sign_code,
			ST_GeomFromText(geometry_wkt, 2263) AS geometry
FROM		nyc_parking.sign_stg
WHERE		UPPER(geometry_wkt) NOT LIKE '%NAN%' AND
			UPPER(borough) = 'BROOKLYN' AND
			sign_description LIKE '%SANITATION BROOM SYMBOL%' ;

SELECT		COUNT(*)
FROM		nyc_parking.block_sign ;

# Insert data into the block sign map
INSERT INTO nyc_parking.block_sign (physicalid, sign_id, sign_side)
## Create CTE of all the necessary data
WITH temp AS (
SELECT		b.physicalid,
			s.sign_id,
            b.geometry AS block_geometry,
            s.geometry AS sign_geometry,
            ST_Distance(b.geometry, s.geometry) AS dist,
            # Calculate bearing using the start and end points of the linestring
            MOD(DEGREES(ATAN2(ST_Y(ST_EndPoint(b.geometry)) - ST_Y(ST_StartPoint(b.geometry)),
							  ST_X(ST_EndPoint(b.geometry)) - ST_X(ST_StartPoint(b.geometry)))) + 360, 360) AS bearing,
			so.side_of_street,
            so.order_number
FROM		nyc_parking.block b
LEFT JOIN	nyc_parking.sign_order so
ON			b.street_id = so.street_id
LEFT JOIN	nyc_parking.sign s
ON			so.order_number = s.order_number 
WHERE		s.geometry IS NOT NULL AND
			b.geometry IS NOT NULL),

## Find the shortest distance to a block geometry for each sign
min_dist AS (
SELECT		sign_id,
			MIN(dist) AS min_dist
FROM		temp
GROUP BY	sign_id)

## Load the signs and the closest block on the same street
SELECT 		bs.physicalid,
			bs.sign_id,
            # Determine side of street in direction of travel using the bearing and cardinal direction side of street
            CASE
				WHEN side_of_street = 'N' AND (bearing BETWEEN 90  AND 270) THEN 'R'
				WHEN side_of_street = 'N' AND (bearing BETWEEN 270 AND 360 OR bearing < 90) THEN 'L'
				WHEN side_of_street = 'E' AND (bearing BETWEEN 0   AND 180) THEN 'R'
				WHEN side_of_street = 'E' AND (bearing BETWEEN 180 AND 360) THEN 'L'
				WHEN side_of_street = 'S' AND (bearing BETWEEN 270 AND 360 OR bearing < 90) THEN 'R'
				WHEN side_of_street = 'S' AND (bearing BETWEEN 90  AND 270) THEN 'L'
				WHEN side_of_street = 'W' AND (bearing BETWEEN 180 AND 360) THEN 'R'
				WHEN side_of_street = 'W' AND (bearing BETWEEN 0   AND 180) THEN 'L'
				ELSE NULL
			END AS sign_side
FROM 		temp bs
JOIN 		min_dist md
ON 			bs.sign_id = md.sign_id AND bs.dist = md.min_dist 
WHERE		bs.dist <= 30 ; # Limit to signs within 30 feet of the centerline.