create schema G2T03;
use G2T03;

create table term
(AYterm char(6) not null,
Approx_Number_Teams int not null,
constraint term_pk primary key (AYterm)
);
create table project
(title varchar(90) not null,
Sponsor_company varchar(30) not null,
withdraw_date date,
term char(6),
project_brief varchar(255) not null,
constraint project_pk primary key (title),
constraint project_fk1 foreign key(term) references Term(AYterm) 
);
create table projects_relevance
(
title varchar(90) not null,
relevant_title varchar(90) not null,
constraint project_relevance_pk primary key (title,relevant_title),
constraint project_relevance_fk1 foreign key(title) references project(title),
constraint project_relevance_fk2 foreign key(title) references project(title)
);
create table person
(
email varchar(100) not null,
name varchar(50),
department varchar(30),
job_title varchar(30),
constraint person_pk primary key (email)
);
create table project_contacts
(
contact varchar(100) not null,
title varchar(90) not null,
constraint project_contacts_pk primary key(title,contact),
constraint project_contacts_fk1 foreign key(title) references project(title),
constraint project_contacts_fk2 foreign key (contact) references person(email)
);

create table student
(
email varchar(100) not null,
name varchar(50) not null,
constraint student_pk primary key (email)
);
create table faculty
(
email varchar(100) not null,
name varchar(50) not null,
office varchar(30),
constraint faculty_pk primary key(email)
);
create table team
(
name varchar(30) not null,
term varchar(6) not null,
x_factor varchar(30),
title varchar(90),
constraint team_pk  primary key(name,term),
constraint team_fk1 foreign key (term) references term(AYterm)
#constraint term_fk2 foreign key(title) references project(title)
);
create table register
(
email varchar(100) not null,
team_name  varchar(30) not null,
term char(6) not null,
role varchar(30),
constraint register primary key(email,team_name,term),
constraint register foreign key(team_name,term) references team (name,term)
);
create table role
(
name varchar(30) not null,
weightage int,
constraint role_pk primary key (name)
);
create table assignment
(
team varchar(30) not null,
term char(6) not null,
role varchar(30) not null,
email varchar(100) not null,
assigned_date date,
constraint assignment_pk primary key(team,term,role,email),
constraint assignment_fk1 foreign key(team,term) references team(name,term),
constraint assignment_fk2 foreign key (role) references role(name),
constraint assignment_fk3 foreign key (email) references faculty(email)
);
create table assessment
(
check_point varchar(30) not null,
objective varchar(100),
percentage int,
constraint assessment_pk primary key (check_point)
);
create table award
(
name varchar(50) not null,
prize int,
award_Desc varchar(255),
type varchar(10),
constraint assessment primary key (name)
);
create table donor_award
(
award_name varchar(50) not null,
donor_name varchar(50),
criterion varchar(100),
constraint donor_award_pk primary key (award_name),
constraint donor_award_fk foreign key(award_name) references award(name)
);
create table sis_award
(
award_name varchar(50) not null,
source_fun varchar(30),
taxable boolean not null,
constraint sis_award_pk primary key (award_name),
constraint sis_award_fk1 foreign key(award_name) references award(name)
);
create table grade
(
faculty varchar(100) not null,
team_name varchar(30) not null,
term varchar(6) not null,
assessed_stage varchar(30) not null,
score int,
constraint grade_pk primary key(faculty,team_name,term,assessed_stage),
constraint grade_fk1 foreign key(team_name,term) references team(name,term),
constraint grade_fk2 foreign key(faculty) references faculty(email),
constraint grade_fk3 foreign key(assessed_stage) references assessment(check_point)
);
create table eligible_teams
(
donor_award varchar(50) not null,
team varchar(30) not null,
term char(6) not null,
constraint eligible_teams_pk primary key(donor_award,term,team),
constraint eligible_teams_fk1 foreign key(donor_award) references donor_award(award_name),
constraint eligible_teams_fk2 foreign key(team,term) references team(name,term)
);
create table donor_availability
(
term char(6) not null,
donor_award varchar(50) not null,
constraint donor_availability_pk primary key(term,donor_award),
constraint donor_availability_fk1 foreign key(donor_award) references donor_award(award_name),
constraint donor_availability_fk2 foreign key(term) references term(AYterm)
);
create table nomination
(
reason varchar(50),
winner boolean,
team varchar(30) not null,
term char(6) not null,
faculty varchar(100) not null,
award varchar(50) not null,
constraint nomination_pk primary key(team,term,faculty,award),
constraint nomination_fk1 foreign key(faculty) references faculty(email),
constraint nomination_fk2 foreign key(team,term) references team(name,term),
constraint nomination_fk3 foreign key(award) references award(name)
);
create table faculty_vote
(
team varchar(30) not null,
term char(6) not null,
faculty varchar(100) not null,
award varchar(50) not null,
voting_faculty varchar(100) not null,
constraint faculty_vote_pk primary key(team,term,faculty,award,voting_faculty),
constraint faculty_vote_fk1 foreign key(team,term,faculty,award) references nomination(team,term,faculty,award),
constraint faculty_vote_fk2 foreign key(voting_faculty) references faculty(email)
);
create table faculty_expertise
(
email varchar(100) not null,
expertise varchar(30) not null,
constraint faculty_expertise_pk primary key (email,expertise),
constraint faculty_expertise_fk1 foreign key(email) references faculty(email)
);
create table assigned480
(
term char(6) not null,
email varchar(100) not null,
constraint assigned480_pk primary key(term,email),
constraint assigned480_fk1 foreign key(term) references term(AYterm),
constraint assiged480_fk2 foreign key(email) references faculty(email)
);

LOAD DATA INFILE 'D:\\G2T03\\data\\term.txt'
INTO TABLE term
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\person.txt' 
INTO TABLE person
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\student.txt' 
INTO TABLE student
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\faculty.txt' 
INTO TABLE faculty
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\assessment.txt' 
INTO TABLE assessment
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\award.txt' 
INTO TABLE award
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;


LOAD DATA INFILE 'd:\\g2t03\\data\\project.txt' 
INTO TABLE project
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(title,Sponsor_company,@withdraw_date,term,project_brief)
set withdraw_date = STR_TO_DATE(@withdraw_date, '%d/%m/%Y');

LOAD DATA INFILE 'd:\\g2t03\\data\\projects_relevance.txt' 
INTO TABLE projects_relevance
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\project_contacts.txt' 
INTO TABLE project_contacts
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\team.txt' 
INTO TABLE team
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\register.txt' 
INTO TABLE register
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\faculty_expertise.txt' 
INTO TABLE faculty_expertise
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\assigned480.txt' 
INTO TABLE assigned480
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\role.txt' 
INTO TABLE role
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\grade.txt' 
INTO TABLE grade
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\donor_award.txt' 
INTO TABLE donor_award
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\sis_award.txt' 
INTO TABLE sis_award
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\eligible_teams.txt' 
INTO TABLE eligible_teams
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\donor_availability.txt' 
INTO TABLE donor_availability
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\nomination.txt' 
INTO TABLE nomination
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\faculty_vote.txt' 
INTO TABLE faculty_vote
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'd:\\g2t03\\data\\assignment.txt' 
INTO TABLE assignment
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(team,term,role,email,@assigned_date)
set assigned_date = STR_TO_DATE(@assigned_date, '%d/%m/%Y');

