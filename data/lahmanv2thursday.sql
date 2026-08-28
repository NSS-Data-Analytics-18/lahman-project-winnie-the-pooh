select
    min(yearid) as earliest_year,
    max(yearid) as latest_year
from teams; -- 1. 1871-2016

select
    p.namefirst,
    p.namelast,
    p.height,
    sum(a.g_all) as games_played,
    t.name as team_name
from people as p
inner join appearances as a
    on p.playerid = a.playerid
inner join teams as t
    on a.teamid = t.teamid
    and a.yearid = t.yearid
where p.height = (select min(height)from people)
group by
    p.playerid,
    p.namefirst,
    p.namelast,
    p.height,
    t.name
order by games_played desc; -- 2. Eddie Gaedel, 1 game played, St. Louis Browns

select
	p.namefirst,
	p.namelast,
	sum(salaries.salary) as total_salary
from people as p
inner join (select distinct college.playerid
    from collegeplaying as college
    inner join schools 
        on college.schoolid = schools.schoolid
    where schools.schoolname = 'Vanderbilt University'
) as vandy
    on p.playerid = vandy.playerid
inner join salaries
	 on p.playerid = salaries.playerid
group by p.playerid,
		 p.namefirst,
		 p.namelast
order by total_salary desc; -- 3.


select
    case
        when pos = 'OF' then 'Outfield'
        when pos in ('SS', '1B', '2B', '3B') then 'Infield'
        when pos in ('P', 'C') then 'Battery'
    end as position_group,
	sum(po) as total_putouts
from fielding
where yearid = 2016
group by
	case
        when pos = 'OF' then 'Outfield'
        when pos in ('SS', '1B', '2B', '3B') then 'Infield'
        when pos in ('P', 'C') then 'Battery'
end; -- 4. ["Battery" - 41424], ["Infield" - 58934], ["Outfield" - 29560]

select
	 max(w) as most_wins_not_WS
from teams
where yearid between 1970 and 2016
	and wswin = 'N'; -- a

select 
	 min(w) as least_wins_WS
from teams
where yearid between 1970 and 2016
	and wswin = 'Y'; -- b

select
    yearid,
    name,
    w,
    wswin
from teams
where yearid between 1970 and 2016
    and wswin = 'Y'
order by w; -- c. 1981 had players on strike so teams played less games than a normal season

select
	min(w) as least_wins_ws
from teams
where yearid between 1970 and 2016
	and yearid <> 1981
	and wswin = 'Y'; -- d. 83 wins
	
select
	count(*) as times_most_wins_won_ws,
	round(count(*) * 100 / 46, 1) as percent
from (
select *
from (
select
	yearid,
	name,
	w,
	wswin,
	max(w) over(partition by yearid) as most_wins_that_year
from teams
where yearid between 1970 and 2016
	and yearid <> 1981) as team_wins
where w = most_wins_that_year)
as top_teams
where wswin = 'Y'; -- 7. 12 times, 26% of the time

select
	p.namefirst,
	p.namelast,
	b.yearly_hr as hr_2016
from (
	select
		playerid,
		yearid,
		yearly_hr,
		max(yearly_hr) over(partition by playerid) as career_high_hrs,
		count(*) over(partition by playerid) as years_played
	from (
		select
		playerid,
		yearid,
		sum(hr) as yearly_hr -- hr = homerun
		from batting
		group by playerid, yearid
 	) as yearly_batting
) as b
inner join people as p
	on b.playerid = p.playerid
where b.yearid = 2016
	and b.yearly_hr = b.career_high_hrs
	and b.years_played >= 10
	and b.yearly_hr > 0
order by b.yearly_hr desc; -- 10.

	