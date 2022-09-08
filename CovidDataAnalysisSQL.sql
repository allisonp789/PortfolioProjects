/* 

COVID-19 Project: Data Analysis with SQL

*/


SELECT *
FROM PortfolioProject..CovidDeaths


SELECT *
FROM PortfolioProject..CovidVaccinations


---------------------------------------------------------------------------------------------------------------------------------

-- Selecting data that I will be using


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT location, date, new_people_vaccinated_smoothed, people_vaccinated
FROM PortfolioProject..CovidVaccinations
ORDER BY 1, 2

---------------------------------------------------------------------------------------------------------------------------------

-- Looking at Total Cases vs. Population

-- Showing percentage of each country's population that contracted COVID over time


SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Showing percentage of United States population that contracted Covid over time


SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2


-- Showing highest infection rate compared to population per country


SELECT location
    , population, MAX(total_cases) AS HighestInfectionCount
    , MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Creating View showing percentage of population infected per country (for later visualizations)


USE PortfolioProject
GO

CREATE VIEW PercentInfected AS
SELECT location
    , population, MAX(total_cases) AS HighestInfectionCount
    , MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population


---------------------------------------------------------------------------------------------------------------------------------


-- Looking at Total Deaths

-- Showing likelihood of dying if you contract COVID in your country over time


SELECT location
    , date
    , total_cases
    , total_deaths
    , CONVERT(bigint, total_deaths) / total_cases * 100 AS PercentDeathPerInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2


-- Showing Total Deaths vs. Population per country over time


SELECT location
    , date
    , total_deaths
    , population
    , CONVERT(bigint, total_deaths)/population * 100 AS PercentPopulationDeath
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2 


-- Showing countries' highest death count per population


SELECT location
    , MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
    , MAX(CAST(total_deaths AS bigint)/population)*100 AS PercentPopulationDeath
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC


---------------------------------------------------------------------------------------------------------------------------------

-- Looking at new cases

-- Using a Subquery to show highest number of new cases and corresponding date


SELECT location, date, new_cases
FROM PortfolioProject..CovidDeaths
WHERE new_cases =
(
SELECT MAX(new_cases)
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
)


-- Using Temp Table and Join to show date when new cases reached highest number for each country
 

DROP TABLE IF EXISTS #MaxNewCases
CREATE TABLE #MaxNewCases
(
MaxNewCases BIGINT
, Location NVARCHAR(255)
)

INSERT INTO #MaxNewCases
SELECT MAX(new_cases), location
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location


SELECT CONVERT(DATE, b.date) AS Date, a.location, a.MaxNewCases
FROM #MaxNewCases AS a
LEFT JOIN PortfolioProject..CovidDeaths AS b
ON a.MaxNewCases = b.new_cases
AND a.Location = b.location
WHERE a.MaxNewCases IS NOT NULL
ORDER BY 3 DESC


---------------------------------------------------------------------------------------------------------------------------------

-- Breaking things down by continent

-- Showing percentage of each continent's population that contracted Covid


SELECT location
    , MAX(total_cases) AS TotalCases
    , population, MAX(total_cases)/population * 100 AS PercentInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL 
    AND location NOT IN ('World'
		, 'High Income' 
		, 'Upper middle income'
		, 'Lower middle income'
		, 'European Union'
		, 'Low income'
		,'International')
GROUP BY location, population
ORDER BY PercentInfected DESC


-- Showing likelihood of dying if you contract Covid for each continent


SELECT location
    , MAX(total_cases) AS TotalCases
    , MAX(CONVERT(BIGINT, total_deaths)) AS TotalDeaths
    , MAX(CONVERT(BIGINT, total_deaths))/MAX(total_cases) * 100 AS PercentDeathPerInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL 
    AND location NOT IN ('World'
		, 'High Income' 
		, 'Upper middle income'
		, 'Lower middle income'
		, 'European Union'
		, 'Low income'
		,'International')
GROUP BY location
ORDER BY PercentDeathPerInfected DESC


-- Showing continent's highest death count per population 


SELECT location
    , population
    , MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
    , MAX(CAST(total_deaths AS bigint))/population * 100 AS PercentPopulationDeath
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL 
    AND location NOT IN ('World'
		, 'High Income' 
		, 'Upper middle income'
		, 'Lower middle income'
		, 'European Union'
		, 'Low income'
		,'International')
GROUP BY location, population
ORDER BY TotalDeathCount DESC


---------------------------------------------------------------------------------------------------------------------------------

-- Breaking things down by income level

-- Showing percentage of population for each income level that contracted Covid


SELECT location
    , population
    , MAX(total_cases) AS MaxTotalCases
    , MAX(total_cases)/population * 100 AS PercentInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%income%'
GROUP BY location, population
ORDER BY PercentInfected DESC


