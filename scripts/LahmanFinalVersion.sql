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
end; -- 4. (Noah) ["Battery" - 41424], ["Infield" - 58934], ["Outfield" - 29560]

SELECT *
FROM teams;

SELECT (yearid/ 10) *10 AS decade,
	ROUND(AVG(so::numeric/g), 2) AS avg_SO_pergame,
	ROUND(AVG(hr::numeric/g), 2) AS avg_HR_pergame
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade; -- 5. (Jewel)

select
	floor(yearid / 10) * 10 as decade,
	round(sum(so)::numeric / sum(g), 2) as so_per_game,
	round(sum(hr)::numeric / sum(g), 2) as hr_per_game
from teams
where yearid >= 1920
group by floor(yearid / 10) * 10
order by decade; -- 5.

SELECT *
	FROM (SELECT namefirst, namelast, sb, (sb+cs) AS attempts, CONCAT(ROUND((sb * 100.0) / NULLIF(sb + cs, 0), 2), '%') AS sb_percentage, yearid
	FROM batting 
	INNER JOIN people ON batting.playerid = people.playerid
	WHERE yearid = 2016) AS sb_2016
WHERE attempts > 20
ORDER BY sb_percentage DESC
LIMIT 1; -- 6. (Nas) Chris Owings had the most success 91.30% and 21 stolen bases 

select
	people.namefirst,
	people.namelast,
	sum(batting.sb) as stolen_bases,
	sum(batting.cs) as caught_stealing,
	round(
		sum(batting.sb)::numeric /
		(sum(batting.sb) + sum(batting.cs)) * 100,
		2
	) as success_pct
from batting
inner join people
	on batting.playerid = people.playerid
where batting.yearid = 2016
group by
	people.playerid,
	people.namefirst,
	people.namelast
having sum(batting.sb) + sum(batting.cs) >= 20
order by success_pct desc; -- 6. chris owings 21 bases, 91.30%

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
where wswin = 'Y'; -- 7. (Noah) 12 times, 26% of the time

SELECT t.name AS team, p.park_name, SUM(h.attendance)/SUM(h.games) AS avg_attendance
FROM homegames AS h
	JOIN parks as p
		ON h.park = p.park
	JOIN teams AS t
		ON h.team = t.teamid
	WHERE games >= 10
	AND h.year = 2016
GROUP BY t.name, p.park_name
ORDER BY avg_attendance DESC
LIMIT 10;-- 8. (Jewel) Dodgers, Cardinals,Browns, Perfectos, Blue Jays 
		            -- Giants, Colts, Cubs, Orphans, White Stockings
		            -- Team/park with highest AVG attendance per game 
		            -- in 2016 where at least 10 g played. Highest 5

select
    h.team,
    p.park_name,
    round(h.attendance::numeric / h.games, 1) as avg_attendance
from homegames as h
inner join parks as p
    on h.park = p.park
where h.year = 2016
    and h.games >= 10
order by avg_attendance asc
limit 5; -- 8.


SELECT people.namefirst, people.namelast, awardsmanagers.yearid, awardsmanagers.lgid, teams.name AS team_name
FROM awardsmanagers 
	INNER JOIN people ON awardsmanagers.playerid = people.playerid
	INNER JOIN teams  ON awardsmanagers.yearid = teams.yearid AND awardsmanagers.yearid = teams.yearid AND awardsmanagers.lgid = teams.lgid
WHERE awardsmanagers.awardid = 'TSN Manager of the Year' AND awardsmanagers.playerid IN (SELECT playerid
	FROM awardsmanagers
	WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('NL', 'AL')
	GROUP BY playerid
	HAVING COUNT(DISTINCT lgid) = 2)
ORDER BY namefirst DESC; -- 9. (Nas) Jim Leyland and Dav coaches who had both awards for AL and NL 

select distinct
    p.namefirst,
    p.namelast,
    am.yearid,
    am.lgid,
    t.name as team_name
