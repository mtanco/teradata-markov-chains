<<<<<<< HEAD
/* Exploring a specific session of a specific customer */select *from beehive.retail_consolewhere customerid = 498073 and sessionid = 2order by tstamp;--customerid sessionid page         cart amount tstamp                     firstname lastname email            -- ---------- --------- ------------ ---- ------ -------------------------- --------- -------- ---------------- --    498,073         2 VIEW PRODUCT null   0.00 2017-04-11 14:16:53.000000 Porter    Gnegy    porter@gnegy.com--    498,073         2 VIEW PRODUCT null   0.00 2017-04-11 14:17:49.000000 Porter    Gnegy    porter@gnegy.com--    498,073         2 VIEW PRODUCT null   0.00 2017-04-11 14:19:46.000000 Porter    Gnegy    porter@gnegy.com--    498,073         2 VIEW PRODUCT null   0.00 2017-04-11 14:20:55.000000 Porter    Gnegy    porter@gnegy.com--    498,073         2 SEARCH       null   0.00 2017-04-11 14:22:32.000000 Porter    Gnegy    porter@gnegy.com--    498,073         2 SEARCH       null   0.00 2017-04-11 14:24:37.000000 Porter    Gnegy    porter@gnegy.com--    498,073         2 VIEW PRODUCT null   0.00 2017-04-11 14:25:26.000000 Porter    Gnegy    porter@gnegy.com--    498,073         2 SEARCH       null   0.00 2017-04-11 14:27:27.000000 Porter    Gnegy    porter@gnegy.com--    498,073         2 SEARCH       null   0.00 2017-04-11 14:29:20.000000 Porter    Gnegy    porter@gnegy.com--    498,073         2 VIEW PRODUCT null   0.00 2017-04-11 14:30:16.000000 Porter    Gnegy    porter@gnegy.com--    498,073         2 SEARCH       null   0.00 2017-04-11 14:33:11.000000 Porter    Gnegy    porter@gnegy.com--    498,073         2 SEARCH       null   0.00 2017-04-11 14:34:51.000000 Porter    Gnegy    porter@gnegy.com--    498,073         2 SEARCH       null   0.00 2017-04-11 14:35:21.000000 Porter    Gnegy    porter@gnegy.com--    498,073         2 VIEW PRODUCT null   0.00 2017-04-11 14:36:21.000000 Porter    Gnegy    porter@gnegy.com--    498,073         2 VIEW PRODUCT null   0.00 2017-04-11 14:38:27.000000 Porter    Gnegy    porter@gnegy.com--    498,073         2 SEARCH       null   0.00 2017-04-11 14:41:08.000000 Porter    Gnegy    porter@gnegy.com--    498,073         2 SEARCH       null   0.00 2017-04-11 14:43:53.000000 Porter    Gnegy    porter@gnegy.com--SELECT *FROM nPath ( 	ON (		select *		from beehive.retail_console		where customerid = 498073 		and sessionid = 2	) AS "input1"		PARTITION BY customerid,sessionid 		ORDER BY tstamp	USING  		Mode (NONOVERLAPPING) 		Pattern ('A*') 		Symbols ( 			TRUE as A		) 		Result (			first(customerid of A) as customerid			,first(sessionid of A) as sessionid			,accumulate(page of A) as page_path		) ) AS np;-- customerid sessionid page_path                                        -- ---------- --------- ------------------------------------------------ --     498073         2 Snippet:[VIEW PRODUCT, VIEW PRODUCT, VIEW PRODUCSELECT *FROM nPath ( 	ON (		select *		from beehive.retail_console		where customerid = 498073 		and sessionid = 2	) AS "input1"		PARTITION BY customerid,sessionid 		ORDER BY tstamp	USING  		Mode (OVERLAPPING) 		Pattern ('A.A') 		Symbols ( 			TRUE as A		) 		Result (			first(page of A) as page1			,last(page of A) as page2		) ) AS np;-- page1        page2        -- ------------ ------------ -- SEARCH       SEARCH      -- VIEW PRODUCT SEARCH      -- VIEW PRODUCT VIEW PRODUCT-- SEARCH       VIEW PRODUCT-- SEARCH       SEARCH      -- SEARCH       SEARCH      -- VIEW PRODUCT SEARCH      -- SEARCH       VIEW PRODUCT-- SEARCH       SEARCH      -- VIEW PRODUCT SEARCH      -- SEARCH       VIEW PRODUCT-- SEARCH       SEARCH      -- VIEW PRODUCT SEARCH      -- VIEW PRODUCT VIEW PRODUCT-- VIEW PRODUCT VIEW PRODUCT-- VIEW PRODUCT VIEW PRODUCTSELECT page1, page2, COUNT(*) AS cnt	,COUNT(*) * 1.00 / SUM(COUNT(*)) OVER( PARTITION BY page1 ) AS pctFROM nPath ( 	ON (		select *		from beehive.retail_console		where customerid = 498073 		and sessionid = 2	) AS "input1"		PARTITION BY customerid,sessionid 		ORDER BY tstamp	USING  		Mode (OVERLAPPING) 		Pattern ('A.A') 		Symbols ( 			TRUE as A		) 		Result (			first(page of A) as page1			,last(page of A) as page2		) ) AS npGROUP BY page1, page2;-- page1        page2        cnt  pct  -- ------------ ------------ ---- ---- -- SEARCH       SEARCH       5.00 0.62-- SEARCH       VIEW PRODUCT 3.00 0.38-- VIEW PRODUCT SEARCH       4.00 0.50-- VIEW PRODUCT VIEW PRODUCT 4.00 0.50--name=markov_chainSELECT '[' || page1 || ',' || page2 || ']' as path	,COUNT(*) * 1.00 / SUM(COUNT(*)) OVER( PARTITION BY page1 ) AS cntFROM nPath ( 	ON (		select *		from beehive.retail_console		where customerid = 498073 		and sessionid = 2	) AS "input1"		PARTITION BY customerid,sessionid 		ORDER BY tstamp	USING  		Mode (OVERLAPPING) 		Pattern ('A.A') 		Symbols ( 			TRUE as A		) 		Result (			first(page of A) as page1			,last(page of A) as page2		) ) AS npGROUP BY page1, page2;-- path                        cnt  -- --------------------------- ---- -- [SEARCH,SEARCH]             0.62-- [SEARCH,VIEW PRODUCT]       0.38-- [VIEW PRODUCT,SEARCH]       0.50-- [VIEW PRODUCT,VIEW PRODUCT] 0.50
=======
/* Exploring a specific session of a specific customer */

select *
from beehive.retail_console
where customerid = 498073 
and sessionid = 2
order by tstamp;

--customerid sessionid page         cart amount tstamp                     firstname lastname email            
-- ---------- --------- ------------ ---- ------ -------------------------- --------- -------- ---------------- 
--    498,073         2 VIEW PRODUCT null   0.00 2017-04-11 14:16:53.000000 Porter    Gnegy    porter@gnegy.com
--    498,073         2 VIEW PRODUCT null   0.00 2017-04-11 14:17:49.000000 Porter    Gnegy    porter@gnegy.com
--    498,073         2 VIEW PRODUCT null   0.00 2017-04-11 14:19:46.000000 Porter    Gnegy    porter@gnegy.com
--    498,073         2 VIEW PRODUCT null   0.00 2017-04-11 14:20:55.000000 Porter    Gnegy    porter@gnegy.com
--    498,073         2 SEARCH       null   0.00 2017-04-11 14:22:32.000000 Porter    Gnegy    porter@gnegy.com
--    498,073         2 SEARCH       null   0.00 2017-04-11 14:24:37.000000 Porter    Gnegy    porter@gnegy.com
--    498,073         2 VIEW PRODUCT null   0.00 2017-04-11 14:25:26.000000 Porter    Gnegy    porter@gnegy.com
--    498,073         2 SEARCH       null   0.00 2017-04-11 14:27:27.000000 Porter    Gnegy    porter@gnegy.com
--    498,073         2 SEARCH       null   0.00 2017-04-11 14:29:20.000000 Porter    Gnegy    porter@gnegy.com
--    498,073         2 VIEW PRODUCT null   0.00 2017-04-11 14:30:16.000000 Porter    Gnegy    porter@gnegy.com
--    498,073         2 SEARCH       null   0.00 2017-04-11 14:33:11.000000 Porter    Gnegy    porter@gnegy.com
--    498,073         2 SEARCH       null   0.00 2017-04-11 14:34:51.000000 Porter    Gnegy    porter@gnegy.com
--    498,073         2 SEARCH       null   0.00 2017-04-11 14:35:21.000000 Porter    Gnegy    porter@gnegy.com
--    498,073         2 VIEW PRODUCT null   0.00 2017-04-11 14:36:21.000000 Porter    Gnegy    porter@gnegy.com
--    498,073         2 VIEW PRODUCT null   0.00 2017-04-11 14:38:27.000000 Porter    Gnegy    porter@gnegy.com
--    498,073         2 SEARCH       null   0.00 2017-04-11 14:41:08.000000 Porter    Gnegy    porter@gnegy.com
--    498,073         2 SEARCH       null   0.00 2017-04-11 14:43:53.000000 Porter    Gnegy    porter@gnegy.com
--

SELECT *
FROM nPath ( 
	ON (
		select *
		from beehive.retail_console
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
--     498073         2 Snippet:[VIEW PRODUCT, VIEW PRODUCT, VIEW PRODUC

SELECT *
FROM nPath ( 
	ON (
		select *
		from beehive.retail_console
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

SELECT page1, page2, COUNT(*) AS cnt
	,COUNT(*) * 1.00 / SUM(COUNT(*)) OVER( PARTITION BY page1 ) AS pct
FROM nPath ( 
	ON (
		select *
		from beehive.retail_console
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
-- SEARCH       SEARCH       5.00 0.62
-- SEARCH       VIEW PRODUCT 3.00 0.38
-- VIEW PRODUCT SEARCH       4.00 0.50
-- VIEW PRODUCT VIEW PRODUCT 4.00 0.50
>>>>>>> 0a61f5c8ec26f9482f431e42b129118ee3ac7e87
