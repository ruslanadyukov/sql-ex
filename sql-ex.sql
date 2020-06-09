--решение 40 задач

--Задание: 51

with x as (
    select name
        ,numGuns 
        ,displacement 
    from ships as s
        ,classes as c
    where s.class = c.class
    union 
    select ship
        ,numGuns
        ,displacement 
    from outcomes as o
        ,classes as c
    where o.ship = c.class
)
    ,z as (
    select max(numguns) as max
        ,displacement 
    from (
        select  numGuns
            ,displacement
        from ships as s
            ,classes as c
        where s.class = c.class
        union 
        select  numGuns
            ,displacement 
        from outcomes as o
            ,classes as c
        where o.ship = c.class
    ) as a
    group by displacement
)
select  x.name
from x
    ,z
where x.displacement = z.displacement
    and x.numGuns = z.max


--Задание: 52

select distinct name 
from ships as s
join classes as c on s.class=c.class
where (c.type = 'bb' or
        c.type is null
    )
    and (c.country = 'japan' or
         c.country is null
    )
    and (c.numguns >= 9 or
        c.numguns is null
    )
    and (c.bore < 19 or
        c.bore is null
    )
    and (c.displacement <= 65000 or
        c.displacement is null
    )


--Задание: 64

select i.point
    ,i.date
    ,'inc' as operation
    ,sum(inc) as money_sum 
from income as i 
left join outcome as o on i.point=o.point 
    and i.date = o.date
where o.out is null
group by i.point
    ,i.date
union 
select o1.point
    ,o1.date
    ,'out' as operation
    ,sum(out) as money_sum 
from outcome as o1 
left join income as i1 on o1.point=i1.point
    and o1.date = i1.date
where i1.inc is null 
group by o1.point
    ,o1.date


--Задание: 67

select count(*) as qty 
from (
    select top 1 with ties count(*) as qty
        ,town_from
        ,town_to 
    from trip
    group by town_from
        ,town_to
    order by qty desc
) as t


--Задание: 68

select count(*) as qty 
from (
    select top 1 with ties sum(c) as cc
    ,c1
    ,c2 
    from(
        select count(*) as c
            ,town_from as c1
            ,town_to as c2 
        from trip
        where  town_from >= town_to
        group by town_from
            ,town_to
        union
        select count(*) as c
            ,town_to as c1
            ,town_from as c2
        from trip
        where town_to > town_from
        group by town_to
            ,town_from
    ) as x
    group by c1, c2
    order by cc desc
) as t


--Задание: 70

select distinct o.battle 
from outcomes as o
left join ships as s on o.ship = s.name 
left join cLasses as c on o.ship = c.class or
    s.class = c.class
where c.country is not null
group by c.country
    ,o.battle
having count(o.ship) >= 3


--Задание: 71

select p.maker 
from product as p
left join pc on p.model = pc.model
where p.type = 'pc'
group by p.maker
having count(p.model) = count(pc.model)


--Задание: 73

select distinct c.country
    ,b.name
from battles as b
    ,classes as c
except
select c.country
    ,o.battle
from outcomes as o
left join ships as s on s.name = o.ship
left join classes as c on o.ship = c.class or
    s.class = c.class
where c.country is not null
group by c.country
    ,o.battle


--Задание: 74

select country
    ,class
from classes
where country='Russia'
    and exists (
        select country
            ,class
        from classes
        where country='Russia'
    )
union
select country
    ,class
from classes
where not exists (
    select country
        ,class
    from classes
    where country = 'Russia'
)


--Задание: 75

with x as(
    select maker
        ,price as lap
        ,null as pc
        ,null as pr 
    from product as p
    join laptop as l on l.model = p.model
    where price is not null
    union
    select maker
        ,null as lap
        ,price as pc
        ,null as pr 
    from product as p
    join pc on pc.model = p.model
    where price is not null
    union 
    select maker
        ,null as lap
        ,null as pc
        ,price as pr 
    from product as p
    join printer as pr on pr.model = p.model
    where price is not null
)
select maker
    ,max(lap) as laptop
    ,max(pc) as pc
    ,max(pr) as printer
