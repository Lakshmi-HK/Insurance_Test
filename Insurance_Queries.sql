-- SQL Queries

-- 1.	Find out which policy type is considered most for each product code.

select
      p.prod_code,
	  pt.policy_type,
      count(pt.policy_type) as Most_Considered_PolicyType
from product as p
left join policy_details as pd
    on p.prod_code = pd.prod_code
left join policytype as pt
    on pt.policy_type = pd.policy_type
group by p.prod_code, policy_type
order by Most_Considered_PolicyType desc;

-- 2.	Get the total insured sum categorised by TPA.

select
     TPA,
     sum(sum_insured) as Total_Insured_Sum
from policy_details as p
left join insurance_detail as i
    on p.policy_ID = i.policy_ID
group by TPA
order by Total_Insured_Sum desc;

-- 3.	Find the statistics of maximum, minimum and average time gap (in days) between the claim date and admit date.

select
     i.hosp_id,
     max(datediff(admit_dt ,claim_dt  )),
     min(datediff(admit_dt ,claim_dt )),
     avg(datediff(admit_dt ,claim_dt )) 
from insurance_detail as i
left join hospital_details as h
   on i.hosp_ID = h.hosp_ID
group by i.hosp_id;

/* 4.	Find the relation between the claim amount and the treatment time (difference of admit 
		date and discharge date).
*/

select
     claim_amt,
     datediff( discharge_dt , admit_dt )
from hospital_details ;

-- 5.	Get the sum of difference between claim amount and settlement amount categorised by payment type.

select
      payment_type ,
      sum(settle_amt - claim_amt)
from payment_details as p
left join insurance_detail as i
   on p.payment_ID = i.payment_ID
left join hospital_details as h
   on h.hosp_ID = i.hosp_ID
group by payment_type;
      
/* 6.	Find the statistics of maximum, minimum and average time gap (in days) between the discharge date and
		payment date categorised by payment type.
*/

select
     payment_type,
	  max(datediff(discharge_dt,payment_dt)),
      min(datediff(discharge_dt,payment_dt)),
      avg(datediff(discharge_dt,payment_dt))
from payment_details as p
left join insurance_detail as i
   on p.payment_ID = i.payment_ID
left join hospital_details as h
   on h.hosp_ID = i.hosp_ID
group by payment_type;
 
/* 7.	What is the average tenure for a policy taken categorised by the product code. (Difference between
 policy start and end date)
 */
 
 select 
	  p.prod_code,
      datediff(policy_end_date , policy_start_date) as Average_Tenure_Days
from product as p
left join policy_details as pd
    on p.prod_code = pd.prod_code
group by p.prod_code;
 
-- 8.	Find out which hospital type has claims classified as fraud more either networked or non-networked hospitals.

select
     hosp_type,
     count(hosp_type)
from insurance_detail as i
left join hospital_details as h
   on i.hosp_ID = h.hosp_ID
where fraud = 1
group by hosp_type;

-- 9.	Get the count of policy claims categorised by sex. (Based on member_id).

select 
      sex,
      count(member_id)
from policy_details
group by sex;

-- 10.	Get the count of members for each distinct policy reference value.

select * from policy_details limit 20;
     
select
     policy_ref,
     count(policy_id)
from policy_details
group by policy_ref;

-- 11.	For claims classified as fraud, get the details of claims recommended to be genuine

select
      *
from insurance_detail
where fraud = 1 and recommendation = 'Genuine';

-- 12.	Validate whether the sum of all the charges matches to the claim amount.

select
     claim_amt,
     nursing_charge + surgery_charge + cons_fee + test_charge + pharmacy_cost + other_charge + pre_hosp_charge + post_hosp_charge + other_charge_non_hosp as Total
from hospital_details;

-- 13.	Find if there are any co-payments made.

select 
     * 
from insurance_detail
where copayment = 1;

-- 14.	Which is the most commonly used payment type for the policy claims.

select
     payment_type,
     count(pd.payment_ID) 
from payment_details as pd
left join insurance_detail as i
   on pd.payment_ID = i.payment_ID
left join policy_details as p
   on i.policy_ID = p.policy_ID
group by payment_type
order by   count(pd.payment_ID) desc;

-- 15.	What is the average age of the members claiming for the insurance considering all the claim records.

select
      avg(member_age)
from policy_details as p
left join insurance_detail as i
   on p.policy_ID = i.policy_ID;

-- 16.	Get all the details of claims for the highest sum insured tpa classified as fraud.

select
      *
from insurance_detail as i
left join policy_details as p
    on i.policy_ID = p.policy_ID
where fraud = 1
order by sum_insured desc;

/* 17.	Add a new column to insurance detail table named as profit which the difference between 
       claim amount and settlement amount.
*/

alter table insurance_detail add profit float;

select * from insurance_detail limit 20;

create table newtable
(
     select 
           claim_amt - settle_amt 
     from payment_details  as p
	 left join insurance_detail as i
        on p.payment_ID = i.payment_ID
	  left join hospital_details as h
        on i.hosp_ID = h.hosp_ID
);

insert into insurance_detail(profit) select * from newtable;
-- 18.	Find out which tpa made highest profit.

select
     TPA
from insurance_detail
order by profit desc;

-- 19.	Find the relationship between sum insured and the policy tenure.

select
      sum_insured,
      policy_end_date - policy_start_date as Policy_Tenure_Days
from policy_details;

/* 20.	For a new policy insurance which tpa, product code and policy type is recommended according to your
        observation of analysis.
*/

select
      tpa,
      p.prod_code,
      pt.policy_type,
      count(id)
from product as p
left join policy_details as pd
    on p.prod_code = pd.prod_code
left join policytype as pt
    on pd.policy_type = pt.policy_type
left join insurance_detail as i
   on pd.policy_ID = i.policy_ID
 where fraud=1
 group by tpa , prod_code , policy_type
 order by  count(id) desc;
 
/* 
   Recommendation for a new policy
   tpa --> f,n,g,e 
   code --> g a f o 
   type --> a , b , c
   
*/