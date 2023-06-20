/* 

Covid 19 Data Exploration 

Skills used: Joins, CTE's, Aggregate Functions, Converting Data Types, Creating Views

*/

--Total Cases vs. Total Deaths for US
SELECT location, date, new_cases, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
	FROM Covid_Project..CovidDeaths
	WHERE location = 'United States'
	ORDER BY 1,2

--Peak New Cases by Location
WITH PeakCases AS (
    SELECT location, new_cases, date,
           ROW_NUMBER() OVER (PARTITION BY location ORDER BY new_cases DESC, date DESC) AS rn
    FROM Covid_Project..CovidDeaths
	WHERE location IN (SELECT location FROM Covid_Project..Population)
)
SELECT location, new_cases, date
FROM PeakCases
WHERE rn = 1
ORDER BY location


--Total Cases vs Population Percent Rate
SELECT dea.location, MAX(dea.total_cases) as total_cases, pop.population, MAX(dea.total_cases)/pop.population *100 as total_infection_rate
	FROM Covid_Project..CovidDeaths dea
	JOIN Covid_Project..Population pop
		ON dea.location = pop.location
	GROUP BY dea.location, pop.population
	ORDER BY 4 DESC

--Total Death Count by Location
SELECT location, MAX(total_deaths) as total_deaths
	FROM Covid_Project..CovidDeaths
	WHERE location IN (SELECT location FROM Covid_Project..Population)
	GROUP BY location
	ORDER BY 2 DESC

--Peak Death Count by Location
WITH PeakDeaths AS (
    SELECT location, new_deaths, date,
           ROW_NUMBER() OVER (PARTITION BY location ORDER BY new_deaths DESC, date DESC) AS rn
    FROM Covid_Project..CovidDeaths
	WHERE location IN (SELECT location FROM Covid_Project..Population)
)
SELECT location, new_deaths, date
FROM PeakDeaths
WHERE rn = 1
ORDER BY date DESC;

--Total Deaths vs Population Percent Rate
SELECT dea.location, MAX(dea.total_deaths) as total_deaths, pop.population, MAX(dea.total_deaths)/pop.population *100 as total_death_rate
	FROM Covid_Project..CovidDeaths dea
	JOIN Covid_Project..Population pop
		ON dea.location = pop.location
	GROUP BY dea.location, pop.population
	ORDER BY 1 

