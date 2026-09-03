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
inner join (select distinct cp.playerid
    from collegeplaying as cp
    inner join schools as s
        on cp.schoolid = s.schoolid
    where s.schoolname = 'Vanderbilt University'
) as vandy
    on p.playerid = vandy.playerid)
inner join salaries
	 on p.playerod