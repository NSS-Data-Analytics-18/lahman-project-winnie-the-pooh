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