from x
group by maker


--Задание: 76

with x as (
    select row_number() over (
            partition by p.id_psg
                ,pass.place
            order by pass.date
            ) as num
        ,datediff(minute
             ,time_out
             ,dateadd(day
                ,case 
                        when time_in < time_out then 1 
                        else 0 end
                ,time_in
            )
        ) as time
        ,p.id_psg
        ,p.name
    from pass_in_trip as pass 
    left join trip as t on pass.trip_no = t.trip_no
    left join Passenger as p on p.id_psg = pass.id_psg
)
select max(x.name) as name
    ,sum(time) as minutes
from x
group by x.id_psg
having max(num) = 1


--Задание: 77

select top 1 with ties *
from (
    select count(distinct p.trip_no) as count
        ,date 
    from pass_in_trip as p
    join trip as t on p.trip_no = t.trip_no
    where town_from = 'Rostov'
    group by date
) as x
order by 1 desc


--Задание: 78

select name
    ,dateadd(day, -datepart(day, b.date) +1, convert(date, b.date)) as firstD
    ,eomonth(b.date) as lastD
from battles as b


--Задание: 79

select name
    ,minutes
from (
    select p.id_psg
    ,sum((datediff(minute, time_out, time_in)+1440)%1440) as minutes
    ,max(sum((datediff(minute, time_out, time_in)+1440)%1440)) over() as max
    from pass_in_trip as p
    join trip as t on p.trip_no = t.trip_no
    group by p.id_psg
) as a
join passenger as p on p.id_psg = a.id_psg
where minutes = max


--Задание: 80

select distinct maker
from product
where maker not in (
    select maker
    from product
    where type = 'pc'
        and model not in(
        select model from pc
        )
)


--Задание: 81

select o.code
    ,o.point
    ,o.date
    ,o.out
from outcome as o
join (
    select top 1 with ties year(date) as y
    ,month(date) as m
    ,sum(out) as out
    from outcome
    group by year(date)
        ,month(date)
    order by out desc
) as x on year(o.date) = x.y
    and month(o.date) = x.m


--Задание: 83

select name
from ships as s
join classes as c on s.class = c.class
where
    case
        when c.numGuns = 8 then 1 else 0
        end +
    case
        when c.bore = 15 then 1 else 0
        end +
    case
        when c.displacement = 32000 then 1 else 0
        end +
    case
        when c.type = 'bb' then 1 else 0
        end +
    case
        when s.launched = 1915 then 1 else 0
        end +
    case
        when s.class = 'Kongo' then 1 else 0
        end +
    case
        when c.country = 'USA' then 1 else 0
        end >= 4


--Задание: 84

select name
    ,a as '1-10'
    ,b as '11-20'
    ,c as '21-30'
from (
    select t.id_comp
    ,sum(case 
        when day(p.date) <= 10 then 1 else 0
        end
    ) as a
    ,sum(case
        when (day(p.date) >= 11 and day(p.date) <= 20) then 1 else 0
        end
    ) as b
    ,sum(case
        when (day(p.date) >= 21 and day(p.date) <= 30) then 1 else
        0 end
    ) as c
    from trip as t 
    join pass_in_trip as p on t.trip_no = p.trip_no
        and convert(char(6), p.date, 112) = '200304'
    group by t.id_comp
) as x
join company as c on x.id_comp = c.id_comp


--Задание: 85

select maker 
from product
group by maker
having count(distinct type) = 1
    and (max(type) = 'printer' or
        max(type) = 'PC'
        and count(model) >= 3
    )


--Задание: 86

select maker
    ,case count(distinct type)
        when 1 then max(type) 
        when 2 then min(type) + '/' + max(type)
        when 3 then 'Laptop/PC/Printer'
        else null
        end types
from product
group by maker


--Задание: 87

select distinct name
    ,count(town_to) as qty
