/* Michelle Tanco - 05/11/2018
 * 5_predictions.sql
 * 
 * Using our different models, we predict what segment a
 * given session fits into
 * 
 * Normally we would use a new session, not one that helped build the 
 * models :D
 * */


--First five rows of a specific session
select top 5
	row_number() over (order by tstamp) as rn
	,customerid
	,sessionid
	,page
from retail_base as a
where customerid = 350109 
and sessionid = 0
order by tstamp

-- rn customerid sessionid page         
-- -- ---------- --------- ------------ 
--  1     350109         0 ENTER       
--  2     350109         0 VIEW PRODUCT
--  3     350109         0 ADD TO CART 
--  4     350109         0 VIEW PRODUCT
--  5     350109         0 REVIEW CART 


--get pairs
drop table session_pairs;
create volatile table session_pairs as (
	SELECT rn, cast(page_pair as VARCHAR(103)) as page_pair
	FROM nPath ( 
		ON (
			select top 5
				row_number() over (order by tstamp) as rn
				,customerid
				,sessionid
				,page
			from retail_base as a
			where customerid = 350109 
			and sessionid = 0
			order by tstamp
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
from session_pairs
order by rn

-- rn page_pair                   
-- -- --------------------------- 
--  1 [ENTER, VIEW PRODUCT]      
--  2 [VIEW PRODUCT, ADD TO CART]
--  3 [ADD TO CART, VIEW PRODUCT]
--  4 [VIEW PRODUCT, REVIEW CART]

--see probability at each step of the model
select 
	rn
	,page_pair
	,all_mc.cnt as avg_pct
	,switch_mc.cnt as switch_pct
	,xbox_mc.cnt as xbox_pct
from session_pairs as customer
join all_mc
	on customer.page_pair = all_mc.path
left outer join xbox_mc 
	on customer.page_pair  = xbox_mc.path
left outer join switch_mc
	on customer.page_pair  = switch_mc.path
order by rn;

-- rn page_pair                   avg_pct switch_pct xbox_pct 
-- -- --------------------------- ------- ---------- -------- 
--  1 [ENTER, VIEW PRODUCT]          0.71       0.91     0.91
--  2 [VIEW PRODUCT, ADD TO CART]    0.09       0.15     0.15
--  3 [ADD TO CART, VIEW PRODUCT]    0.26       0.26     0.26
--  4 [VIEW PRODUCT, REVIEW CART]    0.01       0.01     0.01


--After 4 steps, what segment do we look like?
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
	from session_pairs as customer
	left outer join all_mc
		on customer.page_pair = all_mc.path
	join xbox_mc 
		on customer.page_pair  = xbox_mc.path
	join switch_mc
		on customer.page_pair  = switch_mc.path
) as probs

-- avg_prob              switch_prob          xbox_prob             
-- --------------------- -------------------- --------------------- 
-- 1.6613999999999998E-4 3.549000000000004E-4 3.2200000000000035E-4


--What type of shopper is the segment at each step?
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
	from session_pairs as customer
	left outer join all_mc
		on customer.page_pair = all_mc.path
	join xbox_mc 
		on customer.page_pair  = xbox_mc.path
	join switch_mc
		on customer.page_pair  = switch_mc.path
) as probs;


-- rn avg_prob              switch_prob          xbox_prob             
-- -- --------------------- -------------------- --------------------- 
--  1                  0.71                 0.91                  0.92
--  2                0.0639               0.1365                0.1288
--  3              0.016614 0.035490000000000015   0.03220000000000001
--  4 1.6614000000000028E-4 3.549000000000004E-4 3.2200000000000035E-4

