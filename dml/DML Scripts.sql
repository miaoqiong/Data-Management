# i. Given a year(let's say 2013), list all the IS480 projects that were chosen by students in a term of that year.
select t.term as Team, t.title as Title, r.team_name as Team_Name, s.name as Name, r.role as Role
from team t, student s, register r
where t.term like '2013%' and s.email = r.email and t.name = r.team_name and t.term = r.term
order by t.term, t.title;


# ii. List all IS480 projects that have relevant projects.
select p1.title as Title, p1.project_brief as 'Project Brief', p1.term as Term,
p2.title as Title, p2.project_brief as 'Project Brief', p2.term as Term
from project p1, project p2, projects_relevance pr
where p1.title=pr.title
and pr.relevant_title=p2.title;

# iii. Given a term(let's say 2013_1), list details of the project available in that term.
select p.title as Title, project_brief as 'Project brief', Sponsor_company as Sponsor,
if(withdraw_date is null,'','yes') as 'Withdrawn?', 
if(t.name is null,'',t.name) as Team,
if(f.name is null,'',f.name) as Supervisor
from ((select * from project where term='2013_1') as p left outer join team t on p.title=t.title)
left outer join(assignment a inner join faculty f on a.email=f.email)
on a.team=t.name and a.role='Supervisor' and f.email = a.email
order by p.title;


# iv. For a set of given terms (say 2013_1 and 2015_1), list for each of them the approximated number of teams,
# the number of project teams registered, total number of teams with supervisors's assigned, total number of teams
# with primary reviewers' assigned, and total number of teams with secondary reviewers' assigned.
select t.ayterm as 'Term', t.approx_number_teams as 'Approx Num Teams',
count(distinct r.team_name) as 'Total Teams Registered',
if(sup is null,'0',sup) as 'Total Teams with Supervisors Assigned',
if(pri is null,'0',pri) as 'Total Teams with PriReviewers Assigned',
if(sec is null,'0',sec) as 'Total Teams with SecReviewers Assigned' from
((select term, count(team) as sup from assignment where role='Supervisor' group by term) as t1 left outer join 
 (select term, count(team) as pri from assignment where role='Primary Reviewer' group by term) as t2 on t1.term = t2.term)
left outer join(select term, count(team) as sec from assignment where role='Secondary Reviewer' group by term) 
as t3 on t2.term=t3.term, (select * from term where ayterm in ('2013_1','2015_1')) as t, register r
where t.ayterm=t1.term and t.ayterm=r.term
group by t.ayterm;

# v. For every term, retrieve the teams that registered for IS480 within that term. For each of the teams, list term, 
# acceptance score, its assessment percentage, midterm score, its assessment percentage, final score, its assessment 
# percentage and the overall overall score (derived based on all assessment components) 
# *Note: there are other assessment components that form part of the 100% overall score.

select  queryoverall.term as 'Term', queryoverall.team as 'Team', 
		query1.check_point_grade as 'Acceptance Score', query1.percentage as 'Acceptance %', 
		query2.check_point_grade as 'Midterm Score', query2.percentage as 'Midterm %', 
		query3.check_point_grade as 'Finals Score' ,query3.percentage as 'Finals %' , 
		queryoverall.overall_score as 'Overall Score 100%' from
