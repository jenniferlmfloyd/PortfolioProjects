/* 

Covid 19 Data Clean 

*/

--Verifying data imported correctly
SELECT * 
	FROM Covid_Project..CovidDeaths
	ORDER BY 2,1

SELECT * 
	FROM Covid_Project..CovidVaccinations
	ORDER BY 1,3

SELECT * 
	FROM Covid_Project..CovidHospitalizations
	ORDER BY 1,3

SELECT * 
FROM Covid_Project..Population
ORDER BY 1

--Separating the population table to sift out the actual countries and the summary continents/world that were created by OWID.
SELECT * INTO Covid_Project..PopulationOWID
FROM Covid_Project..Population
WHERE iso_code like '%OWID%'
ORDER BY 1

DELETE FROM Covid_Project..Population
WHERE iso_code like '%OWID%'

--Verifying Population tables
SELECT * 
FROM Covid_Project..Population
ORDER BY 1

SELECT * 
FROM Covid_Project..PopulationOWID

--Align column names
sp_RENAME 'Covid_Project..CovidHospitalizations.entity', 'location', 'COLUMN'
sp_RENAME 'Covid_Project..Population.entity', 'location', 'COLUMN'
sp_RENAME 'Covid_Project..PopulationOWID.entity', 'location', 'COLUMN'

