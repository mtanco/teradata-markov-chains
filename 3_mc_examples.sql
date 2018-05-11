/* Michelle Tanco - 05/11/2018
 * 3_mc_exmaples.sql
 * 
 * Build 3 markov chain models 
 * 1. The "average" session, made from all sessions
 * 2. Switch model, made from sessions with a Switch in the cart
 * 3. Xbox model, made from sessions with an Xbox in the cart
 * */

--"average" MC
DROP TABLE all_mc;
CREATE TABLE all_mc AS (
	SELECT '[' || page1 || ', ' || page2 || ']' as path
		, COUNT(*) * 1.00 / SUM(COUNT(*)) 
			OVER( PARTITION BY page1 ) AS cnt
	FROM nPath ( 
		ON retail_base AS "input1"
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
DROP TABLE switch_mc;
CREATE TABLE switch_mc AS (

	SELECT '[' || page1 || ', ' || page2 || ']' as path
		, COUNT(*) * 1.00 / SUM(COUNT(*)) 
			OVER( PARTITION BY page1 ) AS cnt
	FROM nPath ( 
		ON (
			select *
			from retail_base as b
			where exists (
				select *
				from retail_base as x
				where x.cart = 'SWITCH'
				and x.customerid = b.customerid
				and x.sessionid = b.sessionid
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
DROP TABLE xbox_mc;
CREATE TABLE xbox_mc AS (

	SELECT '[' || page1 || ', ' || page2 || ']' as path
		, COUNT(*) * 1.00 / SUM(COUNT(*)) 
			OVER( PARTITION BY page1 ) AS cnt
	FROM nPath ( 
		ON (
			select *
			from retail_base as b
			where exists (
				select *
				from retail_base as x
				where x.cart = 'XBOX'
				and x.customerid = b.customerid
				and x.sessionid = b.sessionid
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
