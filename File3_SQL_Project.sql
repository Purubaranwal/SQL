/* Problem Statement 1:  Some complaints have been lodged by patients that they have been prescribed hospital-exclusive medicine that they can’t find elsewhere and facing problems due to that. Joshua, from the pharmacy management, wants to get a report of which pharmacies have prescribed hospital-exclusive medicines the most in the years 2021 and 2022. Assist Joshua to generate the report so that the pharmacies who prescribe hospital-exclusive medicine more often are advised to avoid such practice if possible.   */

select pharmacyid,pharmacyname ,count(*) as no_of_exclusive_medicine
from prescription p join contain c using(prescriptionid) left join pharmacy using(pharmacyid)
where medicineid in (select medicineid from medicine where hospitalExclusive = 's') and treatmentid in (select treatmentid from treatment where year(date) in (2021,2022))
group by pharmacyid,pharmacyname
order by count(*) desc;
-- -------------------------------------------------------------------------------------------------------------
/* Problem Statement 2: Insurance companies want to assess the performance of their insurance plans. Generate a report that shows each insurance plan, the company that issues the plan, and the number of treatments the plan was claimed for. */
select planname, companyname, count(claimid) as number_of_claims
from claim c join insuranceplan using(uin) join insurancecompany using(companyid)
group by  planname, companyname
order by companyName,number_of_claims;

-- -------------------------------------------------------------------------------------------------------------
/* Problem Statement 3: Insurance companies want to assess the performance of their insurance plans. Generate a report that shows each insurance company's name with their most and least claimed insurance plans. */
with cte as (
select companyname, planname, count(claimid),
dense_rank() over(partition by companyName order by count(claimid) desc) as top,
dense_rank() over(partition by companyName order by count(claimid) asc) as bottom
from insurancecompany left join insuranceplan using(companyid) left join claim using(uin) left join treatment using(claimid)
group by companyname, planname)
select * from cte where top = 1 or bottom = 1 order by companyname, top;

/* Data is not very clean as there are multiple places where ltd and ltd. is present is same company */
-- -------------------------------------------------------------------------------------------------------------
/* Problem Statement 4:  The healthcare department wants a state-wise health report to assess which state requires more attention in the healthcare sector. Generate a report for them that shows the state name, number of registered people in the state, number of registered patients in the state, and the people-to-patient ratio. sort the data by people-to-patient ratio. */

select state, count(personid) as people, count(patientID) as patient, count(patientID)/count(personid) as people_patient_Ratio
from person left join patient on person.personid = patient.patientid right join address using(addressid)
group by state order by count(patientID)/count(personid) desc;
-- -------------------------------------------------------------------------------------------------------------
/* Problem Statement 5:  Jhonny, from the finance department of Arizona(AZ), has requested a report that lists the total quantity of medicine each pharmacy in his state has prescribed that falls under Tax criteria I for treatments that took place in 2021. Assist Jhonny in generating the report. */

select pharmacyID, pharmacyName, sum(quantity) as total_of_quantity 
from prescription join contain using(prescriptionid) join medicine using(medicineid) join
pharmacy using(pharmacyid) join address using(addressid) join treatment t using(treatmentid)
where state = 'az' and taxcriteria = 'I' and year(date)=2021
group by pharmacyID, pharmacyName;

-- -------------------------------------------------------------------------------------------------------------

