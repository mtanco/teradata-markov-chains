/* Michelle Tanco - 05/11/2018
 * 4_visualize_mc.sql
 * 
 * Running this script in Teradata App Center would allow us
 * to view these models as sigma graphs and better understand the
 * topology
 * 
 * We use 10% as a cut off threshold of a "likely" transaction
 * although this was chosen at random and should be changed or 
 * exclude on a project by project base
 * */

--name=all_mc
select * 
from mtanco.all_mc
where cnt > 0.10;

--name=switch_mc
select * 
from mtanco.switch_mc
where cnt > 0.10;

--name=xbox_mc
select * 
from mtanco.xbox_mc
where cnt > 0.10;

--compair the probabilities in each model to understand
--differences in behaviors and segments
--name=comp_mc
select 
	a.path
	, a.cnt as all_pct
	, coalesce(x.cnt,0) as xbox_pct
	, coalesce(s.cnt,0) as switch_pct
from all_mc as a
full outer join xbox_mc as x
	on a.path = x.path
full outer join switch_mc as s
	on a.path = s.path;

--	 path                                                    all_pct xbox_pct switch_pct 
-- ------------------------------------------------------- ------- -------- ---------- 
-- [VIEW PRODUCT, SEARCH]                                     0.46     0.42       0.43
-- [ENTER SHIPPING INFORMATION, ENTER PAYMENT INFORMATION]    0.38     0.64       0.20
-- [DELAYED SHIPPING NOTIFICATION, VIEW PRODUCT]              0.50     0.00       0.50
-- [VIEW PRODUCT, ADD TO CART]                                0.09     0.14       0.15
-- [ENTER SHIPPING INFORMATION, EXIT]                         0.23     0.09       0.33
-- [VIEW PRODUCT, REVIEW CART]                                0.01     0.01       0.01
-- [SHIPPING FAQ, ENTER SHIPPING INFORMATION]                 0.21     0.27       0.00
-- [ADD TO CART, REVIEW CART]                                 0.37     0.33       0.41
-- [ENTER SHIPPING INFORMATION, SEARCH]                       0.08     0.09       0.07
-- [SHIPPING FAQ, VIEW PRODUCT]                               0.29     0.27       0.33
-- [SERVER ERROR, VIEW PRODUCT]                               0.67     1.00       0.50
-- [REVIEW CART, VIEW PRODUCT]                                0.17     0.20       0.15
-- [DELAYED SHIPPING NOTIFICATION, SEARCH]                    0.50     0.00       0.50
-- [RETURN POLICY, ENTER PAYMENT INFORMATION]                 0.80     1.00       0.67
-- [CONFIRM ORDER, PURCHASE COMPLETE]                         0.60     0.71       0.33
-- [SEARCH, EXIT]                                             0.12     0.14       0.14
-- [PURCHASE COMPLETE, VIEW PRODUCT]                          0.17     0.20       0.00
-- [REVIEW CART, DELAYED SHIPPING NOTIFICATION]               0.02     0.00       0.04
-- [ENTER PAYMENT INFORMATION, CONFIRM ORDER]                 0.71     0.78       0.60
-- [SERVER ERROR, SEARCH]                                     0.33     0.00       0.50
-- [CONFIRM ORDER, SEARCH]                                    0.20     0.14       0.33
-- [SHIPPING FAQ, EXIT]                                       0.29     0.27       0.33
-- [ENTER, VIEW PRODUCT]                                      0.71     0.92       0.91
-- [SEARCH, SEARCH]                                           0.44     0.43       0.43
-- [ADD TO CART, EXIT]                                        0.15     0.16       0.14
-- [ENTER SHIPPING INFORMATION, VIEW PRODUCT]                 0.12     0.00       0.20
-- [SEARCH, VIEW PRODUCT]                                     0.44     0.43       0.42
-- [ENTER, HOME PAGE]                                         0.29     0.08       0.09
-- [VIEW PRODUCT, EXIT]                                       0.00     0.00       0.00
-- [ENTER PAYMENT INFORMATION, SERVER ERROR]                  0.21     0.11       0.40
-- [SHIPPING FAQ, SEARCH]                                     0.21     0.18       0.33
-- [ENTER SHIPPING INFORMATION, RETURN POLICY]                0.19     0.18       0.20
-- [REVIEW CART, SHIPPING FAQ]                                0.16     0.28       0.07
-- [REVIEW CART, EXIT]                                        0.19     0.20       0.17
-- [ENTER PAYMENT INFORMATION, SEARCH]                        0.07     0.11       0.00
-- [SEARCH, REVIEW CART]                                      0.00     0.01       0.00
-- [HOME PAGE, VIEW PRODUCT]                                  0.52     0.50       0.56
-- [HOME PAGE, SEARCH]                                        0.42     0.50       0.33
-- [CONFIRM ORDER, EXIT]                                      0.10     0.00       0.33
-- [REVIEW CART, SEARCH]                                      0.19     0.12       0.24
-- [PURCHASE COMPLETE, EXIT]                                  0.83     0.80       1.00
-- [HOME PAGE, EXIT]                                          0.06     0.00       0.11
-- [ADD TO CART, SEARCH]                                      0.23     0.26       0.19
-- [VIEW PRODUCT, VIEW PRODUCT]                               0.44     0.42       0.40
-- [REVIEW CART, ENTER SHIPPING INFORMATION]                  0.27     0.20       0.33
-- [RETURN POLICY, SEARCH]                                    0.20     0.00       0.33
-- [ADD TO CART, VIEW PRODUCT]                                0.26     0.25       0.26
-- [CONFIRM ORDER, VIEW PRODUCT]                              0.10     0.14       0.00
