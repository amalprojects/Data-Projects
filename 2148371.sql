create database rentalmatcher;




-- student table
use rentalmatcher;
create table student(student_id INT primary key, 
    student_name varchar(255) NOT NULL,
    student_surname varchar(255) NOT NULL,
    phone_number BIGINT NOT NULL,
    max_rent INT  NOT NULL, 
    required_parking boolean NOT NULL,
    required_accessibility boolean NOT NULL,
    move_Date DATE NOT NULL,
    actively_seeking boolean not null,
    join_date DATE not null);

use rentalmatcher;
select*from student;

use rentalmatcher;
insert into student values 
(1,"Amal","Antony",4545698987,400,true,true,'2022-07-05', True,'2022-04-01'),
(2,"Ben","Stokes",7676987876,500,true,false,'2022-07-10', False,'2022-03-10'),
(3,"Maria","Tom",5454323231,500,true,false,'2022-07-15', True,'2022-03-10'),
(4,"Annie","Marie",7676546461,400,true,true,'2022-08-10', True,'2022-04-15'),
(5,"Richard","Kovacs",5858765651,400,false,false,'2022-08-05', True,'2022-03-12'),
(6,"Laura","Dunscombe",898907075,500,true,false,'2022-08-01',False,'2022-03-09'),
(7,"Elon","Gates",8787654543,400,false,false,'2022-07-20',True,'2022-03-17'),
(8,"bruno","salvo",878789897,400,true,true,'2022-07-01',true,' 2022-04-15'),
(9,"monte","carlo",9090989896,400,true,false,'2022-07-15',true,'2022-04-15');

-- house table for total number of houses
use rentalmatcher;
create table house(house_id int primary key,house_address varchar(255) not null, owner_name varchar(255) not null, owner_surname varchar(255) not null,
rent int not null, parking boolean not null,accessibility boolean not null , house_availability boolean not null, viewing_time TIMESTAMP,available_date DATE );

insert into house values(1,'1 vincent street','owen','davies',400,true,true,true,'2022-05-20','2022-09-02'),(2,'2 vincent street','jane','doe',500,true,false,true,'2022-05-10','2022-09-05'),
(3,'3 vincent street','john','doe',400,true,true,true,'2022-05-05','2022-09-04'),(4,'4 vincent street','david','werner',400,false,false,true,'2022-06-10','2022-09-01'),
(5,'5 vincent street','ben','shapiro',400,false,false,true,'2022-06-20','2022-09-06'),(6,'6 vincent street','elaine','davies',400,true,true,true,'2022-05-25','2022-09-02'),
(7,'7 vincent street','amal','antony',500,true,false,true,'2022-06-15','2022-08-20'),(8,'8 vincent street','riz','nawaz',500,false,true,false,'2022-05-12','2022-08-10');







--rental appointment table
use rentalmatcher;
create table rental_appointment(match_id int ,student_id int, student_name varchar(255),student_surname varchar(255),
house_address varchar(255), accepted_rental_offer boolean, notice_date DATE);

use rentalmatcher;
insert into rental_appointment values (1,3,'Maria','Tom','2 vincent street', true , '2022-06-10'),
(2,3,'Maria','Tom','7 vincent street', false, '2022-06-11'),(3,5,'Richard','Kovacs','4 vincent street',true,'2022-06-12'),
(4,5,'Richard','Kovacs','5 vincent street', false , '2022-06-10'),(5,7,'Elon','Gates','4 vincent street',true,'2022-06-12'),
(6,7,'Elon','Gates','5 vincent street', true ,'2022-06-12'),(7,1,'Amal','Antony','1 vincent street', false , '2022-06-10'),
(8,1,'Amal','Antony','3 vincent street',true,'2022-06-08'),(9,1,'Amal','Antony','6 vincent street',false,'2022-06-15'),
(10,4,'Annie','Marie','1 vincent street',false,'2022-06-10'),(11,4,'Annie','Marie','3 vincent street',true,'2022-06-10'),
(12,4,'Annie','Marie','6 vincent street',false,'2022-06-11'),(13,8,'bruno','salvo','6 vincent street',true,'2022-06-10'),
(14,8,'bruno','salvo','1 vincent street',true,'2022-06-11'),(15,8,'bruno','salvo','3 vincent street',true,'2022-06-10');


-- accepted and rejected rentals table
use rentalmatcher;
create table accepted_appointment(id int,student_id int, student_name varchar(255), student_surname varchar(255),house_address varchar(255),);


use rentalmatcher;
insert into accepted_appointment values(1,3,'Maria','Tom','2 vincent street'),(2,5,'Richard','Kovacs','4 vincent street'),
(3,7,'Elon','Gates','5 vincent street'),(4,1,'Amal','Antony','3 vincent street'),(4,8,'bruno','salvo','6 vincent street'),
(5,8,'bruno','salvo','1 vincent street'),(6,8,'bruno','salvo','3 vincent street');

--views



------------------------------------------------------------------------1st task - Rental Demand System
use rentalmatcher;
create view rental_demand_view as  select student_name,student_surname,join_date from student where actively_seeking = 1 order by join_date;

use rentalmatcher;
select*from rental_demand_view;

------------------------------------------------------------------------2nd task - Match and Rent

use rentalmatcher;
create view initial_match as select*from student join house;

use rentalmatcher;
select*from initial_match;

use rentalmatcher;
 create view filtered_match as select student_id,house_address,viewing_time,join_date from initial_match 
where max_rent = rent and required_parking = parking and required_accessibility=accessibility 
and available_date > move_Date and actively_seeking = 1 order by join_date;

use rentalmatcher;
create view match_and_rent as select*from filtered_match limit 5;

use rentalmatcher;
select*from match_and_rent;

-------------------------------------------------------------------------3rd task - rental tracker

use rentalmatcher;
create view accepted as select * from rental_appointment where accepted_rental_offer = 1;

use rentalmatcher;
create view accepted_rental as select * from accepted group by house_address;

--rentaltracker view
use rentalmatcher;
create view students_to_be_contacted as select * from accepted where match_id not in (select match_id from  accepted_rental);

use rentalmatcher;
select*from students_to_be_contacted;

-------------------------------------------------------------------------4th task - system efficacy

use rentalmatcher;
select * from rental_appointment;

use rentalmatcher;
create view rejected_rentals as select * from rental_appointment where accepted_rental_offer = 0;

use rentalmatcher;
select student_name,student_surname, count(student_name) as rejected_houses from rejected_rentals group by student_name;

use rentalmatcher;
create view system_efficacy as select student_name,student_surname, count(student_name) as rejected_houses from rejected_rentals group by student_name;

use rentalmatcher;
select*from system_efficacy 
-------------------------------------------------------------------------5th task - Renter report
use rentalmatcher;
create view renter_report as select house_address, count(house_address) as no_of_rejections from rejected_rentals group by house_address;

use rentalmatcher;
select*from renter_report;