from awardsmanagers am
join people p on am.playerid = p.playerid
join managers m on am.playerid = m.playerid and am.yearid = m.yearid
join teams t on m.teamid = t.teamid and m.yearid = t.yearid
where am.awardid = 'TSN Manager of the Year'
and am.playerid in (
    select playerid
    from awardsmanagers
    where awardid = 'TSN Manager of the Year'
    group by playerid
    having count(distinct lgid) = 2)
order by p.namelast, am.yearid; -- 9. Jim & Davey

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

select
    yearid,
    round(corr(w, team_salary)::numeric, 3) as salary_wins_correlation
from (
    select
        t.yearid,
        t.teamid,
        t.w,
        s.team_salary
    from teams as t
    inner join (
        select
            yearid,
            teamid,
            sum(salary) as team_salary
        from salaries
        where yearid >= 2000
        group by yearid, teamid
    ) as s
        on t.yearid = s.yearid
        and t.teamid = s.teamid
    where t.yearid >= 2000
) as team_data
group by yearid
order by yearid; -- 11.
				 -- For the most part, there is a weak to moderate positive correlation between team salary and number of wins. 
				 -- The correlation was stronger in 2004, 2006, and especially 2016.
				 -- Suggesting that higher-paid teams tended to win more games in those years. 
				 -- Overall, however, team salary does not strongly predict the number of wins.

select
    yearid,
    round(corr(w, attendance)::numeric, 3) as wins_attendance_correlation
from teams
where yearid >= 2000
    and attendance is not null
group by yearid
order by yearid; -- 12A. There is a moderate positive correlation between wins and attendance at home games
				 -- From 2000–2016 most yearly correlations are around 0.4–0.6
				 -- suggesting that teams with more wins generally tend to have higher attendance.
				 -- with 2009 showing a strong correlation of 0.679, while 2012 was much weaker at 0.274.

select
    yearid,
    name,
    wswin,
    divwin,
    wcwin,
    attendance,
    lead(attendance) over(
        partition by teamid
        order by yearid) as next_year_attendance, 
    lead(attendance) over(
        partition by teamid
        order by yearid) - attendance as attendance_diff
from teams
where attendance is not null
order by teamid, yearid ; -- list all differences year to next year

select
    round(avg(attendance_change)) as avg_attendance_change
from (
    select
        yearid,
        name,
        wswin,
        lead(attendance) over(
            partition by teamid
            order by yearid
        ) - attendance as attendance_change
    from teams
    where attendance is not null
) as attendance_data
where wswin = 'Y'; --  finding average change from previous year to next

select
    round(avg(attendance_change)) as avg_playoff_attendance_change
from (
    select
        yearid,
        name,
        divwin,
        wcwin,
        attendance,
        lead(attendance) over(
            partition by teamid
            order by yearid
        ) - attendance as attendance_change
    from teams
    where attendance is not null
) as attendance_data
where divwin = 'Y'
    or wcwin = 'Y'; -- avg change in attendance after the team won the pre

select *
from (
	select distinct lgid
	from teams
	where yearid = 2016
	) as leagues,
	lateral (
		select teamid, w as wins
		from teams
		where yearid = 2016
			and lgid = leagues.lgid
		order by w desc
		limit 3
) as top_teams; -- 1

SELECT
    playerid,
    namefirst,
    namelast,
    (birthyear || '-' || birthmonth || '-' || birthday)::date AS birthdate
FROM people; -- 2a.

select
	p.playerid,
	p.namefirst,
	p.namelast,
	p.debut,
	p.finalgame,
	extract(year from age(p.debut::date, p.birthdate)) as age_debut,
	extract(year from age(p.finalgame::date, p.birthdate)) as age_retired
from (
	select
		playerid,
		namefirst,
		namelast,
		(birthyear || '-' || birthmonth || '-' || birthday)::date AS birthdate,
		debut,
		finalgame
	from people
) as p,
lateral (
	select
		extract(year from age(p.debut::date, p.birthdate)) as age_debut,
		extract(year from age(p.finalgame::date, p.birthdate)) as age_retired
) as ages; -- 2b.

