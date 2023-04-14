/* Problem Statement 1: 
Insurance companies want to know if a disease is claimed higher or lower than average.  Write a stored procedure that returns “claimed higher than average” or “claimed lower than average” when the diseaseID is passed to it. 
Hint: Find average number of insurance claims for all the diseases.  If the number of claims for the passed disease is higher than the average return “claimed higher than average” otherwise “claimed lower than average”.*/

drop procedure check_status;
delimiter //
create procedure check_status(in d_id int)
begin
declare avg_all_claims float;
declare disease_claims float;
select avg(number_of_claims) into avg_all_claims from (select diseaseID, count(claimid) as number_of_claims from disease d left join treatment using(diseaseid) group by diseaseid) a;
select count(claimid) into disease_claims from disease d left join treatment using(diseaseid) where diseaseid = d_id;
if disease_claims > avg_all_claims then select 'Claimed Higher than avg';
else select 'claimed lower than avg';
end if;
end //
delimiter ;
call check_status(19);

/* Problem Statement 2:  
Joseph from Healthcare department has requested for an application which helps him get genderwise report for any disease. 
Write a stored procedure when passed a disease_id returns 4 columns,
disease_name, number_of_male_treated, number_of_female_treated, more_treated_gender
Where, more_treated_gender is either ‘male’ or ‘female’ based on which gender underwent more often for the disease, if the number is same for both the genders, the value should be ‘same’.*/

delimiter //
create procedure get_gender_report(in d_id int)
begin
with cte as (select diseasename, gender, 
count(treatmentID) as no_treatment
from disease d left join treatment t using(diseaseid) left join person p on t.patientid = p.personid
where diseaseid = d_id
group by diseaseid,diseasename, gender),
cte2 as (
select diseasename,
sum(case when gender = 'male' then no_treatment else 0 end) as male,
sum(case when gender = 'female' then no_treatment else 0 end) as female
from cte group by diseasename)
select *, case when male > female then 'male' when female > male then 'female' else 'same' end as more_treated_gender from cte2;
end //
delimiter ;
call get_gender_report(1);
/* Problem Statement 3:  
The insurance companies want a report on the claims of different insurance plans. 
Write a query that finds the top 3 most and top 3 least claimed insurance plans.
The query is expected to return the insurance plan name, the insurance company name which has that plan, and whether the plan is the most claimed or least claimed. */
with cte as (select companyname,planname, count(claimID) as number_of_claims,
rank() over(order by count(claimid) desc) as top,
rank() over(order by count(claimid) asc) bottom
from treatment t join claim c using(claimid) right join insuranceplan ip using(uin) join insurancecompany ic using(companyid) group by companyname,planname)
select planname, companyname,  number_of_claims, 
case when top <=3 then 'most claimed' when bottom <=3 then 'least claimed' else 'same' end as status
from cte where top <=3 or bottom <=3;




/* Problem Statement 4: 
The healthcare department wants to know which category of patients is being affected the most by each disease.
Assist the department in creating a report regarding this.
Provided the healthcare department has categorized the patients into the following category.
YoungMale: Born on or after 1st Jan  2005  and gender male.
YoungFemale: Born on or after 1st Jan  2005  and gender female.
AdultMale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender male.
AdultFemale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender female.
MidAgeMale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender male.
MidAgeFemale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender female.
ElderMale: Born before 1st Jan 1970, and gender male.
ElderFemale: Born before 1st Jan 1970, and gender female.*/
with cte as (select patientID, personname, dob,gender,
case 
when dob >= '2005-01-01' and gender = 'male' then 'YoungMale'
when dob > '2005-01-01' and gender = 'female' then 'YoungFemale'
when dob < '2005-01-01' and dob >= '1985-01-01' and gender = 'male' then 'AdultMale'
when dob < '2005-01-01' and dob >= '1985-01-01' and gender = 'female' then 'AdultFeMale'
when dob < '1985-01-01' and dob >= '1970-01-01' and gender = 'male' then 'MidAgeMale'
when dob < '1985-01-01' and dob >= '1970-01-01' and  gender = 'female' then 'MidAgeFeMale'
when dob < '1970-01-01' and gender = 'male' then 'ElderMale'
when dob < '1970-01-01' and gender = 'female' then'ElderMale'
else 'none' end as age_tag
from patient p left join person pr on p.patientid = pr.personid)
select age_tag, count(diseaseID) as numbers_affected
from cte left join treatment t using(patientid) 
group by age_tag
order by numbers_affected desc limit 1;


/* Problem Statement 5:  
Anna wants a report on the pricing of the medicine. She wants a list of the most expensive and most affordable medicines only. 
Assist anna by creating a report of all the medicines which are pricey and affordable, listing the companyName, productName, description, maxPrice, and the price category of each. Sort the list in descending order of the maxPrice.
Note: A medicine is considered to be “pricey” if the max price exceeds 1000 and “affordable” if the price is under 5. Write a query to find */
select * from medicine;
select companyname, productname ,  description, maxPrice,
case when maxprice > 1000 then 'pricey' when maxprice < 5 then 'affordable' else 'none' end as price_tag
from medicine where maxprice > 1000 or maxprice <5 ;