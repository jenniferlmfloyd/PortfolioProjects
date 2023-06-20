/* 

Covid 19 Data Export for Tableau 

*/

--Total Deaths vs Population Percent Rate
SELECT dea.location, MAX(dea.total_deaths) as total_deaths, pop.population, MAX(dea.total_deaths)/pop.population *100 as total_death_rate
	FROM Covid_Project..CovidDeaths dea
	JOIN Covid_Project..Population pop
		ON dea.location = pop.location
	GROUP BY dea.location, pop.population
	ORDER BY 1 

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

--New Cases vs. Daily Vaccinations vs. ICU Occupancy vs. New Deaths
SELECT dea.date, dea.new_deaths, dea.new_cases, vacs.daily_vaccinations, dea.location, hos.value as icu_occupancy
FROM Covid_Project..CovidDeaths dea
JOIN Covid_Project..CovidVaccinations vacs ON dea.date = vacs.date AND dea.location = vacs.location
JOIN Covid_Project..CovidHospitalizations hos ON dea.date = hos.date AND dea.location = hos.location
WHERE hos.indicator = 'Daily ICU occupancy' AND dea.location IN (SELECT location FROM Covid_Project..Population) 

