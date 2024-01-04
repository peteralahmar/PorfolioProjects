SELECT *
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you test positive in your country.
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Death_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Canada'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage got covid
SELECT location, date, population, total_cases, (NULLIF(CONVERT(float, total_cases), 0)) / (CONVERT(float, population)) * 100 AS PercentofPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Canada'
and continent is not null
order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population
SELECT Location, population, Max(total_cases) as  highestInfectionCount, Max((NULLIF(CONVERT(float, total_cases), 0)) / (CONVERT(float, population))) * 100 AS PercentofPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by Location, population
order by PercentofPopulationInfected desc

-- Showing countries with the highest death count per population

SELECT Location, Max(cast(total_deaths as int)) as totalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by location
order by totalDeathCount desc

-- group them by continents

SELECT continent, Max(cast(total_deaths as int)) as totalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by continent
order by totalDeathCount desc

--Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/ Sum(NULLIF(CONVERT(float, total_cases), 0)) * 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by date
order by 1,2

--Looking at total population vs vaccinations.

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccination
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location = 'Canada'
order by 2,3

--USING CTE to calculate vaccinated per population

With PopvsVac (Continent, location,Date,Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccination
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.location = 'Canada'
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) *100 as Vaccinated_perc
From PopvsVac


--Using Temporary Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccination
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.location = 'Canada'
--order by 2,3
Select *, (RollingPeopleVaccinated/Population) *100 as Vaccinated_perc
From #PercentPopulationVaccinated

--creating view to store data for viz

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccination
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3