from passenger as p 
join pass_in_trip as pass on p.id_psg = pass.id_psg 
join trip as t on pass.trip_no = t.trip_no
where t.town_to = 'moscow'
    and pass.id_psg not in (
        select distinct pass.id_psg 
        from pass_in_trip as pass 
        join trip as t on pass.trip_no = t.trip_no
        where date + time_out = (
            select min(date + time_out) 
            from trip as t1
            join pass_in_trip as pass1 on t1.trip_no = pass1.trip_no
            where pass1.id_psg = pass.id_psg
        ) 
    and town_from = 'Moscow'
    )
group by name
    ,pass.id_psg
having count(town_to) > 1


--Задание: 88

select (
        select name 
        from Passenger 
        where id_psg = b.id_psg
    ) as name
    ,b.trip_qty
    ,(
        select name 
        from company 
        where id_comp = b.id_comp
    ) as company
from (
    select p.id_psg
        ,min(t.id_comp) as id_comp
        ,count(p.trip_no) as trip_qty
        ,max(count(p.trip_no)) over() as max_qty
    from pass_in_trip as p
    join trip as t on p.trip_no = t.trip_no
    group by p.id_psg
    having min(t.id_comp) = max(t.id_comp)
) as b
where trip_qty = max_qty


--Задание: 89

select  maker
    ,count(model) as qty
from product
group by maker
having count(model) >= all(
    select count(model) 
    from product
    group by maker
    ) or
    count(model) <= all(
        select count(model) 
        from product
        group by maker
    )


--Задание: 90

select maker
    ,model
    ,type 
from (
    select *
        ,row_number () over (order by model) as a
        ,row_number() over (order by model desc) as b
    from product
) as x
where a > 3 
    and b >3


--Задание: 91

select cast(sum(a.b) / count (a.b) as numeric(12,2)) as avg_paint
from (
    select distinct q_name
        ,sum(cast (isnull(b_vol, 0) as float)) as b 
    from utQ as q
    left join utB as u on q.q_id = u.b_q_id
    group by q_name
) as a


--Задание: 92

select q_name 
from utQ
where q_id in (
    select b_q_id
    from (
        select b_q_id
         from utB
        group by b_q_id
        having sum(b_vol) = 765
    ) as b
    where b_q_id not in (
        select b_q_id
        from utB
        where b_v_id in (
            select b_v_id
            from utB
            group by b_v_id
            having sum(b_vol) < 255
        )
    )
)


--Задание: 93

select c.name
    ,sum(x.a) as minutes
from(
    select distinct t.id_comp
        ,p.trip_no
        ,p.date
        ,t.time_out
        ,t.time_in
        ,case
            when datediff(minute, t.time_out,t.time_in) > 0 then datediff(minute, t.time_out,t.time_in)
            when datediff(minute, t.time_out,t.time_in) <= 0 then datediff(minute, t.time_out,t.time_in+1)
            else null end as a
    from pass_in_trip as p 
    join trip as t on p.trip_no = t.trip_no
) as x 
join company as c on x.id_comp = c.id_comp
group by c.name


--Задание: 95

select distinct name
    ,count(distinct convert(char(12), date)+ convert (char(10), p.trip_no)) as flights
    ,count( distinct plane) as planes
    ,count (distinct id_psg) as diff_psngrs
    ,count (place) as total_psngrs
from company as c
join trip as t on c.id_comp = t.id_comp
join pass_in_trip as p on t.trip_no = p.trip_no
group by name


--Задание: 96

with x as (
    select v_name
        ,v_id 
        ,count (case when v_color = 'R' then 1 else null end) over (partition by v_id) as v
        ,count (case when v_color = 'B' then 1 else null end) over (partition by b_q_id) as b
    from utV
    join utB on utV.v_id = utB.b_v_id
)
select v_name
from x
where v > 1
    and b > 0
group by v_name


--Задание: 100

select x.date
    ,x.code
    ,i.point
    ,i.inc
    ,o.point
    ,o.out 
from (
    select distinct date
        ,row_number() over (partition by date order by code) as code
     from outcome
    union
    select distinct date
        ,row_number() over (partition by date order by code) as code
    from income
) as x
left join (
    select date
    ,point
    ,inc
    ,row_number() over (partition by date order by code) as code1 
    from income
) as i on x.date = i.date
    and x.code = i.code1
