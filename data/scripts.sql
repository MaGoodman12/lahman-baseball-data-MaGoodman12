--concat(value,' ', value, ' ', value) as __;

/*1. What range of years for baseball games played does the provided database cover?*/

select * from appearances;

select 
	min(yearid),
	max(yearid)
from appearances;
--1871-2016

/*2. Find the name and height of the shortest player in the database.
How many games did he play in?
What is the name of the team for which he played?*/

select * from people;
select * from appearances;
select * from teams;

SELECT
	concat(p.namefirst, ' ', p.namelast) as name,
 	min(height) as height,
	t.name as team,
	a.g_all as games_played
FROM people as p
LEFT join appearances as a
using(playerid)
join teams as t
on a.teamid = t.teamid
WHERE height is not null
group by height, namefirst, namelast, t.teamid, t.name, a.g_all
order by height
limit 1;
--Eddie Gaedel, 43', Browns, 1 game


/*3. Find all players in the database who played at Vanderbilt University.
Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues.
Sort this list in descending order by the total salary earned.
Which Vanderbilt player earned the most money in the majors?*/

SELECT * FROM schools;
SELECT * FROM people;
SELECT * FROM collegeplaying;
SELECT * FROM salaries;

SELECT
	DISTINCT CONCAT( p.namefirst, ' ',  p.namelast) AS player,
	SUM(distinct sa.salary) AS total_salary
FROM people as p
JOIN collegeplaying as c
USING(playerid)
JOIN schools as sc
USING(schoolid)
JOIN salaries as sa
USING(playerid)
WHERE sc.schoolname ilike '%vand%'
GROUP BY player
order by total_salary desc;
--David Price, 81M

/*4.Using the fielding table, group players into three groups based on their position:
label players with position OF as "Outfield",
those with position "SS", "1B", "2B", and "3B" as "Infield",
and those with position "P" or "C" as "Battery".
Determine the number of putouts made by each of these three groups in 2016.*/

SELECT * FROM fielding;

WITH positions AS (
	SELECT
	po,
	yearid,
	CASE WHEN pos IN ('OF') THEN 'Outfield'
		WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
	 	WHEN pos IN ('P', 'C') THEN 'Battery'
	 	END AS positions
FROM fielding)

SELECT
	p.positions,
	SUM(po) AS putouts
FROM positions as p
WHERE yearid = '2016'
GROUP BY positions;
--Battery 41424
--Infield 58934
--Outfield 29560

/*5.Find the average number of strikeouts per game by decade since 1920.
Round the numbers you report to 2 decimal places.
Do the same for home runs per game.
Do you see any trends?*/

select * from teams;

SELECT
	FLOOR(yearid/10) * 10 AS decade,
	SUM(soa) as so_pitcher,
	SUM(so) as so_batter,
	ROUND(CAST(SUM(so) as dec) / CAST(SUM(g) as dec), 2) as so_avg,
	ROUND(CAST(SUM(hr) as dec) / CAST(SUM(g) as dec), 2) as hr_avg
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;
--all values increase following timeline

/*andrew-
SELECT decade, 
		SUM(so) as so_batter, SUM(soa) as so_pitcher, 
		ROUND(CAST(SUM(so) as dec) / CAST(SUM(g) as dec), 2) as so_per_game,
		ROUND(CAST(SUM(hr) as dec) / CAST(SUM(g) as dec), 2) as hr_per_game
FROM (
	SELECT CASE 
			WHEN yearid >= 2010 THEN '2010s'
			WHEN yearid >= 2000 THEN '2000s'
			WHEN yearid >= 1990 THEN '1990s'
			WHEN yearid >= 1980 THEN '1980s'
			WHEN yearid >= 1970 THEN '1970s'
			WHEN yearid >= 1960 THEN '1960s'
			WHEN yearid >= 1950 THEN '1950s'
			WHEN yearid >= 1940 THEN '1940s'
			WHEN yearid >= 1930 THEN '1930s'
			WHEN yearid >= 1920 THEN '1920s'
			ELSE NULL
		END AS decade,
		so,
		soa,
		hr,
		g
	FROM teams
) sub
WHERE decade IS NOT NULL
GROUP BY decade
ORDER BY decade DESC;
*/

/*6.Find the player who had the most success stealing bases in 2016,
where success is measured as the percentage of stolen base attempts which are successful.
(A stolen base attempt results either in a stolen base or being caught stealing.)
Consider only players who attempted at least 20 stolen bases.*/

select * from people;
select * from batting;

select
	DISTINCT CONCAT( p.namefirst, ' ',  p.namelast) AS player,
	sum(sb_2 + cs_2) as attempts,
	round((sum(sb_2) / sum(sb_2 + cs_2) * 100),2) as success_rate
FROM
(
select
	distinct b.playerid,
	cast(sb as numeric) as sb_2,
	cast(cs as numeric) as cs_2
from batting as b
where sb is not null and cs is not null
AND yearid = 2016
group by playerid, sb, cs
having sum(sb + cs) > 20) as sub1
join people as p
using(playerid)
group by player
order by success_rate desc
limit 1;
--Chris Owings, 23 attempts, 91.30 success_rate

/*7.From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
What is the smallest number of wins for a team that did win the world series?
Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case.
Then redo your query, excluding the problem year.
How often from 1970 – 2016 was it the case that a team with the most wins also won the world series?
What percentage of the time?*/

select * from teams;

--most wins w/ no ws_win
select yearid, name as team, w
from teams
where wswin = 'N' AND yearid between 1970 AND 2016
group by yearid, name, w
order by w desc;
--2001 mariners 116w

--least wins w/ ws_win
select yearid, name as team, w
from teams
where wswin = 'Y' AND yearid between 1970 AND 2016
group by yearid, name, w
order by w;
--1981 dodgers 63w

--why are wins so low
select *
from teams
where name ilike '%dodge%'
and yearid = 1981;
--due to 550 s.o.

--lowest w for ws_win <>1981
select yearid, name as team, w
from teams
where wswin = 'Y' AND yearid between 1970 and 1980 and yearid <> 1981
group by yearid, name, w
order by w;
--Oakland Athletics 90w

--% of ws_wins with highest w
select *
FROM
	(
	select distinct yearid, name as team, w, wswin
	from teams
	where wswin is not null and yearid between 1970 and 2016
	group by yearid, name, wswin, w
	order by yearid, w desc) as ws
where wswin = 'Y'
order by yearid;
--not finished
--case when with numeric values for yes and no percentages


/*8.Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016
(where average attendance is defined as total attendance divided by number of games).
Only consider parks where there were at least 10 games played. 
Report the park name, team name, and average attendance.
Repeat for the lowest 5 average attendance.*/

select * from homegames;
select * from parks;
select * from teams;

--top 5 most attended
select p.park_name as park, t.name as team, sum(h.attendance / h.games) as avg_attend
from homegames as h
join parks as p
using(park)
join teams as t
on h.team = t.teamid and h.year = t.yearid
where year = 2016
and h.games > 10
group by p.park_name, t.name
order by avg_attend desc
limit 5;

--top 5 least attended
select p.park_name as park, t.name as team, sum(h.attendance / h.games) as avg_attend
from homegames as h
join parks as p
using(park)
join teams as t
on h.team = t.teamid and h.year = t.yearid
where year = 2016
and h.games > 10
group by p.park_name, t.name
order by avg_attend
limit 5;

/*9.Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)?
Give their full name and the teams that they were managing when they won the award.*/
select * from people;
select * from managers;
select * from awardsmanagers;
select * from teams;

WITH nl_league AS
(
select playerid, awardid as award, yearid as year, lgid as league
from awardsmanagers
where awardid ilike '%tsn%'
and lgid = 'NL'
group by playerid, awardid, yearid, lgid
order by playerid
),

al_league AS
(
select playerid, awardid as award, yearid as year, lgid as league
from awardsmanagers
where awardid ilike '%tsn%'
and lgid = 'AL'
group by playerid, awardid, yearid, lgid
order by playerid
)

select distinct m.playerid, concat(p.namefirst, ' ', p.namelast) as manager, t.name as team, nl.award, nl.year, nl.league, al.league
from nl_league as nl
JOIN al_league as al
on nl.playerid = al.playerid and nl.award = al.award
JOIN managers as m
on nl.playerid = m.playerid and al.playerid = m.playerid
JOIN people as p
on m.playerid = p.playerid
join teams as t
on m.teamid = t.teamid
order by year, m.playerid

--CTES with al and nl, using 'having = 2 for results
--


--goal outcome
SELECT *
FROM awardsmanagers
WHERE awardid ILIKE '%TSN%';

WITH m AS 
(SELECT *
FROM awardsmanagers
WHERE lgid = 'AL'
	AND awardid ILIKE '%TSN%'
	AND playerid IN (
		SELECT playerid
		FROM awardsmanagers
		WHERE awardid ILIKE '%TSN%'
			AND lgid = 'NL'
	)
UNION
SELECT *
FROM awardsmanagers
WHERE lgid = 'NL'
	AND awardid ILIKE '%TSN%'
	AND playerid IN (
		SELECT playerid
		FROM awardsmanagers
		WHERE awardid ILIKE '%TSN%'
			AND lgid = 'AL'
	)
 )
SELECT m.awardid, m.yearid AS award_year, 
		m.lgid AS award_league, 
		p.namefirst, p.namelast,
		t.name
FROM m
LEFT JOIN people p ON p.playerid = m.playerid
LEFT JOIN managers ON managers.playerid = m.playerid
			AND managers.yearid = m.yearid
LEFT JOIN teams t ON t.yearid = managers.yearid AND managers.teamid = t.teamid
ORDER BY p.namelast, m.yearid;

--Open-ended questions

/*10.Analyze all the colleges in the state of Tennessee.
Which college has had the most success in the major leagues?
Use whatever metric for success you like -
number of players, number of games, salaries, world series wins, etc.*/

/*11.Is there any correlation between number of wins and team salary?
Use data from 2000 and later to answer this question.
As you do this analysis,
keep in mind that salaries across the whole league tend to increase together,
so you may want to look on a year-by-year basis.*/

--(value::numeric::money)

/*12.In this question, you will explore the connection between number of wins and attendance.

a.Does there appear to be any correlation between attendance at home games and number of wins?

b.Do teams that win the world series see a boost in attendance the following year?
What about teams that made the playoffs?
Making the playoffs means either being a division winner or a wild card winner.*/



/*13.It is thought that since left-handed pitchers are more rare,
causing batters to face them less often, that they are more effective.
Investigate this claim and present evidence to either support or dispute this claim.
First, determine just how rare left-handed pitchers are compared with right-handed pitchers.
Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?*/


