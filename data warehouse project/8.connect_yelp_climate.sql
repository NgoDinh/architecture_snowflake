select *
from ods.ods_review as t1
left join ods.ods_temperature as t2 on date(t1._date) = t2._date
left join ods.ods_precipitation as t3 on date(t1._date) = t3._date