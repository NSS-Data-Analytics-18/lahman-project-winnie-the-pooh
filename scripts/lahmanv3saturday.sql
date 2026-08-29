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
where wswin = 'Y'; --  finding average change from previous year to next after winning the world series

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
    or wcwin = 'Y'; -- avg change in attendance after the team got into the playoffs the previous year

-- 12B. Yes teams that won the World Series saw an average attendance increase of 16,482.
-- Teams that made the playoffs the previous season saw an average increase of 50,290.
-- This shows that MLB postseason success is associated with increased attendance next season.
-- It is interesting that the World Series winner on average has a lower increase in attendance than a team that made the playoffs.

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




				 