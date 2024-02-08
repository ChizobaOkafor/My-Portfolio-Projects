--COVID-19 Exploration Data
--Skills used in this project: Aggregate Functions, CTEs, Temp Tables, Views, Window Functions, Data Type Conversion, NULL constraints,etc.

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4;

--Select the data we are to be using
SELECT 
	location, 
	date,
	total_cases, 
	new_cases, 
	total_deaths,
	population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2; 

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract COVID in Nigeria
SELECT 
	location, 
	date, 
	total_cases,
	total_deaths, 
	(CAST(total_deaths AS numeric)/CAST(total_cases AS numeric))*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Nigeria'
  AND continent IS NOT NULL
ORDER BY 1,2;

--Looking at Total Cases vs Population 
--Shows what percentage of population got COVID
SELECT 
	location, date, 
	population, 
	total_cases, 
	(CAST(total_cases AS numeric)/population)*100 AS Contraction_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1,2;

--Countries with highest infection rate compared to population
SELECT 
	location, 
	population, 
	MAX(total_cases) AS Highest_Infection_Count, 
	MAX(CAST(total_cases AS numeric)/population)*100 AS Contraction_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Contraction_Percentage DESC;

--Showing countries with highest death count per population
SELECT 
	location, 
	MAX(CAST(total_deaths AS numeric)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC;

--LET'S BREAK THIS DOWN BY CONTINENT
--Showing the continent with the highest death count per population
SELECT 
	continent, 
	MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC;

--Global Numbers 
SELECT 
	SUM(new_cases) AS sum_new_cases,
	SUM(new_deaths) AS sum_death_total, 
	(SUM(new_deaths)/SUM(new_cases))*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date, total_deaths, total_cases
ORDER BY 1,2; 

SELECT *
FROM PortfolioProject..CovidVaccinations;

SELECT *
FROM PortfolioProject..CovidDeaths AS cd
JOIN PortfolioProject..CovidVaccinations AS cv
  ON cd.location = cv.location
    AND cd.date = cv.date;

--Looking at Total Population vs Vaccinations
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
SELECT 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS bigint)) OVER(PARTITION BY cd.location 
	                                              ORDER BY cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS cd
JOIN PortfolioProject..CovidVaccinations AS cv
  ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;

--Temp Table
DROP TABLE IF EXISTS #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopVaccinated
SELECT 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS bigint)) OVER(PARTITION BY cd.location 
	                                              ORDER BY cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS cd
JOIN PortfolioProject..CovidVaccinations AS cv
  ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

SELECT *
FROM PercentPopVaccinated;

--Create view for later visualization
CREATE VIEW PercentPopVac AS
SELECT cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS bigint)) OVER(PARTITION BY cd.location ORDER BY cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS cd
JOIN PortfolioProject..CovidVaccinations AS cv
  ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

SELECT *
FROM PercentPopVac;