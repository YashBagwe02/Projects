SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [Portfolio Project]..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

--look at total cases vs population
SELECT location,date,total_cases,Population,(total_cases/population)*100 AS PopulationInfectedPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is NOT NULL
AND location like '%India%'
ORDER BY 1,2
/* Observation: It basically shows the amount of population of Inida infected with covid in percentage*/

--Countries with Highest Infected rates
SELECT location,population,MAX(total_cases) as HighestInfectedCount,MAX((total_cases/population))*100 AS PopulationInfectedPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%India%'
WHERE continent is  not NULL
GROUP BY location,population
ORDER BY PopulationInfectedPercentage DESC
/*Observation:It shows what percent of the Country's population has got covid or was infected by covid*/


--Total Death Counts by location
SELECT location,MAX(total_deaths) as DeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%India%'
WHERE continent is NULL
GROUP BY location
ORDER BY DeathCount DESC


--Exploring based on continents
--total cases vs population based on continents
SELECT continent,date,total_cases,Population,(total_cases/population)*100 AS PopulationInfectedPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is NOT NULL
--AND location like '%India%'
ORDER BY 1,2

--showing continents with highest death counts
SELECT continent,MAX(total_deaths) as DeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%India%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY DeathCount DESC

----Global numbers
--SELECT date,Sum(new_cases) as total_cases,SUM(new_deaths) as total_deaths,SUM(cast(new_deaths as int))/SUM(cast(new_cases as int)) as DeathPercentage
--FROM [Portfolio Project]..CovidDeaths
----WHERE location like '%India%'
--WHERE continent is  not NULL
--GROUP BY date
--ORDER BY 1,2 DESC

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(bigint,new_vaccinations) )over (Partition by dea.location ORDER BY dea.location, dea.Date) as PeoplevaccinatedTillDate
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
order by 2,3	

--USING CTE TO PERFORM CALCULATION WITH PeopleVaccinatedTillDate

WITH PopuVsVacc(Continent,Location,Date,Population,New_vaccinations,PeopleVaccinatedTillDate)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(bigint,new_vaccinations) )over (Partition by dea.location ORDER BY dea.location, dea.Date) as PeoplevaccinatedTillDate
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT * ,(PeopleVaccinatedTillDate/Population)*100
FROM PopuVsVacc
/* Observation: It shows the Total People Vaccinated per day and Vaccinated till the date and
the last column compares vaccinated people with population to calculate the percent of population vaccinated*/

--Using TEMP TABLES TO PERFORM THE SAME PREVIOUYS PROBLEM
DROP Table if exists #PercentVaccinatedPeople
Create Table #PercentVaccinatedPeople
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinatedTillDate numeric
)

Insert into #PercentVaccinatedPeople
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(bigint,new_vaccinations) )over (Partition by dea.location ORDER BY dea.location, dea.Date) as PeoplevaccinatedTillDate
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
--order by 2,3
Select*,(PeopleVaccinatedTillDate/Population)*100
FROM #PercentVaccinatedPeople

-- Creating a view
CREATE VIEW PercentVaccinatedPeople as 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(bigint,new_vaccinations) )over (Partition by dea.location ORDER BY dea.location, dea.Date) as PeoplevaccinatedTillDate
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null