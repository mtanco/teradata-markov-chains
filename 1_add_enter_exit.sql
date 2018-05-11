/* Michelle Tanco - 05/11/2018
 * 1_add_enter_exit.sql
 * 
 * Build sample data set and
 * for every session add a "Start" and "Stop" event
 * */

--Create statement for sample data, load into this table
show table retail_base;
CREATE MULTISET TABLE retail_base ,FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO,
     MAP = TD_MAP1
     (
      customerid INTEGER,
      sessionid INTEGER,
      tstamp TIMESTAMP(6),
      page VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      cart VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC)
PRIMARY INDEX ( customerid );

--LOAD DATA AND THEN DO THE NEXT STEPS

--Add Start before first page in session
insert into mtanco.retail_base
select customerid, sessionid
	, min(tstamp) - interval '1' second as tstamp
	, 'ENTER' as page
	, null as cart
from retail_base
group by customerid, sessionid;

--Add End before first page in session
insert into retail_base
select customerid, sessionid
	, max(tstamp) + interval '1' second as tstamp
	, 'EXIT' as page
	, null as cart
from retail_base
group by customerid, sessionid;

select top 25 * 
from retail_base
order by 1,2,3;

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




