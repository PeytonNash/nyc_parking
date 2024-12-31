CREATE DATABASE IF NOT EXISTS nyc_parking ;

# Create road staging table 
CREATE TABLE nyc_parking.road_stg (
bike_lane       			VARCHAR(10)
,bike_trafd     			VARCHAR(10)
,borocode       			VARCHAR(10)
,date_creat     			VARCHAR(20)
,time_creat     			VARCHAR(20)
,frm_lvl_co     			VARCHAR(20)
,full_stree     			VARCHAR(100)
,l_blkfc_id     			VARCHAR(10)
,l_high_hn      			VARCHAR(10)
,l_low_hn       			VARCHAR(10)
,l_zip          			VARCHAR(10)
,date_modif     			VARCHAR(20)
,time_modif     			VARCHAR(20)
,physicalid     			VARCHAR(20)
,post_direc     			VARCHAR(10)
,post_modif     			VARCHAR(10)
,post_type      			VARCHAR(10)
,pre_direct     			VARCHAR(10)
,pre_modifi     			VARCHAR(10)
,pre_type       			VARCHAR(10)
,r_blkfc_id     			VARCHAR(100)
,r_high_hn      			VARCHAR(10)
,r_low_hn       			VARCHAR(100)
,r_zip          			VARCHAR(100)
,rw_type        			VARCHAR(100)
,segment_ty     			VARCHAR(100)
,shape_leng     			VARCHAR(100)
,snow_pri       			VARCHAR(10)
,st_label       			VARCHAR(10)
,st_name        			VARCHAR(100)
,st_width       			VARCHAR(10)
,status         			VARCHAR(20)
,to_lvl_co      			VARCHAR(100)
,trafdir        			VARCHAR(10)
,boroname       			VARCHAR(20)
,geometry_wkt				VARCHAR(5000)
,l_geometry_curb			BLOB
,r_geometry_curb			BLOB
) ;

# Create sign staging table 
CREATE TABLE nyc_parking.sign_stg (
order_number                VARCHAR(100)
,record_type                VARCHAR(100)
,order_type                 VARCHAR(100)
,borough                    VARCHAR(100)
,on_street                  VARCHAR(100)
,on_street_suffix           VARCHAR(100)
,from_street                VARCHAR(100)
,from_street_suffix         VARCHAR(100)
,to_street                  VARCHAR(100)
,to_street_suffix           VARCHAR(100)
,side_of_street             VARCHAR(100)
,order_completed_on_date    VARCHAR(100)
,sign_code                  VARCHAR(100)
,sign_description           VARCHAR(100)
,sign_size                  VARCHAR(100)
,sign_design_voided_on_date VARCHAR(100)
,sign_location              VARCHAR(100)
,distance_from_intersection VARCHAR(100)
,arrow_direction            VARCHAR(100)
,facing_direction           VARCHAR(100)
,sheeting_type              VARCHAR(100)
,support                    VARCHAR(100)
,sign_notes                 VARCHAR(100)
,sign_x_coord               VARCHAR(100)
,sign_y_coord               VARCHAR(100)
,full_stree                 VARCHAR(100)
,geometry_wkt               VARCHAR(100)
) ;