select
	p.playerid,
	p.namefirst,
	p.namelast,
	p.debut,
	p.finalgame,
	extract(year from age(p.debut::date, p.birthdate)) as age_debut,
	extract(year from age(p.finalgame::date, p.birthdate)) as age_retired
from (
	select
		playerid,
		namefirst,
		namelast,
		(birthyear || '-' || birthmonth || '-' || birthday)::date AS birthdate,
		debut,
		finalgame
	from people
) as p,
lateral (
	select
		extract(year from age(p.debut::date, p.birthdate)) as age_debut,
		extract(year from age(p.finalgame::date, p.birthdate)) as age_retired
) as ages
order by age_debut
limit 1; -- 2c. age 15, Joe Nuxhall

select
	p.playerid,
	p.namefirst,
	p.namelast,
	p.debut,
	p.finalgame,
	extract(year from age(p.debut::date, p.birthdate)) as age_debut,
	extract(year from age(p.finalgame::date, p.birthdate)) as age_retired
from (
	select
		playerid,
		namefirst,
		namelast,
		(birthyear || '-' || birthmonth || '-' || birthday)::date AS birthdate,
		debut,
		finalgame
	from people
) as p,
lateral (
	select
		extract(year from age(p.debut::date, p.birthdate)) as age_debut,
		extract(year from age(p.finalgame::date, p.birthdate)) as age_retired
) as ages
order by age_retired desc nulls last
limit 1; -- 2d.  Satchel Paige, age 59

select count(distinct a2.playerid) as players_with_mays
from allstarfull as a1
join allstarfull as a2
    on a1.yearid = a2.yearid
    and a1.gamenum = a2.gamenum
where a1.playerid = 'mayswi01'
    and a1.startingpos is not null
    and a2.startingpos is not null
    and a2.playerid <> 'mayswi01'; -- 3a. 125 players started with him

with recursive player_connection as (
    select
        a1.playerid as player1,
        a2.playerid as player2
    from allstarfull a1
    join allstarfull a2
        on a1.yearid = a2.yearid
        and a1.gamenum = a2.gamenum
    where a1.startingpos is not null
        and a2.startingpos is not null
        and a1.playerid <> a2.playerid),
mays_connection as (
    select player2
    from player_connection
    where player1 = 'mayswi01')
select count(distinct pc.player2) as players
from player_connection as pc
join mays_connection as mc
    on pc.player1 = mc.player2
where pc.player2 <> 'mayswi01'
    and pc.player2 not in (
        select player2
        from mays_connection); -- 3b. 217

with recursive connections as (
    select distinct
        a1.playerid as player1,
        a2.playerid as player2
    from allstarfull a1
    join allstarfull a2
        on a1.yearid = a2.yearid
        and a1.gamenum = a2.gamenum
    where a1.startingpos is not null
        and a2.startingpos is not null
        and a1.playerid <> a2.playerid
),
paths as (
    select
        c.player1,
        c.player2,
        p1.namefirst || ' ' || p1.namelast
            || ' -> ' ||
        p2.namefirst || ' ' || p2.namelast as player_chain,
        ',' || c.player1 || ',' || c.player2 || ',' as visited,
        1 as chain_length
    from connections c
    join people p1
        on c.player1 = p1.playerid
    join people p2
        on c.player2 = p2.playerid
    where c.player1 = 'ruthba01'

    union all

    select
        p.player1,
        c.player2,
        p.player_chain
            || ' -> ' ||
        p2.namefirst || ' ' || p2.namelast,
        p.visited || c.player2 || ',',
        p.chain_length + 1
    from paths p
    join connections c
        on p.player2 = c.player1
    join people p2
        on c.player2 = p2.playerid
    where p.chain_length < 4
        and position(',' || c.player2 || ',' in p.visited) = 0
        and p.player2 <> 'mayswi01'
)
select
    player_chain,
    chain_length
from paths
where player2 = 'mayswi01'
order by chain_length
limit 1; -- 3c. Babe Ruth - Bill Dickey - Ted Williams - Willie Mays, chain length of 3