left join (
    select date
        ,point
        ,out
        ,row_number() over (partition by date order by code) as code2 
    from outcome
) as o on x.date = o.date
    and x.code = o.code2


--Задание: 102

select name 
from passenger
where id_psg in (
    select id_psg 
    from pass_in_trip as pass
    join trip as t on pass.trip_no=t.trip_no
    group by id_psg
    having count(distinct case 
        when town_from <= town_to then town_from+town_to
        else town_to+town_from 
        end
    ) = 1
)


--Задание: 103

select min(t1.trip_no) as min1
    ,min(t2.trip_no) as min2
    ,min(t3.trip_no) as min3
    ,max(t1.trip_no) as max1
    ,max(t2.trip_no) as max2
    ,max(t3.trip_no) as max3
from trip as t1
    ,trip as t2
    ,trip as t3
where t2.trip_no > t1.trip_no
    and t3.trip_no  >t2.trip_no


--Задание: 105

select maker
    ,model
    ,row_number() over ( order by maker, model) as a
    ,dense_rank() over(order by maker) as b
    ,rank() over(order by maker) as c
    ,count(maker) over(order by maker) as d
from product


--Задание: 107

select name
    ,trip_no
    ,date
from (
    select name
        ,t.trip_no
        ,date
        ,row_number() over(order by time_out + date, id_psg) as n
    from company as c 
    join trip as t on c.id_comp=t.id_comp 
    join pass_in_trip as pass on t.trip_no=pass.trip_no
    where town_from='Rostov'
        and year(date) = 2003
        and month(date) = 4
) as x
where n = 5


--Задание: 109

select q_name
    ,whites
    ,allcolor-whites as blacks
from (
    select q_name
    ,(sum(sum(utB.b_vol)) over()) / 765 as whites
    ,count(*) over() as allcolor
    from utQ as q
    left join utB as b on q.q_id=b.b_q_id
    group by q_name
    having sum(b_vol) is null or
        sum(b_vol) = 765
 ) as x


--Задание: 110

select name 
from passenger
where id_psg in (
    select id_psg
    from pass_in_trip as pass 
    join trip as t on pass.trip_no = t.trip_no
    where datepart(dw, date) = 7 
        and time_in < time_out 
)


--Задание: 113

select sum(255 - isnull ([R],0) ) as R
    ,sum(255 - isnull([G],0)) as G
    ,sum(255 - isnull([B],0)) as B
from (
    select isnull(b_q_id, q_id) as id
        ,v_color as c
        ,b_vol as v 
    from utB as b
    right join utQ as q on b.b_q_id=q.q_id
    left join utV as v on b.b_v_id=v.v_id
) as x
pivot (
    sum(v) for c in ([R], [G], [B])
) as pvt
where isnull([R],0) + isnull([G],0) + isnull([B],0) < 765


--Задание: 114

with a as(
    select id_psg
        ,count(*) as c
    from pass_in_trip
    group by id_psg
        ,place
)
    ,b as (
        select distinct id_psg
            ,c
        from a
        where c = (
            select max(c)
            from a
        )
    )
select name
    ,c
from b 
join passenger as p on b.id_psg=p.id_psg

--Задание: 115

select distinct u.b_vol as Up
    ,d.b_vol as Down
    ,s.b_vol as Side
    ,cast(power((power(s.b_vol,2) - power((1.*d.b_vol-1.*u.b_vol) / 2,2)),1. / 2.) / 2 as dec(15,2)) as Rad
from utB u
    ,utB d
    ,utB s
where u.b_vol < d.b_vol
    and 1. * u.b_vol + 1. * d.b_vol = 2. * s.b_vol


--Задание: 117

Select top 1 with ties country
    ,max_val
    ,name
from classes
cross apply(
    values(numguns * 5000, 'numguns')
        ,(bore * 3000, 'bore')
        ,(displacement, 'displacement')
)
spec(max_val
    ,name
)
group by country
    ,max_val
    ,name
order by rank() over (partition by country order by max_val desc)
