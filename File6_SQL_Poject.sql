/* Problem Statement 1: 
The healthcare department wants a pharmacy report on the percentage of hospital-exclusive medicine prescribed in the year 2022.
Assist the healthcare department to view for each pharmacy, the pharmacy id, pharmacy name, total quantity of medicine prescribed in 2022, total quantity of hospital-exclusive medicine prescribed by the pharmacy in 2022, and the percentage of hospital-exclusive medicine to the total medicine prescribed in 2022.
Order the result in descending order of the percentage found. */  
select pharmacyID, pharmacyName, sum(quantity) as total_quantity,
sum(case when hospitalExclusive = 's' then quantity else 0 end) as hospitalexclusive
from pharmacy ph left join prescription pr using(pharmacyid) left join treatment using(treatmentid) left join contain c using(prescriptionid) left join medicine m using(medicineid)
where `date` between '2022-01-01' and '2022-12-31'
group by pharmacyID, pharmacyName;

/* Problem Statement 2:  
Sarah, from the healthcare department, has noticed many people do not claim insurance for their treatment. She has requested a state-wise report of the percentage of treatments that took place without claiming insurance. Assist Sarah by creating a report as per her requirement. */

select state,(count(treatmentID) - count(claimID))*100/count(treatmentID) as treatment_to_claim_ratio
from treatment t left join person p on t.patientid = p.personid left join address using(addressid)
group by state;

/* Problem Statement 3:  
Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a particular region. Assist Sarah by creating a report which shows for each state, the number of the most and least treated diseases by the patients of that state in the year 2022. */
select state, diseasename, number_of_treatment,
case when top = 1 then 'most_spread' 
when bottom =1 then 'least_spread' 
end as tag
from 
(select state, diseasename, count(treatmentid) as number_of_treatment,
rank() over(partition by state order by count(treatmentid) desc) as top,
rank() over(partition by state order by count(treatmentid) asc) as bottom
from address left join person p using(addressid) left join treatment t on t.patientid = p.personid  join disease using(diseaseid)
where  year(t.date) = 2022 group by state, diseasename order by state) a
where top = 1 or bottom = 1 ;

/* Problem Statement 4: 
Manish, from the healthcare department, wants to know how many registered people are registered as patients as well, in each city. Generate a report that shows each city that has 10 or more registered people belonging to it and the number of patients from that city as well as the percentage of the patient with respect to the registered people. */
with cte as (select state, city, count(distinct personID) as registered_people, count(distinct patientid) as registered_patients
from address a left join person p using(addressid) left join treatment t on p.personid = t.patientid
group by state, city)
select *,registered_patients*100/registered_people from cte where registered_people >=10;


/* Problem Statement 5:  
It is suspected by healthcare research department that the substance “ranitidine” might be causing some side effects. Find the top 3 companies using the substance in their medicine so that they can be informed about it. */

select companyname from (select companyname, count(productName) as containing_products,
rank() over(order by count(productName) desc) rk
from medicine where substancename like '%RANITIDINA%'
group by companyname ) a where rk <=3;
-- **********************************************************