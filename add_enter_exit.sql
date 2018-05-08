/* Add a "page" at the start and end of each session 
 * to denote starting and stopping the session
 * */

DROP TABLE mtanco.mt_retail_npath;
CREATE TABLE mtanco.mt_retail_npath AS (
	
	select customerid, sessionid, tstamp, page
	from beehive.retail_console

) WITH DATA; 

insert into mtanco.mt_retail_npath
select customerid, sessionid
	, min(tstamp) - interval '1' second as tstamp
	, 'ENTER' as page
from beehive.retail_console
group by customerid, sessionid;

insert into mtanco.mt_retail_npath
select customerid, sessionid
	, max(tstamp) + interval '1' second as tstamp
	, 'EXIT' as page
from beehive.retail_console
group by customerid, sessionid;


select top 25 * 
from mtanco.mt_retail_npath
order by 1,2,3;

-- customerid sessionid tstamp                     page         
-- ---------- --------- -------------------------- ------------ 
--     350001         0 2017-04-10 19:20:41.000000 ENTER       
--     350001         0 2017-04-10 19:20:42.000000 VIEW PRODUCT
--     350001         0 2017-04-10 19:22:14.000000 SEARCH      
--     350001         0 2017-04-10 19:23:11.000000 VIEW PRODUCT
--     350001         0 2017-04-10 19:24:03.000000 SEARCH      
--     350001         0 2017-04-10 19:26:56.000000 SEARCH      
--     350001         0 2017-04-10 19:29:54.000000 SEARCH      
--     350001         0 2017-04-10 19:31:07.000000 VIEW PRODUCT
--     350001         0 2017-04-10 19:32:47.000000 VIEW PRODUCT
--     350001         0 2017-04-10 19:34:35.000000 VIEW PRODUCT
--     350001         0 2017-04-10 19:36:28.000000 VIEW PRODUCT
--     350001         0 2017-04-10 19:37:05.000000 SEARCH      
--     350001         0 2017-04-10 19:37:50.000000 VIEW PRODUCT
--     350001         0 2017-04-10 19:39:44.000000 VIEW PRODUCT
--     350001         0 2017-04-10 19:41:34.000000 VIEW PRODUCT
--     350001         0 2017-04-10 19:44:29.000000 SEARCH      
--     350001         0 2017-04-10 19:46:46.000000 VIEW PRODUCT
--     350001         0 2017-04-10 19:48:55.000000 SEARCH      
--     350001         0 2017-04-10 19:50:50.000000 VIEW PRODUCT
--     350001         0 2017-04-10 19:52:11.000000 SEARCH      
--     350001         0 2017-04-10 19:52:12.000000 EXIT        
--     350001         1 2017-04-28 05:58:28.000000 ENTER       
--     350001         1 2017-04-28 05:58:29.000000 HOME PAGE   
--     350001         1 2017-04-28 06:00:06.000000 SEARCH      
--     350001         1 2017-04-28 06:02:10.000000 SEARCH      


