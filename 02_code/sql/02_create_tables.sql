# Create borough table
CREATE TABLE nyc_parking.borough (
 borough_id		TINYINT UNSIGNED NOT NULL AUTO_INCREMENT
,borough		VARCHAR(13) NOT NULL
,PRIMARY KEY(borough_id)
) ;

# Create street table
CREATE TABLE IF NOT EXISTS nyc_parking.street (
 street_id 			INT UNSIGNED NOT NULL AUTO_INCREMENT # Primary key
,borough_id			TINYINT UNSIGNED NOT NULL # Primary key/foreign key
,street_name		VARCHAR(40) NOT NULL
,street_label		VARCHAR(40)
,PRIMARY KEY 		(street_id)
,CONSTRAINT fk_borough FOREIGN KEY (borough_id) REFERENCES nyc_parking.borough(borough_id)
) ;

# Create block table
CREATE TABLE nyc_parking.block (
 physicalid 		INT UNSIGNED NOT NULL # Primary key
,street_id 			INT UNSIGNED # Foreign key to street data
,geometry			LINESTRING NOT NULL SRID 2263
,rw_type			TINYINT
,st_width			SMALLINT
,trafdir			ENUM('TW', 'TF', 'FT', 'NV')
,segment_ty			ENUM('U', 'T', 'R', 'E', 'S', 'B', 'C')
,shape_length		DECIMAL(10,5)	
,bike_lane			TINYINT
,bike_trafd			ENUM('TW', 'TF', 'FT')
,frm_lvl_co			TINYINT
,to_lvl_co			TINYINT
,status				TINYINT
,date_time_modif	DATETIME
,date_time_created	DATETIME
,post_direct		ENUM('N', 'E', 'S', 'W', 'NE', 'NW', 'SE', 'SW')
,post_modified		VARCHAR(12)
,post_type			VARCHAR(5)
,pre_direct			ENUM('N', 'E', 'S', 'W', 'NE', 'NW', 'SE', 'SW')
,pre_modified		VARCHAR(6)
,pre_type			VARCHAR(5)
,PRIMARY KEY (physicalid)
,CONSTRAINT fk_street FOREIGN KEY (street_id) REFERENCES nyc_parking.street(street_id)
) ;

# Create curb table
CREATE TABLE nyc_parking.curb (
 curb_id 		INT UNSIGNED NOT NULL AUTO_INCREMENT # Primary key
,physicalid 	INT UNSIGNED NOT NULL # Foreign key to block data
,curb_side		ENUM('L', 'R')
,geometry		LINESTRING NOT NULL SRID 2263
,PRIMARY KEY(curb_id)
,CONSTRAINT fk_block FOREIGN KEY (physicalid) REFERENCES nyc_parking.block(physicalid)
) ;

# Create sign order table
CREATE TABLE nyc_parking.sign_order (
 order_number 	VARCHAR(12) NOT NULL # Primary key
,record_type	ENUM('Current')
,order_type 	ENUM('S-', 'P-')
,street_id 		INT UNSIGNED NOT NULL # Foreign key to street
,side_of_street	ENUM('N', 'S', 'E', 'W')
,PRIMARY KEY(order_number)
,CONSTRAINT fk_street2 FOREIGN KEY (street_id) REFERENCES nyc_parking.street(street_id)
) ;

# Create restrictions table
CREATE TABLE nyc_parking.restrict (
restrict_id					SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT
,monday							TINYINT
,tuesday						TINYINT
,wednesday						TINYINT
,thursday						TINYINT
,friday							TINYINT
,saturday						TINYINT
,sunday							TINYINT
,start_time						TIME
,end_time						TIME
,PRIMARY KEY (restrict_id)
) ;

# Create sign description table
CREATE TABLE nyc_parking.sign_description (
 sign_code						VARCHAR(12)	
,sign_description				VARCHAR(170)
,sign_design_voided_on_date		DATE
,restrict_id					SMALLINT UNSIGNED
,PRIMARY KEY(sign_code)
,CONSTRAINT fk_restrict FOREIGN KEY (restrict_id) REFERENCES nyc_parking.restrict(restrict_id)
) ;

# Create sign table
CREATE TABLE nyc_parking.sign (
 sign_id		BIGINT UNSIGNED NOT NULL AUTO_INCREMENT # Primary key
,order_number	VARCHAR(12) # Foreign key to order table
,sign_code 		VARCHAR(12)	# Foreign key to description table
,geometry		POINT NOT NULL SRID 2263
,PRIMARY KEY(sign_id) 
,CONSTRAINT fk_order FOREIGN KEY (order_number) REFERENCES nyc_parking.sign_order(order_number)
,CONSTRAINT fk_sign_code FOREIGN KEY (sign_code) REFERENCES nyc_parking.sign_description(sign_code)
);

# Create associative block/sign table
CREATE TABLE nyc_parking.block_sign (
 physicalid 		INT UNSIGNED NOT NULL # Primary key
,sign_id			BIGINT UNSIGNED NOT NULL # Primary key
,dist 				DOUBLE AS (ST_Distance(block_geometry, sign_geometry)) STORED
,sign_side			ENUM('L', 'R')
,PRIMARY KEY (physicalid, sign_id)
,CONSTRAINT fk_block2 FOREIGN KEY (physicalid) REFERENCES nyc_parking.block(physicalid)
,CONSTRAINT fk_sign2 FOREIGN KEY (sign_id) REFERENCES nyc_parking.sign(sign_id)
) ;