/*Problem Statement 1: A company needs to set up 3 new pharmacies, they have come up with an idea that the pharmacy can be set up in cities where the pharmacy-to-prescription ratio is the lowest and the number of prescriptions should exceed 100. Assist the company to identify those cities where the pharmacy can be set up.*/
with cte as (
select  city , pharmacyid, prescriptionid
from prescription p left join pharmacy ph using(pharmacyid) left join address a using(addressid)
), cte2 as (
select city, (count(distinct pharmacyid)/ count(distinct prescriptionid))*100 as per_100_prescription from cte group by city having count(distinct prescriptionid) > 100)
select * from cte2 order by per_100_prescription;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
/*Problem Statement 2: The State of Alabama (AL) is trying to manage its healthcare resources more efficiently. For each city in their state, they need to identify the disease for which the maximum number of patients have gone for treatment. Assist the state for this purpose.
Note: The state of Alabama is represented as AL in Address Table.*/

select city, diseaseid, diseasename, no_patients from 
(select city,diseaseid, diseasename, count(patientid) as no_patients,
rank() over(partition by city order by count(patientid) desc) as rk
from treatment t left join person p on t.patientid = p.personid left join address using(addressid) left join disease using(diseaseid)
where state = 'al' group by city,diseaseid, diseasename ) a 
where rk =1 ;


-- -----------------------------------------------------------------------------------------------------------------------------------------------------
/*Problem Statement 3: The healthcare department needs a report about insurance plans. The report is required to include the insurance plan, which was claimed the most and least for each disease.  Assist to create such a report.*/
with cte as (
select diseaseid, diseasename , planname, count(*) as times_choosen,
dense_rank() over(partition by diseaseid, diseasename order by count(*) desc) as top,
dense_rank() over(partition by diseaseid, diseasename order by count(*) asc) as bottom
from treatment t left join disease d using(diseaseid) join claim c using(claimid) left join insuranceplan ip using(uin)
group by  diseaseid, diseasename, planname 
order by diseasename)
select * from cte where top = 1 or bottom = 1 order by diseasename, top;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
/*Problem Statement 4: The Healthcare department wants to know which disease is most likely to infect multiple people in the same household. For each disease find the number of households that has more than one patient with the same disease. 
Note: 2 people are considered to be in the same household if they have the same address. */

select * from address;
with same_disease_households as 
( 
select diseaseid, address1,count(distinct t.patientid) as distinct_patients
from treatment t join person p on t.patientid = p.personid join address a using(addressid)
group by diseaseid, address1
having count(distinct t.patientid) > 1)
select diseaseid, diseasename, count(distinct address1) as households_with_multiple_Patients from same_disease_households join disease using(diseaseid) group by  diseaseid, diseasename;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------
/*Problem Statement 5:  An Insurance company wants a state wise report of the treatments to claim ratio between 1st April 2021 and 31st March 2022 (days both included). Assist them to create such a report.*/
select state,  count(claimid) / count(treatmentid) as claim_to_treatment
from treatment t join person p on t.patientid = p.personid join address a using(addressid) 
where date between '2021-03-31' and '2022-04-01'
group by state ;