(
	(
		(select term, team, round(sum(score /100 * percentage),2) as overall_score from
			(select q1.term, q1.team, q1.score, a.percentage, q1.assessed_stage
			from assessment a,
				(select os.term, os.team, os.assessed_stage, sum(role_score) as score from
					(select a.term, a.email, team, a.role, assessed_stage,
					g.score, r.weightage, round((g.score/100*r.weightage),2) as role_score 
					from assignment a, grade g, role r 
					where g.faculty = a.email 
					and g.term = a.term 
					and g.team_name = a.team 
					and r.name = a.role
					) 
				as os group by os.term, os.team, os.assessed_stage
				) 
			as q1 where a.check_point = q1.assessed_stage
			) 
		as w1 group by term, team
		) 
	as queryoverall left outer join
		(select term, team, check_point_grade, percentage from
			(select term, team, sum(new_score) as check_point_grade, assessed_stage, percentage from
				(select a.term, a.email, team, a.role, assigned_date, assessed_stage, 
				g.score, r.weightage, round((g.score/100*r.weightage),2) as new_score, 
				ass.percentage from assignment a, grade g, role r, assessment ass 
				where g.faculty = a.email 
				and g.term = a.term 
				and g.team_name = a.team 
				and r.name = a.role 
				and ass.check_point = g.assessed_stage
				) 
			as wtg group by term, team, assessed_stage
			) 
		as acs where acs.assessed_stage = 'Acceptance'
		)
	as query1 on queryoverall.term = query1.term and queryoverall.team = query1.team 
	)left join 
		(select term, team, check_point_grade, percentage from
			(select term, team, sum(new_score) as check_point_grade, assessed_stage, percentage from
				(select a.term, a.email, team, a.role, assigned_date, 
				assessed_stage, g.score, r.weightage, 
				round((g.score/100*r.weightage),2) as new_score, 
				percentage from assignment a, grade g, role r, assessment ass
				where g.faculty = a.email 
				and g.term = a.term 
				and g.team_name = a.team 
				and r.name = a.role 
				and ass.check_point = g.assessed_stage
				) 
			as wtg group by term, team, assessed_stage
			) 
		as ms where ms.assessed_stage = 'Midterm'
		) 
	as query2 
	on query1.term = query2.term 
	and query1.team = query2.team 
) 
left outer join
	(select term, team, check_point_grade, percentage from
		(select term, team, sum(new_score) as check_point_grade, assessed_stage, percentage from
			(select a.term, a.email, team, a.role, assigned_date, 
			assessed_stage, g.score, r.weightage, 
			round((g.score/100*r.weightage),2) as new_score, percentage
			from assignment a, grade g, role r, assessment ass
			where g.faculty = a.email 
			and g.term = a.term 
			and g.team_name = a.team 
			and r.name = a.role 
			and ass.check_point = g.assessed_stage
			) 
		as wtg group by term, team, assessed_stage
		) 
	as fs where fs.assessed_stage = 'Final'
	) 
as query3 
on query2.term = query3.term 
and query2.team = query3.team
order by term, team;

# vi. For a given term, retrieve all the teams that have won any award. You have to list the teams in ascending order of the 
# award name.

select  temp.name as 'Award Name', temp.team as 'Team_name', s.name as 'Student Name',temp.type as 'Type of Award', st.overall_score as 'Team Score', temp.prize as Prize
from student s,register r, team t,
   (select a.name, n.team, type, prize 
   from nomination n, award a, team t where n.team = t.name and a.name = n.award and winner = 1) 
   as temp, 
   ( select term, team, round(sum(score /100 * percentage),2) as overall_score from
			(select q1.term, q1.team, q1.score, a.percentage, q1.assessed_stage
			from assessment a,
				(select os.term, os.team, os.assessed_stage, sum(role_score) as score from
					(select a.term, a.email, team, a.role, assessed_stage,
					g.score, r.weightage, round((g.score/100*r.weightage),2) as role_score 
					from assignment a, grade g, role r 
					where g.faculty = a.email 
					and g.term = a.term 
					and g.team_name = a.team 
					and r.name = a.role
                    and a.term = '2013_1'
					) 
				as os group by os.term, os.team, os.assessed_stage
				) 
			as q1 where a.check_point = q1.assessed_stage
			) 
		as w1 group by term, team) as st
where r.team_name = t.name and s.email = r.email and temp.team = t.name and st.team = temp.team;

#vii. Retrieve all available awards for a given term. Display the Name of Award, Description and Sponsor Type as (SIS or Donor)
select a.name as 'Award Name', award_Desc as 'Description', type as 'Type', 
IF(type='donor', donor_name, 'null') as 'Donor',
IF(type='donor', criterion, 'Null') as Criterion, IF(type='sis', source_fun,'Null') as 'Source Fund'
from award a left outer join (select award_name, source_fun from sis_award) as sa on a.name = sa.award_name
left outer join (select award_name, criterion, donor_name from donor_award) as da
on a.name = da.award_name