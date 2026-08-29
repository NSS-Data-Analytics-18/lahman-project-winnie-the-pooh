-- LAHMANS BASEBALL DATABASE --

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
		
SELECT p.namefirst, p.namelast, s.schoolname, SUM(sal.salary) AS total_salary
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

-- ASSIGNED 5, 8, 10 by Team Lead --

	-- NUMBER FIVE --
		-- AVG number of SO, HR per game since 1920, round 2

SELECT *
FROM teams;

SELECT (yearid/ 10) *10 AS decade,
	ROUND(AVG(so::numeric/g), 2) AS avg_SO_pergame,
	ROUND(AVG(hr::numeric/g), 2) AS avg_HR_pergame
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;
		-- general upward trend, as strikeouts increase, homerun avg does too

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
LIMIT 10;
		-- Dodgers, Cardinals,Browns, Perfectos, Blue Jays
		-- Giants, Colts, Cubs, Orphans, White Stockings

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
LIMIT 10;
		-- Devil Rays, Rays, Athletics, Indians, Naps, Bronchos
		-- Blues, Marlins, White Sox, Redlegs


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
		ON h.throws = pitcher.throws
	-- Left handed pitchers are less likely to be inducted