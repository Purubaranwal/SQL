
/* Problem Statement 1: 
Brian, the healthcare department, has requested for a report that shows for each state how many people underwent treatment for the disease “Autism”.  He expects the report to show the data for each state as well as each gender and for each state and gender combination. 
Prepare a report for Brian for his requirement. */
select state, coalesce(gender,'both'), count(distinct patientID) as no_of_people
from disease join treatment t using(diseaseid) join person p on t.patientid = p.personid left join address using(addressid)
where diseasename = 'autism'
group by state, gender with rollup;

-- **********************************************************
-- -------------------------------------------------------------------------------------------------------------------------------
/* Problem Statement 2:  
Insurance companies want to evaluate the performance of different insurance plans they offer. 
Generate a report that shows each insurance plan, the company that issues the plan, and the number of treatments the plan was claimed for. The report would be more relevant if the data compares the performance for different years(2020, 2021 and 2022) and if the report also includes the total number of claims in the different years, as well as the total number of claims for each plan in all 3 years combined.*/  

select planname, companyname, COALESCE(year(date),'ALL') as year, count(claimid) as number_of_claims 
from insurancecompany join insuranceplan using(companyid) join claim using(uin) join treatment using(claimid) 
where year(date) in ('2020','2021','2022')
group by concat(planname, companyname), year(date) with rollup ; 

-- -------------------------------------------------------------------------------------------------------------------------------
/* Problem Statement 3:  
Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a particular region. Assist Sarah by creating a report which shows each state the number of the most and least treated diseases by the patients of that state in the year 2022. It would be helpful for Sarah if the aggregation for the different combinations is found as well. Assist Sarah to create this report. */
with cte as (select state, diseasename,count(treatmentID) as number_of_treatment, 
rank() over(partition by state order by count(treatmentID) desc) as top,
rank() over(partition by state order by count(treatmentID) asc) as bottom
from address join person p using(addressid) join treatment t on p.personid = t.patientid join disease using(diseaseid)
where year(date) = '2022'
group by state, diseasename)
select state,  coalesce(diseasename,'ALL TOP AND BOTTOM'),sum(number_of_treatment) as number_treatments
from cte where top = 1 or bottom=1
group by state, diseasename with rollup;



-- ----------------------------------------------------------------------------------------------------------------------------------------
/* Problem Statement 4: 
Jackson has requested a detailed pharmacy report that shows each pharmacy name, and how many prescriptions they have prescribed for each disease in the year 2022, along with this Jackson also needs to view how many prescriptions were prescribed by each pharmacy, and the total number prescriptions were prescribed for each disease.
Assist Jackson to create this report. */

select pharmacyname, coalesce( diseasename,'FOR All DISEASE') as diseasename ,count(prescriptionID) as number_of_prescription
from pharmacy left join prescription using(pharmacyid) left join treatment using(treatmentid) left join disease using(diseaseid)
where year(date) = 2022
group by concat(pharmacyid, pharmacyname), diseasename with rollup ;

---------------------------------------------------------------------------------------------------------------------------------------- 
/* Problem Statement 5:  
Praveen has requested for a report that finds for every disease how many males and females underwent treatment for each in the year 2022. It would be helpful for Praveen if the aggregation for the different combinations is found as well.
Assist Praveen to create this report. */
select coalesce(diseasename,'all'), coalesce(gender,'All') as gender,  count(distinct patientID) as number_of_patients
from disease join treatment using(diseaseid) join person on treatment.patientid = person.personid
where year(date) = 2022
group by diseasename, gender with rollup
