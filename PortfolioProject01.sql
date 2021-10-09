SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,5

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

--Select Data that we  are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total cases vs. Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Vietnam' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total cases vs. Population
SELECT location, date,population, total_cases, (total_cases/population)*100 AS PercentTotalCasesInVietnam
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Vietnam' AND continent IS NOT NULL
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Vietnam%'
WHERE continent IS NOT NULL
Group by Location, Population
order by PercentPopulationInfected DESC

-- Countries with Highest Total Deaths

Select Location,population AS Population, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location,population
order by TotalDeathCount DESC

--Contient have Highest Total Deaths 
Select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount DESC


--Global data at 08/10/2021
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT death.continent, death.location, death.date, death.population, vaccin.new_vaccinations
, SUM(CONVERT(int,vaccin.new_vaccinations)) OVER (PARTITION BY death.Location) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vaccin
	ON death.location = vaccin.location
	AND death.date = vaccin.date
WHERE death.continent IS NOT NULL 
ORDER BY 2,3

--use CTE
WITH PopvsVac (Continent, Location, Date,Population,New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT death.continent, death.location, death.date, death.population, vaccin.new_vaccinations
, SUM(CONVERT(int,vaccin.new_vaccinations)) OVER (PARTITION BY death.Location) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vaccin
	ON death.location = vaccin.location
	AND death.date = vaccin.date
WHERE death.continent IS NOT NULL 
)
SELECT*,(RollingPeopleVaccinated/PopvsVac.Population)*100
FROM
PopvsVac

--Temp Table
CREATE TABLE #PercentPopulationVaccinated
(
	Continent NVARCHAR(255),
	Location NVARCHAR(255),
	Date DATETIME,
	Population NUMERIC,
	New_Vaccinations NUMERIC,
	RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vaccin.new_vaccinations
, SUM(CONVERT(int,vaccin.new_vaccinations)) OVER (PARTITION BY death.Location) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vaccin
	ON death.location = vaccin.location
	and death.date = vaccin.date
WHERE death.continent IS NOT NULL

SELECT*,(RollingPeopleVaccinated/Population)*100
FROM
#PercentPopulationVaccinated

--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vaccin.new_vaccinations
, SUM(CONVERT(int,vaccin.new_vaccinations)) OVER (PARTITION BY death.Location) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vaccin
	ON death.location = vaccin.location
	and death.date = vaccin.date
WHERE death.continent IS NOT NULL










