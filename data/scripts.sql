--concat(birthyear,'-', birthmonth, '-', birthday) as dob,
--concat(deathyear,'-', deathmonth, '-', deathday) as dod,

/*1. What range of years for baseball games played does the provided database cover?*/

SELECT
	MIN(cast(debut as date)) AS min_debut,
	MAX(cast(finalgame as date)) AS max_finalgame
FROM people;


/*2. Find the name and height of the shortest player in the database.
How many games did he play in? What is the name of the team for which he played?*/
--Shortest
SELECT
 	height
FROM people
WHERE height is not null
group by height
order by height;

Select
	namefirst,
	namelast
FROM people
Where height = 43;

--Tallest
SELECT
	height
FROM people
WHERE height is not null
group by height
order by height desc;

Select
	namefirst,
	namelast
FROM people
Where height = 83;

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
GROUP BY position_group
order by total_putouts desc;

/*5.Find the average number of strikeouts per game by decade since 1920.
Round the numbers you report to 2 decimal places.
Do the same for home runs per game.
Do you see any trends?*/

select * from batting;

select
	FLOOR(yearid/10) * 10 AS decade,
	round(avg(hr),2) as hr_avg,
	round(avg(so),2) as so_avg
FROM batting
group by yearid
order by decade desc; 



/*6.Find the player who had the most success stealing bases in 2016,
where success is measured as the percentage of stolen base attempts which are successful.
(A stolen base attempt results either in a stolen base or being caught stealing.)
Consider only players who attempted at least 20 stolen bases.*/

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