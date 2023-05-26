
USE SCHEMA ODS;
----tip table---
CREATE OR REPLACE TABLE ods_tip (
    user_id TEXT,
    business_id TEXT,
    _text TEXT,
    _date DATETIME,
    compliment_count INT
);

INSERT INTO ods_tip(user_id, business_id, _text, _date, compliment_count)
SELECT parse_json(tip_info):user_id,
       parse_json(tip_info):business_id,
       parse_json(tip_info):text,
       to_timestamp_ntz(parse_json(tip_info):date),
       parse_json(tip_info):compliment_count
FROM FINALPROJECT.STAGING.staging_tip;

-----checkin table-----
CREATE OR REPLACE TABLE ods_checkin (
	business_id TEXT PRIMARY KEY,
    _date TEXT	
    -- _data column is a list of all date checked in by user
);

INSERT INTO ods_checkin(business_id, _date)
SELECT parse_json(checkin_info):business_id,
       parse_json(checkin_info):date
FROM FINALPROJECT.STAGING.staging_checkin;

--------review table------
--can use $1 = first column
CREATE OR REPLACE TABLE ods_review (
    review_id TEXT PRIMARY KEY,
    user_id TEXT,
    business_id TEXT,
    stars NUMERIC(3,2),
    useful INT,
    funny INT,
    cool INT,
    _text TEXT,
    _date DATETIME
);

INSERT INTO ods_review(review_id, user_id, business_id, stars, useful, funny, cool, _text, _date)
SELECT parse_json($1):review_id,
       parse_json($1):user_id,
       parse_json($1):business_id,
       parse_json($1):stars,
       parse_json($1):useful,
       parse_json($1):funny,
       parse_json($1):cool,
       parse_json($1):text,
       to_timestamp_ntz(parse_json($1):date)
FROM FINALPROJECT.STAGING.staging_review;

------business table------
CREATE OR REPLACE TABLE ods_business (
    business_id TEXT PRIMARY KEY,
    name TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    latitude FLOAT,
    longitude FLOAT,
    stars NUMERIC(3,2),
    review_count INT,
    is_open INT,
    attributes OBJECT,
    categories TEXT,
    hours VARIANT
);

INSERT INTO ods_business(business_id ,name ,address, city, state, postal_code, latitude, longitude, stars, review_count, is_open, attributes, categories, hours)
SELECT parse_json($1):business_id,
       parse_json($1):name,
       parse_json($1):address,
       parse_json($1):city,
       parse_json($1):state,
       parse_json($1):postal_code,
       parse_json($1):latitude,
       parse_json($1):longitude,
       parse_json($1):stars,
       parse_json($1):review_count,
       parse_json($1):is_open,
       parse_json($1):attributes,
       parse_json($1):categories,
       parse_json($1):hours
FROM FINALPROJECT.STAGING.staging_business;

------user table-----
CREATE OR REPLACE TABLE ods_user (
	user_id TEXT PRIMARY KEY,
    name TEXT,
	review_count INT,
	yelping_since DATETIME,
    useful INT,
    funny INT,
    cool INT,
	elite TEXT,
    friends TEXT,
	fans TEXT,
    average_stars NUMERIC(3,2),
    compliment_hot INT,
    compliment_more INT,
    compliment_profile INT,
    compliment_cute INT,
    compliment_list INT,
    compliment_note INT,
    compliment_plain INT,
	compliment_cool INT,
	compliment_funny INT,
	compliment_writer INT,
	compliment_photos INT	
);

INSERT INTO ods_user(user_id, name, review_count, yelping_since, useful, funny, cool, elite, friends, fans, average_stars, compliment_hot, compliment_more, compliment_profile, compliment_cute, compliment_list, compliment_note, compliment_plain, compliment_cool, compliment_funny, compliment_writer, compliment_photos)
SELECT parse_json($1):user_id,
       parse_json($1):name,
       parse_json($1):review_count,
       to_timestamp_ntz(parse_json($1):yelping_since),
       parse_json($1):useful,
       parse_json($1):funny,
       parse_json($1):cool,
       parse_json($1):elite,
       parse_json($1):friends,
       parse_json($1):fans,
       parse_json($1):average_stars,
       parse_json($1):compliment_hot,
       parse_json($1):compliment_more,
       parse_json($1):compliment_profile,
       parse_json($1):compliment_cute,
       parse_json($1):compliment_list,
       parse_json($1):compliment_note,
       parse_json($1):compliment_plain,
       parse_json($1):compliment_cool,
       parse_json($1):compliment_funny,
       parse_json($1):compliment_writer,
       parse_json($1):compliment_photos
FROM FINALPROJECT.STAGING.staging_user;

----------covid table--------------------
CREATE OR REPLACE TABLE ods_covid (
    business_id TEXT,
    highlights TEXT,
    delivery_or_takeout TEXT,
    grubhub_enabled TEXT,
    call_to_action_enabled TEXT,
    request_a_quote_enabled TEXT,
    covid_banner TEXT,
    temporary_closed_until TEXT,
    virtual_services_offered TEXT
);

INSERT INTO ods_covid(business_id, highlights, delivery_or_takeout, grubhub_enabled, call_to_action_enabled, request_a_quote_enabled, covid_banner, temporary_closed_until, virtual_services_offered)
SELECT parse_json($1):business_id,
       parse_json($1):highlights,
       parse_json($1):"delivery or takeout",
       parse_json($1):"Grubhub enabled",
       parse_json($1):"Call To Action enabled",
       parse_json($1):"Request a Quote Enabled",
       parse_json($1):"Covid Banner",
       parse_json($1):"Temporary Closed Until",
       parse_json($1):"Virtual Services Offered"
FROM FINALPROJECT.STAGING.staging_covid;

--------------precipitation table-----------------------------
CREATE OR REPLACE TABLE ods_precipitation (
    precipitation_id INT PRIMARY KEY,
    _date DATE,
    precipitation FLOAT,
    precipitation_normal FLOAT
);
---it have no duplicate and null in date column so using it as a id of table
INSERT INTO ods_precipitation(precipitation_id, _date, precipitation, precipitation_normal)
SELECT cast(date as INT),
       TO_DATE(date, 'YYYYMMDD'),
       TRY_CAST(precipitation AS FLOAT),
       TRY_CAST(precipitation_normal AS FLOAT)
FROM FINALPROJECT.STAGING.staging_precipitation;

----------temperature table --------------
CREATE OR REPLACE TABLE ods_temperature (
    temperature_id INT PRIMARY KEY,
    _date DATE,
    temp_min FLOAT,
    temp_max FLOAT,
    temp_normal_min FLOAT,
    temp_normal_max FLOAT
);

INSERT INTO ods_temperature(temperature_id, _date, temp_min, temp_max, temp_normal_min, temp_normal_max)
SELECT cast(PERIOD as INT),
       TO_DATE(PERIOD, 'YYYYMMDD'),
       MIN_VALUE,
       MAX_VALUE,
       NORMAL_MIN,
       NORMAL_MAX
FROM FINALPROJECT.STAGING.staging_temperature;