-- Showing likelihood of dying if you contract Covid for each income level


SELECT location
    , MAX(total_cases) AS TotalCases
    , MAX(CONVERT(BIGINT, total_deaths)) AS TotalDeaths
    , MAX(CONVERT(BIGINT, total_deaths))/MAX(total_cases) * 100 AS PercentDeathPerInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%income%'
GROUP BY location
ORDER BY PercentDeathPerInfected DESC


-- Showing highest total deaths vs. total population for each income level


SELECT location
    , population
    , MAX(CONVERT(BIGINT, total_deaths)) AS TotalDeathCount
    , MAX(CONVERT(BIGINT, total_deaths))/population * 100 AS PercentPopulationDeath
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%income%'
GROUP BY location, population
ORDER BY PercentPopulationDeath DESC


---------------------------------------------------------------------------------------------------------------------------------

-- Global numbers for total cases, deaths, and death rate


SELECT SUM(new_cases) AS total_cases
    , SUM(CAST(new_deaths AS bigint)) AS total_deaths
    , SUM(CAST(new_deaths AS bigint))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


---------------------------------------------------------------------------------------------------------------------------------

-- Looking at vaccinations per country

-- Showing percentage of population vaccinated at least once for each country 


SELECT dea.location
    , dea.population
    , MAX(CAST(vac.people_vaccinated AS BIGINT)) AS PeopleVaccinated
    , MAX(CAST(vac.people_vaccinated AS BIGINT))/dea.population * 100 AS PercentVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location, dea.population
ORDER BY PercentVaccinated DESC


-- Create View showing people vaccinated per country for later visualizations


USE PortfolioProject
GO

CREATE VIEW MaxVaccinated AS 
SELECT dea.location
    , dea.population
    , MAX(CAST(vac.people_vaccinated AS BIGINT)) AS PeopleVaccinated
    , MAX(CAST(vac.people_vaccinated AS BIGINT))/dea.population * 100 AS PercentVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location, dea.population


-- Showing percentage of population that is fully vaccinated for each country


SELECT dea.location
    , dea.population
    , MAX(CAST(vac.people_fully_vaccinated AS BIGINT)) AS PeopleFullyVaccinated
    , MAX(CAST(vac.people_fully_vaccinated AS BIGINT))/dea.population * 100 AS PercentFullyVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location, dea.population
ORDER BY PercentFullyVaccinated DESC


-- Showing each country's total population vs. people vaccinated over time


SELECT dea.continent
    , dea.location
    , dea.date
    , dea.population
    , vac.new_people_vaccinated_smoothed
    , SUM(CONVERT(bigint, vac.new_people_vaccinated_smoothed)) OVER (
	PARTITION BY dea.Location ORDER BY dea.location, dea.date
        ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE to show rolling percentage of people vaccinated per country


WITH PopsvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent
    , dea.location
    , dea.date
    , dea.population
    , vac.new_people_vaccinated_smoothed
    , SUM(CONVERT(bigint, vac.new_people_vaccinated_smoothed)) OVER (
        PARTITION BY dea.Location ORDER BY dea.location, dea.date
	) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPercentVaccinated
FROM PopsvsVac
WHERE Continent IS NOT NULL 
ORDER BY Location, Date 


-- Using Temp Table to show rolling percentage of people vaccinated per country


DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255)
, Location nvarchar(255)
, Date datetime
, Population numeric 
, New_vaccinations numeric
, RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent
    , dea.location
    , dea.date
    , dea.population
    , vac.new_people_vaccinated_smoothed
    , SUM(CONVERT(bigint, vac.new_people_vaccinated_smoothed)) OVER (
        PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPercentVaccinated
FROM #PercentPopulationVaccinated
ORDER BY location, date


---------------------------------------------------------------------------------------------------------------------------------

-- Looking at Income Level and Vaccinations

-- Showing total population vs. highest number of vaccinations for each income level


SELECT dea.location
    , dea.population
    , MAX(CONVERT(BIGINT, vac.people_fully_vaccinated)) AS PeopleVaccinated
    , MAX(CONVERT(BIGINT, vac.people_fully_vaccinated))/dea.population * 100 AS PercentVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.location LIKE '%income%'
GROUP BY dea.location, dea.population
ORDER BY PercentVaccinated DESC


-- Using CTE to show rolling percentage of people vaccinated for each income level


WITH IncomePopsvsVacc AS 
(
SELECT dea.location
    , dea.date
    , dea.population
    , SUM(CONVERT(BIGINT, vac.new_people_vaccinated_smoothed)) OVER (
        PARTITION BY dea.location ORDER BY dea.location, dea.date
	) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.location LIKE '%income%'
)

SELECT *, (RollingPeopleVaccinated/population) * 100 AS RollingPercentVaccinated
FROM IncomePopsvsVacc
ORDER BY location, date




