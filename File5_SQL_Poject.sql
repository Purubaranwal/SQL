/* Problem Statement 1: 
Johansson is trying to prepare a report on patients who have gone through treatments more than once. Help Johansson prepare a report that shows the patient's name, the number of treatments they have undergone, and their age, Sort the data in a way that the patients who have undergone more treatments appear on top. */

select patientid, personname, timestampdiff(year, dob, curdate()) as age , count(treatmentID) as times
from treatment t left join person p on t.patientid = p.personid left join patient pt using(patientid)
group by patientid, personname
having count(treatmentid) > 1
order by count(treatmentid) desc;
-- ---------------------------------------------------------------------------------------------------------------------
/* Problem Statement 2:  
Bharat is researching the impact of gender on different diseases, He wants to analyze if a certain disease is more likely to infect a certain gender or not.
Help Bharat analyze this by creating a report showing for every disease how many males and females underwent treatment for each in the year 2021. It would also be helpful for Bharat if the male-to-female ratio is also shown. */
with cte as (
select diseaseid, diseasename, gender, count(distinct patientid) as patients
from disease d left join treatment t using(diseaseid) left join patient pt using(patientid) left join person pr on pt.patientid = pr.personid
where year(date) = 2021 group by diseaseid, diseasename, gender )
select diseaseid, diseasename,
sum(case when gender = 'male' then patients else 0 end) as male,
sum(case when gender = 'female' then patients else 0 end) as female,
sum(case when gender = 'male' then patients else 0 end) /
sum(case when gender = 'female' then patients else 0 end) as male_female_ratio
from cte group by diseasename;
-- ---------------------------------------------------------------------------------------------------------------------
/* Problem Statement 3:  
Kelly, from the Fortis Hospital management, has requested a report that shows for each disease, the top 3 cities that had the most number treatment for that disease.
Generate a report for Kelly’s requirement. */
select * from (select  diseaseid, diseasename, city, count(treatmentid) as no_of_treatments, 
rank() over(partition by diseaseid, diseasename order by count(treatmentid) desc) as rk
from disease left join treatment using(diseaseid) left join person on treatment.patientID = person.personID left join address using(addressid) 
group by diseaseid, diseasename, city ) a where rk <=3;
-- ---------------------------------------------------------------------------------------------------------------------
/* Problem Statement 4: 
Brooke is trying to figure out if patients with a particular disease are preferring some pharmacies over others or not, For this purpose, she has requested a detailed pharmacy report that shows each pharmacy name, and how many prescriptions they have prescribed for each disease in 2021 and 2022, She expects the number of prescriptions prescribed in 2021 and 2022 be displayed in two separate columns.
Write a query for Brooke’s requirement. */
select diseaseName,pharmacyname, count(prescriptionID) as `all`,
count(case when date between '2021-01-01' and '2021-12-31' then prescriptionID else null end) as _2021,
count(case when date between '2022-01-01' and '2022-12-31' then prescriptionID else null end) as _2022
from pharmacy ph left join prescription pr using(pharmacyid) left join treatment tr using(treatmentid) join disease d using(diseaseid) left join address using(addressid)
where date between '2021-01-01' and '2022-12-31'
group by diseaseName,pharmacyname
order by diseaseName,pharmacyname; 

-- ---------------------------------------------------------------------------------------------------------------------
/* Problem Statement 5:  
Walde, from Rock tower insurance, has sent a requirement for a report that presents which insurance company is targeting the patients of which state the most. 
Write a query for Walde that fulfills the requirement of Walde.
Note: We can assume that the insurance company is targeting a region more if the patients of that region are claiming more insurance of that company. */

select companyname, state, no_of_patients from 
(select companyname, state, count(distinct claimID) as no_of_patients,
rank() over(partition by companyname  order by count(distinct claimid) desc) as top
from treatment tr join person pr on tr.patientid = pr.personid join address using(addressid) join claim using(claimid) join insuranceplan using(uin) join insurancecompany using (companyid) 
group by companyname, state ) a where top =1;  

select * from insurancecompany;
-- **********************************************************

