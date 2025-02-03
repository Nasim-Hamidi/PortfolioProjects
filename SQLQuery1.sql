/*
Covid 19 Data Exploration 
*/


Select * 
From PortfolioProject1..CovidVaccinations
Order By 3,4

-- Select Data that we are going to be starting with

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject1..CovidDeaths
Where continent is not null 
Order By 3,4


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where location like '%states%'
and continent is not null 
Order By 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
where location like '%states%'
and continent is not null 
Order By 1,2

-- Countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
Group by location,population
Order By PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null 
Group by location
Order By TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null 
Group by continent
Order By TotalDeathCount DESC

-- GLOBAL NUMBERS

Select SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where continent is not null 
Order By 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location
,dea.date) as RollingPeapleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
     On dea.location=vac.location
	 and dea.date=vac.date
Where dea.continent is not null 
Order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeapleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location
,dea.date) as RollingPeapleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
     On dea.location=vac.location
	 and dea.date=vac.date
Where dea.continent is not null 
)
Select *, (RollingPeapleVaccinated/population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeapleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location
,dea.date) as RollingPeapleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
     On dea.location=vac.location
	 and dea.date=vac.date
Where dea.continent is not null 
Select *, (RollingPeapleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

DROP VIEW IF EXISTS PercentPopulationVaccinated;
USE PortfolioProject1
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingPeapleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
     On dea.location=vac.location
	 and dea.date=vac.date
Where dea.continent is not null 











