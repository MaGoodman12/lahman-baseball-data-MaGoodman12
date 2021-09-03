--concat(birthyear,'-', birthmonth, '-', birthday) as dob,
--concat(deathyear,'-', deathmonth, '-', deathday) as dod,

/*1. What range of years for baseball games played does the provided database cover?*/

SELECT
	MIN(cast(debut as date)) AS min_debut,
	MAX(cast(finalgame as date)) AS max_finalgame
FROM people;

select min
/*2. Find the name and height of the shortest player in the database.
How many games did he play in?
What is the name of the team for which he played?*/
--Shortest
select * from people;
select * from appearances;
select name from teams;
SELECT
	concat(namefirst, namelast) as name,
 	height,
	name
FROM people as p
join teams as t
on 
WHERE height is not null
group by height, namefirst, namelast, teamid
order by height
limit 1;

Select
	namefirst,
	namelast
FROM people
Where height = 43;

/*3. Find all players in the database who played at Vanderbilt University.
Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues.
Sort this list in descending order by the total salary earned.
Which Vanderbilt player earned the most money in the majors?*/

SELECT * FROM schools;
SELECT * FROM people;
SELECT * FROM collegeplaying;
SELECT * FROM salaries;

SELECT
	s.playerid,
	SUM(s.salary) AS total_salary
FROM salaries as s
WHERE playerid IN (
	SELECT 
		DISTINCT playerid
	FROM collegeplaying as c
	WHERE schoolid = 'vandy')
GROUP BY playerid
ORDER BY total_salary desc;

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
	 	END AS position_group
FROM fielding)

SELECT
	p.position_group,
	SUM(po) AS total_putouts
FROM positions as p
WHERE yearid = '2016'
GROUP BY position_group;

/*5.Find the average number of strikeouts per game by decade since 1920.
Round the numbers you report to 2 decimal places.
Do the same for home runs per game.
Do you see any trends?*/

select * from pitching;
select * from batting;

WITH decades AS
(select
 	FLOOR(yearid/10) * 10 AS decade
FROM batting
where yearid >1920
group by decade
order by decade
)

select
	d.decade,
 	round(avg(p.so + b.so),2) as so_avg,
	round(avg(p.hr + b.hr),2) as hr_avg
from pitching as p
LEFT JOIN batting as b
using(yearid)
LEFT JOIN decades as d
on p.yearid = d.decade
 where p.so >0 and p.so is not null
 AND b.so >0 and b.so is not null
 and decade is not null
 group by decade;
 
 --needs to be on GAMES table
 
/*SELECT 
	yearid/10*10 AS decade,
	ROUND(AVG(so),2) AS avg_strikeouts,
	ROUND(AVG(hr),2) AS avg_homeruns
FROM batting
WHERE yearid >= 1920
GROUP BY yearid/10*10
ORDER BY yearid/10*10;*/

/*andrew-SELECT decade, 
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
-- 	WHERE decade IS NOT NULL
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
select * from fielding;

select
player,
	sum(sb_2 + cs_2) as attempts,
	round((sum(sb_2) / sum(sb_2 + cs_2) * 100),2) as success
FROM
(
select
	distinct playerid as player,
	cast(sb as numeric) as sb_2,
	cast(cs as numeric) as cs_2
from batting
where sb is not null and cs is not null
group by player, sb, cs
having sum(sb + cs) > 20) as sub1
group by player
order by success desc;


/*7.From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
What is the smallest number of wins for a team that did win the world series?
Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case.
Then redo your query, excluding the problem year.
How often from 1970 – 2016 was it the case that a team with the most wins also won the world series?
What percentage of the time?*/

/*8.Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016
(where average attendance is defined as total attendance divided by number of games).
Only consider parks where there were at least 10 games played. 
Report the park name, team name, and average attendance.
Repeat for the lowest 5 average attendance.*/

/*9.Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)?
Give their full name and the teams that they were managing when they won the award.*/



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


