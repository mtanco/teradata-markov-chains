--name=all_path
select * from all_path;

--name=item_gone
SELECT 
	,page_path as path
	,count(*) as cnt
FROM nPath ( 
	ON retail_base AS "input1"
		PARTITION BY customerid,sessionid 
		ORDER BY tstamp
	USING  
		Mode (NONOVERLAPPING) 
		Pattern ('A*.I.NI') 
		Symbols ( 
			cart is not null as I
			,cart is null as NI
			,TRUE as A
		) 
		Result (
			first(page of I) as last_item
			,first(page of NI) as no_item
			,accumulate(page of any(I,NI,A)) as page_path
		) 
) AS np
group by 1;
