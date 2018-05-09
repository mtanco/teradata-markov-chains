/* Build markov chain off of entire data set */

--"average" MC
DROP TABLE mtanco.all_mc;
CREATE TABLE mtanco.all_mc AS (
	SELECT '[' || page1 || ', ' || page2 || ']' as path
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

-- Switch in cart MC
DROP TABLE mtanco.switch_mc;
CREATE TABLE mtanco.switch_mc AS (

	SELECT '[' || page1 || ', ' || page2 || ']' as path
		, COUNT(*) * 1.00 / SUM(COUNT(*)) 
			OVER( PARTITION BY page1 ) AS cnt
	FROM nPath ( 
		ON (
			select *
			from mtanco.mt_retail_npath
			where customerid || '_' || sessionid in (
				select distinct customerid || '_' || sessionid
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

) WITH DATA NO PRIMARY INDEX ;

--Xbox in cart MC
DROP TABLE mtanco.xbox_mc;
CREATE TABLE mtanco.xbox_mc AS (

	SELECT '[' || page1 || ', ' || page2 || ']' as path
		, COUNT(*) * 1.00 / SUM(COUNT(*)) 
			OVER( PARTITION BY page1 ) AS cnt
	FROM nPath ( 
		ON (
			select *
			from mtanco.mt_retail_npath
			where customerid || '_' || sessionid in (
				select distinct customerid || '_' || sessionid
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

) WITH DATA NO PRIMARY INDEX ;
