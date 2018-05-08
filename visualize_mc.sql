
--name=all_mc
select * 
from mtanco.all_mc
where cnt > 0.10;

--name=switch_mc
select * 
from mtanco.switch_mc
where cnt > 0.10;

--name=xbox_mc
select * 
from mtanco.xbox_mc
where cnt > 0.10;

--name=comp_mc
select 
	a.path
	, a.cnt as all_pct
	, coalesce(x.cnt,0) as xbox_pct
	, coalesce(s.cnt,0) as switch_pct
from mtanco.all_mc as a
full outer join mtanco.xbox_mc as x
	on a.path = x.path
full outer join mtanco.switch_mc as s
	on a.path = s.path;