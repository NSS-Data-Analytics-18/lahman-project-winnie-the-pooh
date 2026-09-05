-- LAHMANS BASEBALL DATABASE --
	-- Team Work Breakdown: 1,2,3 - ALL; 5,8,10 - Assigned
		-- went back through to finish the rest: 4,6,7,9
		
-- INITIAL QUESTIONS --

	-- NUMBER ONE --
	
SELECT DISTINCT(yearid)
FROM appearances
ORDER BY yearid asc;
		-- Year range of 1871 - 2016

SELECT DISTINCT(MAX(yearid)-MIN(yearid))
FROM appearances;
		-- 145 year range of data collected


	-- NUMBER TWO --
		-- Shortest player, # of game appearances, team
		
SELECT height, p.playerid, t.name, namefirst, namelast, debut, appearances.teamid, appearances.g_all
FROM people AS p
	JOIN appearances
		ON p.playerid = appearances.playerid
	JOIN teams AS t
		ON appearances.teamid = t.teamID
GROUP BY p.playerid, t.name, p.namefirst, p.namelast, p.debut, appearances.g_all, appearances.teamid
ORDER BY height asc;
		-- 43 inch Eddie Gaedel, 1 game debut 08-19-1951 on St Louis Browns


	-- NUMBER THREE --
		-- Vanderbilt U players, their major league salaries
		
SELECT DISTINCT p.namefirst, p.namelast, s.schoolname, SUM(sal.salary)::numeric::money AS total_salary
FROM people AS p
	JOIN collegeplaying AS c
		on p.playerid = c.playerid
	JOIN schools as s
		ON c.schoolid = s.schoolid
	JOIN salaries as sal
		ON p.playerid = sal.playerid
WHERE s.schoolname ILIKE '%Vanderbilt%'
GROUP BY p.namefirst, p.namelast, s.schoolname
ORDER BY total_salary DESC;
		--David Price made most in majors with $245,553,888

SELECT namefirst, namelast, p.playerid, SUM(salary)::numeric::money AS total_salary
FROM people AS p
	INNER JOIN salaries AS sal
	ON p.playerid = sal.playerid
WHERE p.playerid IN (SELECT playerid
					FROM collegeplaying INNER JOIN schools USING (schoolid)
					WHERE schoolname ILIKE '%Vanderbilt%')
GROUP BY namefirst, namelast, p.playerid
ORDER BY total_salary DESC;
		-- still david price, but salary not duplicated


-- ASSIGNED 5, 8, 10 by Team Lead --

	-- NUMBER FIVE --
		-- AVG number of SO, HR per game since 1920, round 2

SELECT *
FROM teams;

SELECT (yearid/ 10) *10 AS decade,
	ROUND(AVG(so::numeric/(g/2)), 2) AS avg_SO_pergame,
	ROUND(AVG(hr::numeric/(g/2)), 2) AS avg_HR_pergame
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;
		-- general upward trend, as strikeouts increase, homerun avg does too
			-- correction: have to divide games by 2, since 2 teams play 1 game


	-- NUMBER EIGHT --
		-- Team/park with highest AVG attendance per game 
		-- in 2016 where at least 10 g played. Highest 5

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
LIMIT 5;
		-- Dodgers, Cardinals,Browns, Perfectos, Blue Jays

	-- Lowest AVG
SELECT t.name AS team, p.park_name, SUM(h.attendance)/SUM(h.games) AS avg_attendance
FROM homegames AS h
	JOIN parks as p
		ON h.park = p.park
	JOIN teams AS t
		ON h.team = t.teamid
	WHERE games >= 10
	AND h.year = 2016
GROUP BY t.name, p.park_name
ORDER BY avg_attendance ASC
LIMIT 5;
		-- Devil Rays, Rays, Athletics, Indians, Naps, Bronchos


	-- NUMBER TEN --
		-- Players w/ at least 1o yr career, who his career highest HR in 2016 >1

WITH career_HR AS
	(SELECT playerid, 
			MAX(hr) AS career_highHR, COUNT(*) AS seasons
	FROM batting
	GROUP BY playerid),

