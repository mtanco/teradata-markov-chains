/* Build markov chain off of entire data set */

--only run once for time :)
/*DROP TABLE mtanco.all_mc;
CREATE TABLE mtanco.all_mc AS (
	SELECT '[' || page1 || ',' || page2 || ']' as path
		, COUNT(*) * 1.00 / SUM(COUNT(*)) 
			OVER( PARTITION BY page1 ) AS cnt
	FROM nPath ( 
		ON (
			select *
			from mtanco.mt_retail_npath
		) AS "input1"
			PARTITION BY customerid,sessionid 
			ORDER BY tstamp
		USING  
			Mode (OVERLAPPING) 
			Pattern ('A.A') 
			Symbols ( 
				TRUE as A
			) 
			Result (
				first(page of A) as page1
				,last(page of A) as page2
			) 
	) AS np
	GROUP BY page1, page2
) WITH DATA NO PRIMARY INDEX ;
*/

--name=markov_chains
select * 
from mtanco.all_mc
where cnt > 0;

/*Markov chains for specfic types of customers*/

--name=cart_counts
select * from (
	select 'Switch' as nm, count(distinct customerid) as cnt
	from beehive.retail_console
	where cart = 'SWITCH'
	
	UNION ALL
	
	select 'Xbox' as nm, count(distinct customerid) as cnt
	from beehive.retail_console
	where cart = 'XBOX'
) as cnts;
 
-- nm     cnt      
-- ------ -------- 
-- Xbox    8495.00
-- Switch 12852.00


--name=switch_mc
SELECT *
FROM(
	SELECT '[' || page1 || ',' || page2 || ']' as path
		, COUNT(*) * 1.00 / SUM(COUNT(*)) 
			OVER( PARTITION BY page1 ) AS cnt
	FROM nPath ( 
		ON (
			select *
			from mtanco.mt_retail_npath
			where customerid in (
				select distinct customerid
				from beehive.retail_console
				where cart = 'SWITCH'
			)
		) AS "input1"
			PARTITION BY customerid,sessionid 
			ORDER BY tstamp
		USING  
			Mode (OVERLAPPING) 
			Pattern ('A.A') 
			Symbols ( 
				TRUE as A
			) 
			Result (
				first(page of A) as page1
				,last(page of A) as page2
			) 
	) AS np
	GROUP BY page1, page2
) AS agg
where cnt > 0;

--name=xbox_mc
SELECT *
FROM(
	SELECT '[' || page1 || ',' || page2 || ']' as path
		, COUNT(*) * 1.00 / SUM(COUNT(*)) 
			OVER( PARTITION BY page1 ) AS cnt
	FROM nPath ( 
		ON (
			select *
			from mtanco.mt_retail_npath
			where customerid in (
				select distinct customerid
				from beehive.retail_console
				where cart = 'XBOX'
			)
		) AS "input1"
			PARTITION BY customerid,sessionid 
			ORDER BY tstamp
		USING  
			Mode (OVERLAPPING) 
			Pattern ('A.A') 
			Symbols ( 
				TRUE as A
			) 
			Result (
				first(page of A) as page1
				,last(page of A) as page2
			) 
	) AS np
	GROUP BY page1, page2
) AS agg
where cnt > 0;
