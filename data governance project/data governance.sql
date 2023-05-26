with od as (
SELECT distinct buyerid
	, creditcardid
	FROM op.orders
)
, tmp as (
select t1.userid
, case when t2.creditcardid is not null then t2.creditcardid else t3.creditcardid end as master_credit_card_id
, case when t3.creditcardid is not null 
			and t3.creditcardid != t2.creditcardid
			and t2.creditcardid is not null
	   then t3.creditcardid else null end other_credit_card_id 
from usr.users as t1
left join usr.creditcards as t2 on t1.userid = t2.userid
left join od as t3 on t1.userid = t3.buyerid
)
select userid, master_credit_card_id
, string_agg(cast(other_credit_card_id as varchar), ',') as other_credit_card_id
from tmp
group by 1,2
--------------------------
SELECT distinct t1.productid
, t1.brand as listing_brand
, t2.brandname as inventory_brand
, case when length(t1.brand) > length(t2.brandname)  then replace(INITCAP(replace(t1.brand, '&', 'and')), ' ','')
	   else replace(INITCAP(replace(t2.brandname, '&', 'and')), ' ','') end as master_brand
	FROM li.listings as t1
	left join im.items as t2 on t1.productid = t2.itemid
---------------------------
SELECT distinct t1.productid
, t1.condition as listing_condition
, t2.condition as inventory_condition
, case when t1.condition is not null  then t1.condition
	   else t2.condition end as master_condition
	FROM li.listings as t1
	left join im.items as t2 on t1.productid = t2.itemid
--------------------------
with cs as (
SELECT distinct userid
	, phone
	FROM cs.customerservicerequests
	
)

select t1.*, t2.list_phone
from usr.users as t1
left join (
	select userid, string_agg(phone, ';') as list_phone
	from cs
	group by 1
) as t2 on t1.userid = t2.userid