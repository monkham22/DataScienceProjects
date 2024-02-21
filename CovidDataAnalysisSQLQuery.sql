SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (CONVERT(decimal(15,3), total_deaths)/CONVERT(decimal(15,3), total_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, population, total_cases,  (CONVERT(decimal(15,3), total_cases)/CONVERT(decimal(15,3), population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%myanmar%'
Where continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((CONVERT(decimal(15,3), total_cases)/CONVERT(decimal(15,3), population)))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%myanmar%'
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%myanmar%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT



-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%myanmar%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2



--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, 
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated /population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, location, date, population,New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, 
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated /population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, 
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated /population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations
USE PortfolioProject
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, 
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated /population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated

