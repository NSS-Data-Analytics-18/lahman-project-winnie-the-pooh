--Question 1
SELECT
	MIN(yearid) as earliest_year,
	MAX(yearid) as latest_year
FROM teams; 
--1871-2016

--Question 2
SELECT namefirst, namelast, height, g_all, teamid
FROM people 
	INNER JOIN appearances ON people.playerid = appearances.playerid
WHERE namefirst = 'Eddie' AND namelast = 'Gaedel'
ORDER BY height ASC;
--shortest player name and height 
--Eddie Gaedel 43(inches) 
--games he played and team 

--Question 3
SELECT DISTINCT namefirst, namelast, salary, schoolid
FROM collegeplaying
	INNER JOIN salaries ON collegeplaying.playerid = salaries.playerid
	INNER JOIN people ON collegeplaying.playerid = people.playerid
WHERE schoolid = 'vandy'
ORDER BY salary DESC;

--Question 6
SELECT *
	FROM (SELECT namefirst, namelast, sb, (sb+cs) AS attempts, CONCAT(ROUND((sb * 100.0) / NULLIF(sb + cs, 0), 2), '%') AS sb_percentage, yearid
	FROM batting 
	INNER JOIN people ON batting.playerid = people.playerid
	WHERE yearid = 2016) AS sb_2016
WHERE attempts > 20
ORDER BY sb_percentage DESC
LIMIT 1;
--Chris Owings had the most success 91.30% and 21 stolen bases 

--Question 9
SELECT people.namefirst, people.namelast, awardsmanagers.yearid, awardsmanagers.lgid, teams.name AS team_name
FROM awardsmanagers 
	INNER JOIN people ON awardsmanagers.playerid = people.playerid
	INNER JOIN teams  ON awardsmanagers.yearid = teams.yearid AND awardsmanagers.yearid = teams.yearid AND awardsmanagers.lgid = teams.lgid
WHERE awardsmanagers.awardid = 'TSN Manager of the Year' AND awardsmanagers.playerid IN (SELECT playerid
	FROM awardsmanagers
	WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('NL', 'AL')
	GROUP BY playerid
	HAVING COUNT(DISTINCT lgid) = 2)
ORDER BY namefirst DESC;
--all coaches who had both  awards for AL and NL 





