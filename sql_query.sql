
--cleaning and data preperation
select id, coalesce(country,'not_available') as country,
coalesce(gender,'not_available') as gender,
coalesce(device,'not_available') as device,
new_ab.group,
total_spent,
whether_converted from
(select id,
u.country,
u.gender,
g.device,
g.group,
sum(coalesce(a.spent,0)) as total_spent,
case when sum(coalesce(a.spent,0))>0 then 1
else
0
end as whether_converted
from users u 
left join groups g
on 
u.id = g.uid
left join activity a
on 
u.id=a.uid
group by u.country,
u.gender,
g.device,
g.group,id
order by id desc) as new_ab;





--novelty effect

select sum(dt_ab.total_spent) as per_dt_spent,
dt_ab.join_dt,
dt_ab.group,
sum(dt_ab.count)
from (
select 
g.join_dt,
g.device,
g.group,
count(a.uid),
sum(coalesce(a.spent,0)) as total_spent,
case when sum(coalesce(a.spent,0))>0 then 1
else
0
end as whether_converted
from  activity a
left join groups g
on 
a.uid = g.uid
group by 
g.join_dt,
g.device,
g.group
order by join_dt asc) as dt_ab
group by dt_ab.join_dt,
dt_ab.group;