HR_2016 AS
	(SELECT playerid, SUM(hr) AS HR_2016
	FROM batting
		WHERE yearid=2016
	GROUP BY playerid)

SELECT CONCAT(p.namefirst, ', ', p.namelast), HR_2016.HR_2016
FROM HR_2016 
	JOIN career_HR AS HR
		ON HR_2016.playerid = HR.playerid
	JOIN people AS p
		ON p.playerid = HR.playerid
	WHERE HR_2016 = HR.career_highHR
		AND HR_2016 > 0
		AND seasons >= 10
ORDER BY HR_2016 DESC;


-- ** OPEN ENDED QUESTIONS ** --
	
	-- NUMBER ELEVEN --

WITH team_salaries AS
	(SELECT yearid, teamid, SUM(salary) AS salary_total
	FROM salaries
		WHERE yearid >= 2000
	GROUP BY yearid, teamid),

team_wins AS
	(SELECT yearid, teamid, name, w AS wins
	FROM teams
		WHERE yearid >= 2000)

SELECT salaries.yearid, salaries.teamid, wins.name,
		salaries.salary_total, wins.wins
FROM team_salaries AS salaries
	JOIN team_wins AS wins
		ON salaries.teamid = wins.teamid
		AND salaries.yearid = wins.yearid
ORDER BY salaries.yearid, salaries.teamid;

-- CORRELATION --
	-- Discovered I can import the above into excel and use correlate there,
	-- or do the function below

WITH team_salaries AS
	(SELECT yearid, teamid, SUM(salary) AS salary_total
	FROM salaries
		WHERE yearid >= 2000
	GROUP BY yearid, teamid),

team_wins AS
	(SELECT yearid, teamid, name, w AS wins
	FROM teams
		WHERE yearid >= 2000)

SELECT yearid, CORR(wins, salary_total) AS wins_salary_CORR
FROM 
	(SELECT salaries.yearid, wins.name,
		salaries.salary_total, wins.wins
	FROM team_salaries AS salaries
		JOIN team_wins AS wins
			ON salaries.teamid = wins.teamid
	AND salaries.yearid = wins.yearid) AS combined
GROUP BY yearid
ORDER BY yearid;
		-- Overall, the more wins does usually signify a higher salary, 
		-- but some popular teams keep higher salaries even with less wins


	-- NUMBER TWELVE --

	-- PART A -- hg wins vs. attendance

SELECT yearid, teamid, w AS wins, attendance, ghome AS homegame,
		ROUND((attendance * 1.0 / ghome),2) AS AVG_attendance_pergame
FROM teams
	WHERE ghome IS NOT NULL
		AND attendance IS NOT NULL
ORDER BY yearid, teamid;
		-- would appear that wins bring in more game attendance on avg

	-- PART B -- world series boost? playoffs?

WITH playoff_teams AS
	(SELECT yearid, teamid, name, wswin, divwin, wcwin, attendance AS current_year_attendance
	FROM teams
		WHERE wswin = 'y' OR divwin = 'y' OR wcwin = 'y' ),

following_year AS
	(SELECT yearid, teamid, name, attendance AS following_year_attendance
	FROM teams)

SELECT playoffs.yearid, playoffs.teamid, following.name, playoffs.current_year_attendance, following.following_year_attendance,
			(following.following_year_attendance - playoffs.current_year_attendance) AS attendance_change, wswin, divwin, wcwin
FROM playoff_teams AS playoffs
	JOIN following_year AS following
		ON playoffs.teamid = following.teamid
		AND playoffs.yearid +1 = following.yearid
ORDER BY playoffs.yearid, playoffs.teamid;
		-- mixed bag of results, some saw massive growth after series or playoff wins, others lost attendance numbers.
		-- could potential increase of ticket prices after a win account for this?

SELECT
    CASE 
        WHEN WSWin = 'Y' THEN 'World Series Winner'
        WHEN DivWin = 'Y' OR WCWin = 'Y' THEN 'Playoff Team'
        ELSE 'Non-Playoff Team'
    END AS team_type,
    AVG(following_year_attendance - current_year_attendance) AS avg_attendance_change
