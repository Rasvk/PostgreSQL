select
title, prodyear 
from 
film f, 
filmgenre fg 
where 
f.title 
SIMILAR TO
'Rush Hour%' 
AND 
f.filmid = fg.filmid 
AND 
fg.genre = 'Action'
;

select 
title, prodyear, filmtype
from 
film f, filmitem fi
where 
f.prodyear = 1893
And 
fi.filmtype = 'C'
And 
fi.filmid = f.filmid
;

select 
firstname, 
lastname
from 
person p,
filmparticipation fp, 
film f
where 
f.title = 'Baile Perfumado'
and 
fp.parttype = 'cast'
and 
f.filmid = fp.filmid
and 
fp.personid = p.personid;

select title, prodyear from film f, person p, filmparticipation fp
where p.firstname = 'Ingmar' and p.lastname = 'Bergman'
and p.personid = fp.personid
and f.filmid = fp.filmid
and fp.parttype = 'director'
order by prodyear;

select max(prodyear), min(prodyear) from film f, person p, filmparticipation fp
where p.firstname = 'Ingmar' and p.lastname = 'Bergman'
and p.personid = fp.personid
and f.filmid = fp.filmid
and fp.parttype = 'director';

select firstprodyear, count(firstprodyear) from series s, s.firstprodyear = '2008' OR s.firstprodyear = '2009'
Group by firstprodyear;

select firstprodyear, count(seriesid) from series s
where s.firstprodyear = 2008 or s.firstprodyear = 2009
group by firstprodyear;

select title, prodyear ,count(parttype)from film f, filmparticipation fp, person p where
f.filmid = fp.filmid
group by title, prodyear
having count(parttype) > 300
