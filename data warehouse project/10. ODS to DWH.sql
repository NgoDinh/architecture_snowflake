use SCHEMA dwh
------------fact_review----------------------
CREATE OR REPLACE TABLE fact_review (
    review_id           TEXT PRIMARY KEY,
    user_id             TEXT,
    business_id         TEXT,
    stars               NUMERIC(3,2),
    useful              INT,
    funny               INT,
    cool                INT,
    review_time         DATETIME,
    _date               DATE
);

INSERT INTO fact_review (review_id, user_id, business_id, stars, useful, funny, cool, review_time, _date)
SELECT  review_id,
        user_id,
        business_id,
        stars,
        useful,
        funny,
        cool,
        _date,
        date(_date) as _date
FROM FINALPROJECT.ods.ods_review;
------------dim date-------------------------
CREATE OR REPLACE TABLE dim_date (
    _date      DATE PRIMARY KEY,
    _dayofweek INT,
    _day       INT,
    _week      INT,
    _month     INT,
    _year      INT
);

INSERT INTO dim_date (_date, _dayofweek, _day, _week, _month, _year)
select _date,
day(_date) as _day,
dayofweek(_date) as _dayofweek,
week(_date) as _week,
month(_date) as _month,
year(_date) as _year
from ods.ods_precipitation
union
select _date,
day(_date) as _day,
dayofweek(_date) as _dayofweek,
week(_date) as _week,
month(_date) as _month,
year(_date) as _year
from ods.ods_temperature
union
select date(_date),
day(_date) as _day,
dayofweek(_date) as _dayofweek,
week(_date) as _week,
month(_date) as _month,
year(_date) as _year
from ods.ods_review;

-------dim user------------------------------
CREATE OR REPLACE TABLE dim_user (
	user_id TEXT PRIMARY KEY,
    name TEXT,
	yelping_since DATETIME,	
);

INSERT INTO dim_user(user_id, name, yelping_since)
select user_id, name, yelping_since from FINALPROJECT.ods.ods_user; 
-------------------dim weather--------------------------------

CREATE OR REPLACE TABLE dim_weather (
    _date date PRIMARY KEY,
    precipitation FLOAT,
    precipitation_normal FLOAT,
    temp_min FLOAT,
    temp_max FLOAT,
    temp_normal_min FLOAT,
    temp_normal_max FLOAT
);

INSERT INTO dim_weather (_date, precipitation, precipitation_normal, temp_min, temp_max, temp_normal_min, temp_normal_max)
select t1._date
, precipitation
, precipitation_normal
, temp_min
, temp_max
, temp_normal_min
, temp_normal_max
from ods.ods_precipitation t1
left join ods.ods_temperature as t2 on t1._date = t2._date

------------------dim_business------------------
CREATE OR REPLACE TABLE dim_business (
    business_id TEXT PRIMARY KEY,
    name TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    is_open INT,
    covid_highlights                TEXT,
    covid_delivery_or_takeout       TEXT
);

INSERT INTO dim_business(business_id ,name , city, state, is_open, covid_highlights, covid_delivery_or_takeout)
SELECT t1.business_id,
    name,
    city,
    state,
    t2.highlights,
    t2.delivery_or_takeout,
FROM FINALPROJECT.ods.ods_business AS t1
LEFT JOIN FINALPROJECT.ods.ods_covid AS t2 ON t1.business_id = t2.business_id;

------------dim_checkin---------------------
CREATE OR REPLACE TABLE dim_checkin (
    business_id text PRIMARY KEY,
    _date date,
    total_checkin int
);

insert into dim_checkin (business_id, _date, total_checkin)
select 
business_id, date(t2.value::datetime) as _date
, count(distinct t2.value) total_checkin
from ods.ods_checkin t1,
LATERAL flatten(input => split(t1._date, ',')) t2
group by 1,2;