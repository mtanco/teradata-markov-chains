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
	
--After 3 steps, is 498073 session 2 more like xbox,switch, or "average" 
	
--First five rows 
select 
	row_number() over (order by tstamp) as rn
	,customerid
	,sessionid
	,page
from mtanco.mt_retail_npath as a
where customerid = 498073 
and sessionid = 2
order by tstamp

--get pairs
drop table mtanco.session_pairs;
create volatile table mtanco.session_pairs as (
	SELECT rn, cast(page_pair as VARCHAR(103)) as page_pair
	FROM nPath ( 
		ON (
			select 
				row_number() over (order by tstamp) as rn
				,customerid
				,sessionid
				,page
			from mtanco.mt_retail_npath as a
			where customerid = 498073 
			and sessionid = 2
		) AS "input1"
			PARTITION BY customerid,sessionid
			ORDER BY rn
		USING  
			Mode (OVERLAPPING) 
			Pattern ('A.A') 
			Symbols ( 
				TRUE as A
			) 
			Result (
				first(rn of A) as rn
				,accumulate(page of A) as page_pair
			) 
	) AS np
)with data 
	on commit preserve rows;

--look at pairs
select *
from mtanco.session_pairs
order by rn

--see probability at each set of the model
select 
	rn
	,page_pair
	,all_mc.cnt as avg_pct
	,switch_mc.cnt as switch_pct
	,xbox_mc.cnt as xbox_pct
from mtanco.session_pairs as customer
join mtanco.all_mc
	on customer.page_pair = all_mc.path
left outer join mtanco.xbox_mc 
	on customer.page_pair  = xbox_mc.path
left outer join mtanco.switch_mc
	on customer.page_pair  = switch_mc.path
order by rn

--see probability at each set of the model
select
	  exp (sum (ln (avg_pct))) as avg_prob
	, exp (sum (ln (switch_pct))) as switch_prob
	, exp (sum (ln (xbox_pct))) as xbox_prob
from(
	select 
		rn
		,page_pair
		,all_mc.cnt as avg_pct
		,switch_mc.cnt as switch_pct
		,xbox_mc.cnt as xbox_pct
	from mtanco.session_pairs as customer
	left outer join mtanco.all_mc
		on customer.page_pair = all_mc.path
	join mtanco.xbox_mc 
		on customer.page_pair  = xbox_mc.path
	join mtanco.switch_mc
		on customer.page_pair  = switch_mc.path
) as probs


--look at best fit category over time
select
	rn
	,  exp (sum (ln (avg_pct))
		OVER (ORDER BY rn ROWS 
		BETWEEN UNBOUNDED PRECEDING 
		AND CURRENT ROW))  as avg_prob
	,  exp (sum (ln (switch_pct))
		OVER (ORDER BY rn ROWS 
		BETWEEN UNBOUNDED PRECEDING 
		AND CURRENT ROW))  as switch_prob
	,  exp (sum (ln (xbox_pct))
		OVER (ORDER BY rn ROWS 
		BETWEEN UNBOUNDED PRECEDING 
		AND CURRENT ROW))  as xbox_prob
from(
	select 
		rn
		,page_pair
		,all_mc.cnt as avg_pct
		,switch_mc.cnt as switch_pct
		,xbox_mc.cnt as xbox_pct
	from mtanco.session_pairs as customer
	left outer join mtanco.all_mc
		on customer.page_pair = all_mc.path
	join mtanco.xbox_mc 
		on customer.page_pair  = xbox_mc.path
	join mtanco.switch_mc
		on customer.page_pair  = switch_mc.path
) as probs

