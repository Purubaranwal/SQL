/*Problem Statement 1:
Patients are complaining that it is often difficult to find some medicines. They move from pharmacy to pharmacy to get the required medicine. A system is required that finds the pharmacies and their contact number that have the required medicine in their inventory. So that the patients can contact the pharmacy and order the required medicine.
Create a stored procedure that can fix the issue.*/
delimiter //
create procedure pharmacy_details_c(in med_name varchar(123))
begin
select productname as medicinename, pharmacyName, phone
from pharmacy join keep using (pharmacyid) join medicine using(medicineid) where productName = med_name;
end //
delimiter ;
call pharmacy_details_c('neosac');
/*Problem Statement 2:
The pharmacies are trying to estimate the average cost of all the prescribed medicines per prescription, for all the prescriptions they have prescribed in a particular year. Create a stored function that will return the required value when the pharmacyID and year are passed to it. Test the function with multiple values.*/
delimiter //
create function avg_bill(yr int)
returns int DETERMINISTIC
begin 
declare x int;
select avg(average_price) into x from (select sum(quantity*maxPrice) as average_price
from treatment join prescription using(treatmentid) join contain using(prescriptionid) join medicine using(medicineid) 
where year(date) = yr
group by prescriptionid) a ;
return(x);
end //
delimiter ;

select avg_bill(2020);
select avg_bill(2021);
select avg_bill(2022);


-- ------------------------------------------------------------------------------------------------------------------------------------------
/*Problem Statement 3:
The healthcare department has requested an application that finds out the disease that was spread the most in a state for a given year. So that they can use the information to compare the historical data and gain some insight.
Create a stored function that returns the name of the disease for which the patients from a particular state had the most number of treatments for a particular year. Provided the name of the state and year is passed to the stored function.*/
delimiter //
create function most_spread(st varchar(123), yr int)
returns varchar(123) deterministic
begin 
declare x varchar(123);
select group_concat(' ',diseasename) into x
from (select state, diseasename, count(treatmentid),
rank() over(partition by state order by count(treatmentid) desc) rk
from address join person using(addressid) join treatment on treatment.patientid = person.personid join disease using(diseaseid)
where state = st and year(date) = yr
group by state, diseasename) a where rk =1;
return(x) ;
end //
delimiter ;
select most_spread('al',2022);

-- --------------------------------------------------------------------------------------------------------------------------------------
/*Problem Statement 4:
The representative of the pharma union, Aubrey, has requested a system that she can use to find how many people in a specific city have been treated for a specific disease in a specific year.
Create a stored function for this purpose.*/
drop function patient_number_city_disease_year;
delimiter //
create function patient_number_city_disease_year(ct varchar(123), d_name varchar(123), yr int)	
returns int deterministic
begin
declare x int;
select count(distinct patientid)  into x
from address left join person using(addressid) left join treatment t on t.patientid = person.personid left join disease using(diseaseid)
where city = ct and diseasename = d_name and year(date) = yr
group by city, diseasename;
return(x);
end //
delimiter ;
select coalesce(patient_number_city_disease_year('Anchorage','Anxiety disorder',2022),0) as number_of_patients;
select coalesce(patient_number_city_disease_year('arvada','cancer',2021),0) as number_of_patients;
/*Problem Statement 5:
The representative of the pharma union, Aubrey, is trying to audit different aspects of the pharmacies. 
She has requested a system that can be used to find the average balance for claims submitted by a specific insurance company in the year 2022. 
Create a stored function that can be used in the requested application. */
delimiter //
create function avg_balance( c_id int)
returns int deterministic
begin
declare x int;
select sum(balance)/count(distinct planname)  into x
from insurancecompany left join insuranceplan using(companyid) left join claim using(uin) left join treatment using(claimid) 
where companyid = c_id and year(date) = 2022;
return (x);
end //
delimiter ;
select avg_balance(1118);

