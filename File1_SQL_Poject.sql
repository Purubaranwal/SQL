
use sql_project;

select count(*) from keep; /*55562*/  /* Since there is no point in having the primary key constraint. Because in future it will obstruct the new data to be being inserted. I'm removing the constraints. */ 
select count(*) from medicine; -- 49301
select count(*) from patient; -- 1126
select count(*) from prescription; -- 13428
select count(*) from pharmacy; -- 213
select count(*) from person; -- 2678
select count(*) from treatment; -- 10885
select count(*) from address; -- 2561
select count(*) from claim; -- 6963
select count(*) from contain; -- 54762
select count(*) from disease; -- 40
select count(*) from insurancecompany; -- 43
SELECT COUNT(*) FROM insuranceplan; /*183*/ /* Three Rows got deleted. two are same uin but different company id, one was pure duplicate*/  



-- --------------------------------------------------------------------------------------------------------------------------------------------------------
/* Problem Statement 1:  Jimmy, from the healthcare department, has requested a report that shows how the number of treatments each age category of patients
has gone through in the year 2022. 
The age category is as follows, Children (00-14 years), Youth (15-24 years), Adults (25-64 years), and Seniors (65 years and over).
Assist Jimmy in generating the report. */ 

with cte as (select treatmentid,case 
  when timestampdiff(year,dob,curdate()) between 00 and 14 then 'Children'
  when timestampdiff(year, dob, curdate()) between 15 and 24 then 'Youth'
  when timestampdiff(year, dob, curdate()) between 25 and 64 then 'Adults'
  else 'Seniors'  end as age_group
 from treatment  left join patient using(patientid))
 select age_group , count(distinct treatmentid) from cte group by age_group;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------

/* Problem Statement 2:  Jimmy, from the healthcare department, wants to know which disease is infecting people of which gender more often.
Assist Jimmy with this purpose by generating a report that shows for each disease the male-to-female ratio. Sort the data in a way that is helpful for Jimmy.*/

with cte as (select diseasename, gender,
case when gender = 'male' then 1 else 0 end as male,
case when gender = 'female' then 1 else 0 end as female
from treatment t left join person p on t.patientid = p.personid left join disease d using(diseaseid))
select diseasename, concat((sum(male)/sum(female))*100, '%') as `male/female`
from cte group by diseasename;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------

/* Problem Statement 3: Jacob, from insurance management, has noticed that insurance claims are not made for all the treatments. He also wants to figure out if the gender of the patient has any impact on the insurance claim. Assist Jacob in this situation by generating a report that finds for each gender the number of treatments, number of claims, and treatment-to-claim ratio. And notice if there is a significant difference between the treatment-to-claim ratio of male and female patients. */
select gender, count(distinct treatmentid) as treatements, count(distinct claimid) as claim, count(distinct claimid)/count(distinct treatmentid) as `claim/treatments`
from treatment t left join person p on t.patientid = p.personid
group by gender;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------
/* Problem Statement 4: The Healthcare department wants a report about the inventory of pharmacies. Generate a report on their behalf that shows how many 
units of medicine each pharmacy has in their inventory, the total maximum retail price of those medicines, and the total price of all the medicines after 
discount. 
Note: discount field in keep signifies the percentage of discount on the maximum price. */

select pharmacyid, round(sum(quantity*maxprice),0) as total_price,  round(sum(quantity*maxprice*((100-discount)/100)),0) as real_price
from medicine m right join keep k using(medicineid)
group by pharmacyid;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------
/* Problem Statement 5:  The healthcare department suspects that some pharmacies prescribe more medicines than others in a single prescription, for them, 
generate a report that finds for each pharmacy the maximum, minimum and average number of medicines prescribed in their prescriptions. */

select pharmacyid, max(total_quantity), min(total_quantity), round(avg(total_quantity),0) from
(select pharmacyid,prescriptionid , sum(quantity) as total_quantity
from pharmacy p left join prescription pr using(pharmacyid) left join contain c using(prescriptionid)
group by pharmacyid,prescriptionid) a group by pharmacyid;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------