FROM 
(WITH playoff_teams AS
	(SELECT yearID,teamID, WSWin, DivWin, WCWin,
            attendance AS current_year_attendance
     FROM teams),
		
following AS (
	SELECT yearID, teamID,
    	attendance AS following_year_attendance
    FROM teams)
		
SELECT p.*, following.following_year_attendance
FROM playoff_teams p
    JOIN following
      ON p.teamID = following.teamID
     AND p.yearID + 1 = following.yearID)
GROUP BY team_type;

	-- NUMBER THIRTEEN --

SELECT *
FROM people;

SELECT p.throws, COUNT(DISTINCT pitching.playerid) AS num_pitchers
FROM pitching 
JOIN people AS p
	ON pitching.playerid = p.playerid
	WHERE p.throws IN ('L','R')
GROUP BY p.throws;
		-- L 2477 R 6605. Less than half L hand

SELECT p.throws, COUNT(*) AS cy_young_wins
FROM awardsplayers AS awards
	JOIN people AS p
		ON awards.playerID = p.playerID
	WHERE awards.awardID = 'Cy Young Award'
		AND p.throws IN ('L','R')
GROUP BY p.throws;
		-- CY Young Award winners: L=37 R=75
		-- definitely less likely to win this, but are we looking at rate?

WITH pitcher_counts AS 
    (SELECT p.throws,
        COUNT (DISTINCT pitching.playerID) AS num_pitchers
    FROM pitching 
   		 JOIN people AS p 
			ON pitching.playerID = p.playerID
    	WHERE p.throws IN ('L','R')
    GROUP BY p.throws),
	
cy_counts AS 
	(SELECT p.throws, COUNT(*) AS cy_young_wins
    FROM awardsplayers AS awards
   		 JOIN people AS p
			ON awards.playerID = p.playerID
    WHERE awards.awardID = 'Cy Young Award'
     	AND p.throws IN ('L','R')
    GROUP BY p.throws)
	
SELECT
    c.throws, cy_young_wins, num_pitchers,
    (cy_young_wins * 1.0 / num_pitchers) AS cy_win_rate
FROM cy_counts AS c
	JOIN pitcher_counts AS p 
		ON c.throws = p.throws;
		-- Looking at the rate of wins shows L handed pitchers are 
		-- SLIGHTLY more likely to win the award

SELECT 
    p.throws,
    COUNT(*) AS hof_inductees
FROM halloffame AS hof
	JOIN people AS p
		ON hof.playerID = p.playerID
	WHERE hof.inducted = 'Y'
 		AND p.throws IN ('L','R')
GROUP BY p.throws;
		-- L=52 R=231 
		-- lets get rate again

WITH pitcher_counts AS 
    (SELECT p.throws,
        COUNT (DISTINCT pitching.playerID) AS num_pitchers
    FROM pitching 
    	JOIN people AS p 
			ON pitching.playerID = p.playerID
    	WHERE p.throws IN ('L','R')
    GROUP BY p.throws),

hof_counts AS
	(SELECT p.throws,
    COUNT(*) AS hof_inductees
	FROM halloffame AS hof
		JOIN people AS p
			ON hof.playerID = p.playerID
		WHERE hof.inducted = 'Y'
 	 		AND p.throws IN ('L','R')
	GROUP BY p.throws)

SELECT h.throws, hof_inductees, num_pitchers, 
		(hof_inductees * 1.0 / num_pitchers) AS hof_rate
FROM hof_counts AS h
	JOIN pitcher_counts AS pitcher
		ON h.throws = pitcher.throws;
	-- Left handed pitchers are less likely to be inducted

-- Going back through unassigned questions: 4,6,7,9
	
	-- QUESTION FOUR --

