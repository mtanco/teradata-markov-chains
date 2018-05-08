/* Exploring a specific session of a specific customer */

select *
from mtanco.mt_retail_npath
where customerid = 498073 
and sessionid = 2
order by tstamp;

-- customerid sessionid tstamp                     page         
-- ---------- --------- -------------------------- ------------ 
--     498073         2 2017-04-11 14:16:52.000000 ENTER       
--     498073         2 2017-04-11 14:16:53.000000 VIEW PRODUCT
--     498073         2 2017-04-11 14:17:49.000000 VIEW PRODUCT
--     498073         2 2017-04-11 14:19:46.000000 VIEW PRODUCT
--     498073         2 2017-04-11 14:20:55.000000 VIEW PRODUCT
--     498073         2 2017-04-11 14:22:32.000000 SEARCH      
--     498073         2 2017-04-11 14:24:37.000000 SEARCH      
--     498073         2 2017-04-11 14:25:26.000000 VIEW PRODUCT
--     498073         2 2017-04-11 14:27:27.000000 SEARCH      
--     498073         2 2017-04-11 14:29:20.000000 SEARCH      
--     498073         2 2017-04-11 14:30:16.000000 VIEW PRODUCT
--     498073         2 2017-04-11 14:33:11.000000 SEARCH      
--     498073         2 2017-04-11 14:34:51.000000 SEARCH      
--     498073         2 2017-04-11 14:35:21.000000 SEARCH      
--     498073         2 2017-04-11 14:36:21.000000 VIEW PRODUCT
--     498073         2 2017-04-11 14:38:27.000000 VIEW PRODUCT
--     498073         2 2017-04-11 14:41:08.000000 SEARCH      
--     498073         2 2017-04-11 14:43:53.000000 SEARCH      
--     498073         2 2017-04-11 14:43:54.000000 EXIT        

SELECT *
FROM nPath ( 
	ON (
		select *
		from mtanco.mt_retail_npath
		where customerid = 498073 
		and sessionid = 2
	) AS "input1"
		PARTITION BY customerid,sessionid 
		ORDER BY tstamp
	USING  
		Mode (NONOVERLAPPING) 
		Pattern ('A*') 
		Symbols ( 
			TRUE as A
		) 
		Result (
			first(customerid of A) as customerid
			,first(sessionid of A) as sessionid
			,accumulate(page of A) as page_path
		) 
) AS np;

-- customerid sessionid page_path                                        
-- ---------- --------- ------------------------------------------------ 
--     498073         2 Snippet:[ENTER, VIEW PRODUCT, VIEW PRODUCT, VIEW


SELECT *
FROM nPath ( 
	ON (
		select *
		from mtanco.mt_retail_npath
		where customerid = 498073 
		and sessionid = 2
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
) AS np;

-- page1        page2        
-- ------------ ------------ 
-- SEARCH       EXIT        
-- SEARCH       SEARCH      
-- VIEW PRODUCT SEARCH      
-- VIEW PRODUCT VIEW PRODUCT
-- SEARCH       VIEW PRODUCT
-- SEARCH       SEARCH      
-- SEARCH       SEARCH      
-- VIEW PRODUCT SEARCH      
-- SEARCH       VIEW PRODUCT
-- SEARCH       SEARCH      
-- VIEW PRODUCT SEARCH      
-- SEARCH       VIEW PRODUCT
-- SEARCH       SEARCH      
-- VIEW PRODUCT SEARCH      
-- VIEW PRODUCT VIEW PRODUCT
-- VIEW PRODUCT VIEW PRODUCT
-- VIEW PRODUCT VIEW PRODUCT
-- ENTER        VIEW PRODUCT


SELECT page1, page2, COUNT(*) AS cnt
	,COUNT(*) * 1.00 / SUM(COUNT(*)) OVER( PARTITION BY page1 ) AS pct
FROM nPath ( 
	ON (
		select *
		from mtanco.mt_retail_npath
		where customerid = 498073 
		and sessionid = 2
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
GROUP BY page1, page2;

-- page1        page2        cnt  pct  
-- ------------ ------------ ---- ---- 
-- ENTER        VIEW PRODUCT 1.00 1.00
-- SEARCH       EXIT         1.00 0.11
-- SEARCH       SEARCH       5.00 0.56
-- SEARCH       VIEW PRODUCT 3.00 0.33
-- VIEW PRODUCT SEARCH       4.00 0.50
-- VIEW PRODUCT VIEW PRODUCT 4.00 0.50

--name=markov_chains
SELECT '[' || page1 || ',' || page2 || ']' as path
	, COUNT(*) * 1.00 / SUM(COUNT(*)) OVER( PARTITION BY page1 ) AS cnt
FROM nPath ( 
	ON (
		select *
		from mtanco.mt_retail_npath
		where customerid = 498073 
		and sessionid = 2
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
GROUP BY page1, page2;

-- path                        cnt  
-- --------------------------- ---- 
-- [ENTER,VIEW PRODUCT]        1.00
-- [SEARCH,EXIT]               0.11
-- [SEARCH,SEARCH]             0.56
-- [SEARCH,VIEW PRODUCT]       0.33
-- [VIEW PRODUCT,SEARCH]       0.50
-- [VIEW PRODUCT,VIEW PRODUCT] 0.50

