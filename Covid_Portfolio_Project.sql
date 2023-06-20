SELECT *   
FROM PortfolioProject.dbo.CovidDeaths   
WHERE continent is NOT NULL   
ORDER BY 3,4   
  

--SELECT *   
--FROM PortfolioProject.dbo.CovidVaccinations   
--WHERE continent is NOT NULL   
--ORDER BY 3,4   
  

SELECT Location, date, total_cases, new_cases, total_deaths, population   
FROM PortfolioProject.dbo.CovidDeaths   
WHERE continent is NOT NULL   
ORDER BY 1,2   


-- Looking at Total Cases vs Total Deaths   
-- Shows likelihood of dying if you contract covid in your country   
 
SELECT Location, date, total_cases, total_deaths, (cast(total_deaths as int)/total_cases)*100 AS DeathPercentage 
FROM PortfolioProject.dbo.CovidDeaths   
WHERE location like '%states%'   
AND continent is NOT NULL   
ORDER BY 1,2   


-- Looking at Total Cases vs Population   
-- Shows what percentage of population got Covid   

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected   
FROM PortfolioProject.dbo.CovidDeaths   
WHERE location like '%states%'   
AND continent is NOT NULL   
ORDER BY 1,2 


-- Looking at countries with highest infection rate compared to population   

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected   
FROM PortfolioProject.dbo.CovidDeaths   
--WHERE location like '%states%'  
WHERE continent is NOT NULL   
GROUP BY Location, population   
ORDER BY PercentPopulationInfected desc   


-- Showing Countries with Highest Death Count per Population   

SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount   
FROM PortfolioProject.dbo.CovidDeaths   
--WHERE location like '%states%'  
WHERE continent is NOT NULL   
GROUP BY Location   
ORDER BY TotalDeathCount desc   

 
-- LET'S BREAK THINGS DOWN BY CONTINENT  
-- Showing continets with the highest death count per population 

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount   
FROM PortfolioProject.dbo.CovidDeaths  
--WHERE location like '%states%'  
WHERE continent is NOT NULL   
GROUP BY continent   
ORDER BY TotalDeathCount desc   

 
-- GLOBAL NUMBERS 

SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(nullif(new_cases,0))*100 AS DeathPercentage 
FROM PortfolioProject.dbo.CovidDeaths   
--WHERE location like '%states%'   
WHERE continent is NOT NULL  
GROUP BY date 
ORDER BY 1,2 


SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(nullif(new_cases,0))*100 AS DeathPercentage 
FROM PortfolioProject.dbo.CovidDeaths   
--WHERE location like '%states%'   
WHERE continent is NOT NULL  
--GROUP BY date 
ORDER BY 1,2 


-- Looking at Total Population vs Vaccination 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingCountVaccinated 
FROM PortfolioProject.dbo.CovidDeaths dea 
	JOIN PortfolioProject.dbo.CovidVaccinations vac 
	ON dea.location = vac.location 
AND dea.date = vac.date 
WHERE dea.continent is NOT NULL  
ORDER BY 2,3 

  


-- USE CTE 

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingCountVaccinated) 
AS 
( 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingCountVaccinated 
FROM PortfolioProject.dbo.CovidDeaths dea 
JOIN PortfolioProject.dbo.CovidVaccinations vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is NOT NULL  
) 
SELECT *, (RollingCountVaccinated/population)* 100 As VaccinationRollingPercentage 
FROM PopvsVac 

 
-- USE TEMP TABLE 

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime null,
Population numeric,
New_vaccinations Numeric,
RollingCountVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingCountVaccinated 
FROM PortfolioProject.dbo.CovidDeaths dea 
JOIN PortfolioProject.dbo.CovidVaccinations vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is NOT NULL  
--ORDER BY 2,3 

SELECT *, (RollingCountVaccinated/population)* 100 As VaccinationRollingPercentage 
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingCountVaccinated 
FROM PortfolioProject.dbo.CovidDeaths dea 
JOIN PortfolioProject.dbo.CovidVaccinations vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is NOT NULL  
--ORDER BY 2,3 


CREATE VIEW TotalDeathCountPerContinent AS
SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount   
FROM PortfolioProject.dbo.CovidDeaths  
--WHERE location like '%states%'  
WHERE continent is NOT NULL   
GROUP BY continent   
--ORDER BY TotalDeathCount desc     