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