with recursive connections as (
    select distinct
        a1.playerid as player1,
        a2.playerid as player2
    from allstarfull a1
    join allstarfull a2
        on a1.yearid = a2.yearid
        and a1.gamenum = a2.gamenum
    where a1.startingpos is not null
        and a2.startingpos is not null
        and a1.playerid <> a2.playerid
),
paths as (
    select
        c.player1,
        c.player2,
        p1.namefirst || ' ' || p1.namelast
            || ' -> ' ||
        p2.namefirst || ' ' || p2.namelast as player_chain,
        ',' || c.player1 || ',' || c.player2 || ',' as visited,
        1 as chain_length
    from connections c
    join people p1
        on c.player1 = p1.playerid
    join people p2
        on c.player2 = p2.playerid
    where c.player1 = 'jeterde01'

    union all

    select
        p.player1,
        c.player2,
        p.player_chain
            || ' -> ' ||
        p2.namefirst || ' ' || p2.namelast,
        p.visited || c.player2 || ',',
        p.chain_length + 1
    from paths p
    join connections c
        on p.player2 = c.player1
    join people p2
        on c.player2 = p2.playerid
    where p.chain_length < 4
        and position(',' || c.player2 || ',' in p.visited) = 0
        and p.player2 <> 'mayswi01'
)
select
    player_chain,
    chain_length
from paths
where player2 = 'mayswi01'
order by chain_length
limit 1; -- 3d. Derek Jeter - Roberto Alomar - Jack Morris - Rod Carew - Willie Mays, chain length of 4

select
    p.throws,
    count(distinct p.playerid) as number_of_pitchers,
	round(
		count(distinct p.playerid) * 100 /
		sum(count(distinct p.playerid)) over(), 
		1
	) as percentage
from people as p
inner join pitching as pit
    on p.playerid = pit.playerid
where p.throws in ('L', 'R')
group by p.throws; --  shows # of pitchers R/L and percentage

select
    p.throws,
    count(distinct ap.playerid) as cy_young_winners
from awardsplayers as ap
inner join people as p
    on ap.playerid = p.playerid
where ap.awardid = 'Cy Young Award'
    and p.throws in ('L', 'R')
group by p.throws; -- shows winners of the award by left/right handedness

select
	round(24.0 / 2477 * 100, 2) as left_cy_young_percentage,
	round(53.0 / 6605 * 100, 2) as right_cy_young_percentage; -- winners percentage

select
    p.throws,
    count(distinct h.playerid) as hall_of_fame_pitchers
from halloffame as h
inner join people as p
    on h.playerid = p.playerid
inner join pitching as pit
    on p.playerid = pit.playerid
where h.inducted = 'Y'
    and p.throws in ('L', 'R')
group by p.throws; -- hall of fame

select
    round(23.0 / 2477 * 100, 2) as left_hof_percentage,
    round(78.0 / 6605 * 100, 2) as right_hof_percentage;
-- Left-handed pitchers are not more likely to make it. Right-handed pitchers have a slightly higher induction rate

-- 13. 
-- Left-handed pitchers are rarer than right-handed pitchers. 
-- There were 2,477 left-handed pitchers, making up 27.3% of pitchers, compared with 6,605 right-handed pitchers, or 72.7%.
-- Left-handed pitchers were slightly more likely to win the Cy Young Award. 
-- There were 24 unique left-handed winners and 53 unique right-handed winners. 
-- This represents about 0.97% of left-handed pitchers compared with 0.80% of right-handed pitchers.
-- Left-handed pitchers were not more likely to make the Hall of Fame. 
-- About 0.93% of left-handed pitchers were inducted compared with 1.18% of right-handed pitchers.
-- Overall, the evidence is mixed. 
-- Left-handed pitchers are much rarer and had a slightly higher rate of winning the Cy Young Award. 
-- Right-handed pitchers had a higher Hall of Fame induction rate. 
-- Therefore, these results don't provide strong evidence that left-handed pitchers are more effective.