--Global summaries
	--By Date
	SELECT date, SUM(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS new_death_percent
		FROM Covid_Project..CovidDeaths
		WHERE new_cases > '0' AND location IN (SELECT location FROM Covid_Project..Population)
		GROUP BY date
		ORDER BY new_death_percent DESC
	--Overall
	SELECT SUM(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS new_death_percent
		FROM Covid_Project..CovidDeaths
		WHERE location IN (SELECT location FROM Covid_Project..Population)

--Rolling Daily People Vaccinated vs Population Percentages by Date
WITH vaxdaily AS
(
SELECT vacs.location, vacs.date, pop.population, vacs.daily_people_vaccinated, SUM(CAST(vacs.daily_people_vaccinated AS numeric)) OVER (PARTITION BY vacs.location ORDER BY vacs.location, vacs.date) AS rolling_daily_vaccinations_people
	FROM Covid_Project..CovidVaccinations vacs
	JOIN Covid_Project..Population pop
		ON vacs.location = pop.location
	WHERE vacs.daily_people_vaccinated IS NOT NULL 
)
Select*, rolling_daily_vaccinations_people/population as rolling_percent
	FROM vaxdaily
	ORDER BY location, date 

--Total People Vaccinated vs Population Percentages by Date
WITH vaxpop AS
(
SELECT vacs.location, vacs.date, pop.population, vacs.people_vaccinated, 
		ROW_NUMBER() OVER (PARTITION BY vacs.location ORDER BY vacs.people_vaccinated DESC, date DESC) AS rn
	FROM Covid_Project..CovidVaccinations vacs
	JOIN Covid_Project..Population pop
		ON vacs.location = pop.location
)
Select location, date, population, people_vaccinated, CAST(people_vaccinated AS numeric)/population as vaccinated_percent
	FROM vaxpop
	WHERE rn = 1 
	ORDER BY location  

--Total People Fully Vaccinated vs Population Percentages by Date
WITH fullyvax AS
(
SELECT vacs.location, vacs.date, pop.population, vacs.people_fully_vaccinated,
		ROW_NUMBER() OVER (PARTITION BY vacs.location ORDER BY people_fully_vaccinated DESC, date DESC) AS rn
	FROM Covid_Project..CovidVaccinations vacs
	JOIN Covid_Project..Population pop
		ON vacs.location = pop.location
)
Select location, date, population, people_fully_vaccinated, CAST(people_fully_vaccinated AS numeric)/population as fully_vaccinated_percent
	FROM fullyvax
	WHERE rn = 1 
	ORDER BY location  


--Covid Hospitalizations
SELECT *
FROM Covid_Project..CovidHospitalizations
  WHERE indicator = 'Daily hospital occupancy' OR indicator= 'Daily ICU occupancy' OR indicator = 'Weekly new ICU admissions' OR indicator = 'Weekly new hospital admissions'
  ORDER BY location


--New Cases vs. Daily Vaccinations vs. ICU Occupancy vs. New Deaths
SELECT dea.date, dea.new_deaths, dea.new_cases, vacs.daily_vaccinations, dea.location, hos.value as icu_occupancy
FROM Covid_Project..CovidDeaths dea
JOIN Covid_Project..CovidVaccinations vacs ON dea.date = vacs.date AND dea.location = vacs.location
JOIN Covid_Project..CovidHospitalizations hos ON dea.date = hos.date AND dea.location = hos.location
WHERE hos.indicator = 'Daily ICU occupancy' 


--Create Views
	--Vax vs Population
	DROP VIEW IF EXISTS vaxdaily
	CREATE VIEW vaxdaily AS
	(
	SELECT vacs.location, vacs.date, pop.population, vacs.daily_people_vaccinated, SUM(CAST(vacs.daily_people_vaccinated AS numeric)) OVER (PARTITION BY vacs.location ORDER BY vacs.location, vacs.date) AS rolling_daily_vaccinations_people
	FROM Covid_Project..CovidVaccinations vacs
	JOIN Covid_Project..Population pop
		ON vacs.location = pop.location
	WHERE vacs.daily_people_vaccinated IS NOT NULL 
	)

	DROP VIEW IF EXISTS vaxpop
	CREATE VIEW vaxpop 	AS
	SELECT v.location, v.date, v.population, v.people_vaccinated
	FROM (
		SELECT vacs.location, vacs.date, pop.population, vacs.people_vaccinated, 
			ROW_NUMBER() OVER (PARTITION BY vacs.location ORDER BY people_vaccinated DESC, date DESC) AS rn
		FROM Covid_Project..CovidVaccinations vacs
		JOIN Covid_Project..Population pop
			ON vacs.location = pop.location
	) v
	WHERE v.rn = 1

	CREATE VIEW fullyvax 	AS
	SELECT f.location, f.date, f.population, f.people_fully_vaccinated
	FROM (
		SELECT vacs.location, vacs.date, pop.population, vacs.people_fully_vaccinated,
			ROW_NUMBER() OVER (PARTITION BY vacs.location ORDER BY people_fully_vaccinated DESC, date DESC) AS rn
		FROM Covid_Project..CovidVaccinations vacs
		JOIN Covid_Project..Population pop
			ON vacs.location = pop.location
	) f
	WHERE f.rn = 1

	CREATE VIEW peakdeath AS
	(
	SELECT location, new_deaths, date,
           ROW_NUMBER() OVER (PARTITION BY location ORDER BY new_deaths DESC, date DESC) AS rn
    FROM Covid_Project..CovidDeaths
	)

	CREATE VIEW totaldeath AS
	(
	SELECT location, MAX(total_deaths) as total_deaths
	FROM Covid_Project..CovidDeaths
	WHERE location IN (SELECT location FROM Covid_Project..Population)
	GROUP BY location
	)

	CREATE VIEW peakcases AS
	(
	WITH PeakCases AS (
		SELECT location, new_cases, date,
           ROW_NUMBER() OVER (PARTITION BY location ORDER BY new_cases DESC, date DESC) AS rn
		FROM Covid_Project..CovidDeaths
		WHERE location IN (SELECT location FROM Covid_Project..Population)
		)
	SELECT location, new_cases, date
	FROM PeakCases
	WHERE rn = 1
	)

	CREATE VIEW dailycases_deaths AS
	(
	SELECT location, date, new_cases, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
	FROM Covid_Project..CovidDeaths
	WHERE location IN (SELECT location FROM Covid_Project..Population)
	)



