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

-- path                                                   cnt  
-- ------------------------------------------------------ ---- 
-- [SEARCH,REVIEW CART]                                   0.00
-- [VIEW PRODUCT,ADD TO CART]                             0.00
-- [VIEW PRODUCT,REVIEW CART]                             0.00
-- [VIEW PRODUCT,EXIT]                                    0.00
-- [REVIEW CART,DELAYED SHIPPING NOTIFICATION]            0.02
-- [ENTER PAYMENT INFORMATION,EXIT]                       0.05
-- [ENTER PAYMENT INFORMATION,VIEW PRODUCT]               0.05
-- [ENTER PAYMENT INFORMATION,SEARCH]                     0.06
-- [CONFIRM ORDER,EXIT]                                   0.08
-- [ENTER SHIPPING INFORMATION,SEARCH]                    0.09
-- [PURCHASE COMPLETE,VIEW PRODUCT]                       0.09
-- [CONFIRM ORDER,SEARCH]                                 0.10
-- [CONFIRM ORDER,VIEW PRODUCT]                           0.10
-- [PURCHASE COMPLETE,SEARCH]                             0.10
-- [ENTER SHIPPING INFORMATION,VIEW PRODUCT]              0.11
-- [HOME PAGE,EXIT]                                       0.11
-- [SEARCH,EXIT]                                          0.11
-- [ADD TO CART,EXIT]                                     0.12
-- [RETURN POLICY,SEARCH]                                 0.12
-- [ENTER SHIPPING INFORMATION,EXIT]                      0.13
-- [RETURN POLICY,VIEW PRODUCT]                           0.13
-- [RETURN POLICY,EXIT]                                   0.15
-- [REVIEW CART,SHIPPING FAQ]                             0.17
-- [ENTER PAYMENT INFORMATION,SERVER ERROR]               0.18
-- [DELAYED SHIPPING NOTIFICATION,VIEW PRODUCT]           0.19
-- [DELAYED SHIPPING NOTIFICATION,EXIT]                   0.19
-- [REVIEW CART,SEARCH]                                   0.19
-- [ENTER SHIPPING INFORMATION,RETURN POLICY]             0.20
-- [REVIEW CART,VIEW PRODUCT]                             0.20
-- [REVIEW CART,EXIT]                                     0.20
-- [REVIEW CART,ENTER SHIPPING INFORMATION]               0.21
-- [SHIPPING FAQ,EXIT]                                    0.22
-- [SHIPPING FAQ,VIEW PRODUCT]                            0.23
-- [SHIPPING FAQ,SEARCH]                                  0.24
-- [ADD TO CART,VIEW PRODUCT]                             0.26
-- [ADD TO CART,SEARCH]                                   0.26
-- [SERVER ERROR,SEARCH]                                  0.31
-- [SHIPPING FAQ,ENTER SHIPPING INFORMATION]              0.31
-- [ENTER,VIEW PRODUCT]                                   0.34
-- [SERVER ERROR,VIEW PRODUCT]                            0.34
-- [SERVER ERROR,EXIT]                                    0.35
-- [ADD TO CART,REVIEW CART]                              0.36
-- [HOME PAGE,VIEW PRODUCT]                               0.44
-- [SEARCH,VIEW PRODUCT]                                  0.44
-- [HOME PAGE,SEARCH]                                     0.45
-- [SEARCH,SEARCH]                                        0.45
-- [ENTER SHIPPING INFORMATION,ENTER PAYMENT INFORMATION] 0.47
-- [VIEW PRODUCT,SEARCH]                                  0.50
-- [VIEW PRODUCT,VIEW PRODUCT]                            0.50
-- [RETURN POLICY,ENTER PAYMENT INFORMATION]              0.61
-- [DELAYED SHIPPING NOTIFICATION,SEARCH]                 0.62
-- [ENTER,HOME PAGE]                                      0.66
-- [ENTER PAYMENT INFORMATION,CONFIRM ORDER]              0.66
-- [CONFIRM ORDER,PURCHASE COMPLETE]                      0.72
-- [PURCHASE COMPLETE,EXIT]                               0.81
