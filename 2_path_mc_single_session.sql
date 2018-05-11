/* Michelle Tanco - 05/11/2018
 * 2_single_session_demo.sql
 * 
 * Build a markov chain off of a single session
 * */


select *
from retail_base
where customerid = 350109 
and sessionid = 0
order by tstamp;

-- customerid sessionid tstamp                     page         cart   
-- ---------- --------- -------------------------- ------------ ------ 
--     350109         0 2017-01-03 14:57:49.000000 ENTER        null  
--     350109         0 2017-01-03 14:57:50.000000 VIEW PRODUCT null  
--     350109         0 2017-01-03 15:00:15.000000 ADD TO CART  SWITCH
--     350109         0 2017-01-03 15:01:03.000000 VIEW PRODUCT SWITCH
--     350109         0 2017-01-03 15:02:41.000000 REVIEW CART  SWITCH
--     350109         0 2017-01-03 15:03:49.000000 SEARCH       null  
--     350109         0 2017-01-03 15:05:40.000000 SEARCH       null  
--     350109         0 2017-01-03 15:06:59.000000 SEARCH       null  
--     350109         0 2017-01-03 15:09:59.000000 VIEW PRODUCT null  
--     350109         0 2017-01-03 15:10:32.000000 VIEW PRODUCT null  
--     350109         0 2017-01-03 15:11:47.000000 VIEW PRODUCT null  
--     350109         0 2017-01-03 15:13:44.000000 SEARCH       null  
--     350109         0 2017-01-03 15:14:29.000000 SEARCH       null  
--     350109         0 2017-01-03 15:15:04.000000 SEARCH       null  
--     350109         0 2017-01-03 15:17:02.000000 VIEW PRODUCT null  
--     350109         0 2017-01-03 15:18:38.000000 VIEW PRODUCT null  
--     350109         0 2017-01-03 15:18:53.000000 SEARCH       null  
--     350109         0 2017-01-03 15:21:50.000000 SEARCH       null  
--     350109         0 2017-01-03 15:22:37.000000 SEARCH       null  
--     350109         0 2017-01-03 15:24:29.000000 VIEW PRODUCT null  
--     350109         0 2017-01-03 15:25:07.000000 VIEW PRODUCT null  
--     350109         0 2017-01-03 15:27:34.000000 VIEW PRODUCT null  
--     350109         0 2017-01-03 15:29:12.000000 VIEW PRODUCT null  
--     350109         0 2017-01-03 15:29:35.000000 VIEW PRODUCT null  
--     350109         0 2017-01-03 15:31:26.000000 SEARCH       null  
--     350109         0 2017-01-03 15:31:27.000000 EXIT         null  


--first nPath, look at full page path of the session
SELECT *
FROM nPath ( 
	ON (
		select *
		from retail_base
		where customerid = 350109 
		and sessionid = 0
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
--     350109         0 [ENTER, VIEW PRODUCT, ADD TO CART, VIEW ...

--Next, for every page return the next page
SELECT *
FROM nPath ( 
	ON (
		select *
		from retail_base
		where customerid = 350109 
		and sessionid = 0
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
-- VIEW PRODUCT SEARCH      
-- VIEW PRODUCT VIEW PRODUCT
-- VIEW PRODUCT VIEW PRODUCT
-- VIEW PRODUCT VIEW PRODUCT
-- VIEW PRODUCT VIEW PRODUCT
-- SEARCH       VIEW PRODUCT
-- SEARCH       SEARCH      
-- SEARCH       SEARCH      
-- VIEW PRODUCT SEARCH      
-- VIEW PRODUCT VIEW PRODUCT
-- SEARCH       VIEW PRODUCT
-- SEARCH       SEARCH      
-- SEARCH       SEARCH      
-- VIEW PRODUCT SEARCH      
-- VIEW PRODUCT VIEW PRODUCT
-- VIEW PRODUCT VIEW PRODUCT
-- SEARCH       VIEW PRODUCT
-- SEARCH       SEARCH      
-- SEARCH       SEARCH      
-- REVIEW CART  SEARCH      
-- VIEW PRODUCT REVIEW CART 
-- ADD TO CART  VIEW PRODUCT
-- VIEW PRODUCT ADD TO CART 
-- ENTER        VIEW PRODUCT

--now we count how many times we go from one page to the next
-- and is the probability of going from each page to each other page
--		(markov chain!)
SELECT page1, page2, COUNT(*) AS cnt
	,COUNT(*) * 1.00 / SUM(COUNT(*)) OVER( PARTITION BY page1 ) AS pct
FROM nPath ( 
	ON (
		select *
		from retail_base
		where customerid = 350109 
		and sessionid = 0
	) AS "input1"
		PARTITION BY customerid,sessionid 
		ORDER BY tstamp
	USING  
		Mode (OVERLAPPING) 
		Pattern ('A.A.A') 
		Symbols ( 
			TRUE as A
		) 
		Result (
			first(page of A) as page1
			,last(page of A) as page2
		) 
) AS np
GROUP BY page1, page2;

-- page1        page2        cnt pct  
-- ------------ ------------ --- ---- 
-- ADD TO CART  REVIEW CART    1 1.00
-- ENTER        ADD TO CART    1 1.00
-- REVIEW CART  SEARCH         1 1.00
-- SEARCH       SEARCH         3 0.33
-- SEARCH       VIEW PRODUCT   6 0.67
-- VIEW PRODUCT SEARCH         6 0.50
-- VIEW PRODUCT VIEW PRODUCT   5 0.42
-- VIEW PRODUCT EXIT           1 0.08

--formatted nicely for Teradata App center
--name=markov_chains
SELECT '[' || page1 || ',' || page2 || ']' as path
	, COUNT(*) * 1.00 / SUM(COUNT(*)) OVER( PARTITION BY page1 ) AS cnt
FROM nPath ( 
	ON (
		select *
		from retail_base
		where customerid = 350109 
		and sessionid = 0
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
-- [ADD TO CART,VIEW PRODUCT]  1.00
-- [ENTER,VIEW PRODUCT]        1.00
-- [REVIEW CART,SEARCH]        1.00
-- [SEARCH,SEARCH]             0.60
-- [SEARCH,EXIT]               0.10
-- [SEARCH,VIEW PRODUCT]       0.30
-- [VIEW PRODUCT,VIEW PRODUCT] 0.58
-- [VIEW PRODUCT,SEARCH]       0.25
-- [VIEW PRODUCT,ADD TO CART]  0.08
-- [VIEW PRODUCT,REVIEW CART]  0.08
