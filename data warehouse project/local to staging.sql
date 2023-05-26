--create format before load data
create or replace file format json_format type = json;
create or replace file format csv_format type = csv, field_delimiter=',', skip_header=1;

--create staging to load file from local
create or replace stage staging_json file_format = json_format;
create or replace stage staging_csv file_format = csv_format;

--put file from local
put file:///Users/vu/Downloads/notebook/temperature.csv @staging_csv auto_compress=true;
put file:///Users/vu/Downloads/notebook/precipitation.csv @staging_csv auto_compress=true;

put file:///Users/vu/Downloads/notebook/covid.json @staging_json auto_compress=true;
put file:///Users/vu/Downloads/notebook/yelp_dataset/yelp_academic_dataset_business.json @staging_json auto_compress=true;
put file:///Users/vu/Downloads/notebook/yelp_dataset/yelp_academic_dataset_checkin.json @staging_json auto_compress=true;
put file:///Users/vu/Downloads/notebook/yelp_dataset/yelp_academic_dataset_tip.json @staging_json auto_compress=true;
put file:///Users/vu/Downloads/notebook/yelp_dataset/yelp_academic_dataset_review.json @staging_json auto_compress=true;
put file:///Users/vu/Downloads/notebook/yelp_dataset/yelp_academic_dataset_user.json @staging_json auto_compress=true;
--create table
CREATE TABLE staging_covid (covid_info VARIANT);
CREATE TABLE staging_business (business_info VARIANT);
CREATE TABLE staging_checkin (checkin_info VARIANT);
CREATE TABLE staging_review (review_info VARIANT);
CREATE TABLE staging_tip (tip_info VARIANT);
CREATE TABLE staging_user (user_info VARIANT);
CREATE TABLE staging_precipitation (date STRING, precipitation STRING, precipitation_normal STRING);
CREATE TABLE staging_temperature (period STRING, min_value STRING, max_value STRING, normal_min STRING, normal_max STRING);

--copy from staging area to table
COPY INTO staging_precipitation FROM @staging_csv/precipitation.csv.gz file_format=csv_format;
COPY INTO staging_temperature FROM @staging_csv/temperature.csv.gz file_format=csv_format;

COPY INTO staging_tip FROM @STAGING_JSON/yelp_academic_dataset_tip.json.gz file_format=json_format;
COPY INTO staging_review FROM @STAGING_JSON/yelp_academic_dataset_review.json.gz file_format=json_format;
COPY INTO staging_user FROM @STAGING_JSON/yelp_academic_dataset_user.json.gz file_format=json_format;
COPY INTO staging_checkin FROM @STAGING_JSON/yelp_academic_dataset_checkin.json.gz file_format=json_format;
COPY INTO staging_business FROM @STAGING_JSON/yelp_academic_dataset_business.json.gz file_format=json_format;
COPY INTO staging_covid FROM @STAGING_JSON/covid.json.gz file_format=json_format;