SELECT
	CASE 
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ('SS', '1B','2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
	END AS position_group,
	SUM(po) AS putout_totals
FROM fielding
WHERE yearid = 2016
GROUP BY position_group;

	-- QUESTION SIX --

SELECT playerid, sb, cs, sb+cs AS sb_attempts,
	ROUND(sb::numeric / (sb+cs) *100, 2) AS sb_success_rate
FROM batting
	WHERE yearid = 2016
		AND (sb+cs) >=20
ORDER BY sb_success_rate DESC
LIMIT 1;
	 	-- owingch01 with highest stolen base success rate at 0.913

	-- QUESTION SEVEN --
		--lets find the problem year first
SELECT yearid, teamid, w AS wins
FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	AND wswin = 'N'
ORDER BY wins DESC
LIMIT 1;
	 		-- largest wins but did NOT win world series
				-- SEA in 2001 with 116 wins 
				
SELECT yearid, teamid, w AS wins
FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	AND wswin = 'Y'
ORDER BY wins ASC
LIMIT 2;
		-- smallest wins that DID win world series
			-- LAN in 1981 with 63 wins & SLN in 2006 w/ 83 wins
			-- shortened season in 1981 due to strike, so uneven number of games

SELECT yearid, teamid, w AS wins
FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	AND wswin = 'Y'
	AND yearid NOT IN (1981, 2006)
ORDER BY wins ASC
LIMIT 1;
		-- exclude 1981 and 2006 as problem years
			-- next up is MIN in 1987 with 85 wins

		-- PART B --
			--most wins per year that won world series & percentage
WITH most_wins AS
	(SELECT yearid, MAX(w) AS highest_w 
	FROM teams
		WHERE yearid BETWEEN 1970 AND 2016
		AND yearid NOT IN (1981, 2006)
	GROUP BY yearid)
SELECT COUNT(*) AS years_max_won_WS
FROM most_wins
	JOIN teams
		ON most_wins.yearid = teams.yearid
		AND most_wins.highest_w = teams.w
	WHERE teams.wswin = 'Y';
			-- 12

		-- Now for the percentage of teams with top wins that also won WS
WITH most_wins AS 
	(SELECT yearid, MAX(w) AS highest_w
    FROM teams
    WHERE yearid BETWEEN 1970 AND 2016
      AND yearid NOT IN (1981)
    GROUP BY yearid),
ws_top_winners AS (
    SELECT COUNT(*) AS years_max_won_ws
    FROM most_wins
    JOIN teams
      ON most_wins.yearid = teams.yearid
     AND most_wins.highest_w = teams.w
    WHERE teams.wswin = 'Y'),
total_years AS 
	(SELECT COUNT(DISTINCT yearid) AS total_valid_years
    FROM teams
    WHERE yearid BETWEEN 1970 AND 2016
      AND yearid NOT IN (1981))
SELECT 
    ws_top_winners.years_max_won_ws,
    total_years.total_valid_years,
    ROUND(ws_top_winners.years_max_won_ws::numeric 
        / total_years.total_valid_years, 3) AS percentage_top_team_won_ws
FROM ws_top_winners, total_years;
		-- about 26.7% of WS winners also achieved top game wins, excluding problem years 1981 & 2006
		-- or 26.1% when only excluding 1981

	-- NUMBER NINE --
WITH dual_winners AS 
    (SELECT playerID
    FROM awardsmanagers
    WHERE awardID = 'TSN Manager of the Year'
    GROUP BY playerID
    HAVING COUNT(DISTINCT lgID) = 2)
SELECT p.namefirst, p.namelast, awards.yearID, awards.lgID, t.teamID, t.name
FROM dual_winners AS d
	JOIN awardsmanagers AS awards
   		ON d.playerID = awards.playerID
	JOIN managers AS m
    	ON awards.playerID = m.playerID
   		AND awards.yearID = m.yearID
	JOIN teams AS t
    	ON m.teamID = t.teamID
   		AND m.yearID = t.yearID
	JOIN people AS p
    	ON p.playerID = awards.playerID
WHERE awards.awardID = 'TSN Manager of the Year'
ORDER BY p.namelast, awards.yearID;
	-- is there a way to clean this up? it looks so messy










