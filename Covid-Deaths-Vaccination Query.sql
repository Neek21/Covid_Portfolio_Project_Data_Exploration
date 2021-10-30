--Data from https://ourworldindata.org/covid-deaths

SELECT *
FROM PortfolioProject..CovidDeaths
Where Continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where Continent is not null
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelyhood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' and Continent is not null
ORDER BY 1,2


--Looking at total cases vs Population
SELECT Location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentageInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' and Continent is not null
ORDER BY 1,2


--Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationPercentageInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where Continent is not null
GROUP BY Location, Population
ORDER BY PopulationPercentageInfected desc

--Showing countries with highest death count per population
SELECT Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where Continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT

--SELECT location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
--FROM PortfolioProject..CovidDeaths
----WHERE location like '%states%'
--Where Continent is null
--GROUP BY location
--ORDER BY TotalDeathCount desc


--Showing continents with the highest death count per population

SELECT continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where Continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc




--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as SumNewCasesPerDay, SUM(cast(new_deaths as int)) as SumNewDeathsPerDay, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%' and 
WHERE Continent is not null
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) as AllCasesInTheWorld, SUM(cast(new_deaths as int)) as AllDeathsInTheWorld, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%' and 
WHERE Continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at total population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--Can also use SUM(CONVERT(int,vac.new_vaccinations))


--USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccination, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE

DROP Table if exists #PercentpopulationVaccinated
CREATE TABLE #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentpopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentpopulationVaccinated

--Creating View to store data for later visuallizations

Create View PercentpopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

Create View TotalDeathCount as
SELECT Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where Continent is not null
GROUP BY Location