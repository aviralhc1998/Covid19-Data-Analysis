SELECT *
From PortfolioProject.dbo.CovidDeaths$where continent is not null
order by 3,4

--SELECT *
--From PortfolioProject.dbo.CovidVaccinations$
--order by 3,4

--Select the Data we are going to be using

SELECT Location,Date,total_cases,new_cases,population
From PortfolioProject.dbo.CovidDeaths$
where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location,Date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From PortfolioProject.dbo.CovidDeaths$
Where location like 'United States' and continent is not null
order by total_cases desc

--Looking at total cases vs Population
-- Shows what percentage of population got Covid
SELECT Location,Date,total_cases,population, (total_cases/population)*100 as Percentage_population_infected
From PortfolioProject.dbo.CovidDeaths$
Where location like 'United States' and continent is not null
order by 1,2

--Looking at countires with Highest Infection rate compared to Population

SELECT Location,MAX(total_cases) as HighestInfectioncount,population, MAX((total_cases/population))*100 as Percentage_population_infected
From PortfolioProject.dbo.CovidDeaths$
where continent is not null
group by population,location
order by Percentage_population_infected desc

-- Showing countries with the Highest Death Counts per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathcount
From PortfolioProject.dbo.CovidDeaths$
where continent is not null
group by location
order by TotalDeathcount desc

-- Showing Continent with total death count

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathcount
From PortfolioProject.dbo.CovidDeaths$
where continent is not null
group by continent
order by TotalDeathcount desc

-- Global numbers
-- By each day
SELECT Date,SUM(new_cases) as Total_cases, SUM(CAST((new_deaths) as int)) as Total_deaths, (SUM(CAST((new_deaths) as int))/SUM(new_cases))*100 as Deathpercentage
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
group by date
order by 1,2

-- Total numbers till date

SELECT SUM(new_cases) as Total_cases, SUM(CAST((new_deaths) as int)) as Total_deaths, (SUM(CAST((new_deaths) as int))/SUM(new_cases))*100 as Deathpercentage
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
order by 1,2

--Looking at Total Population vs Vaccinations

Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, SUM(Convert(bigint,vaccinations.new_vaccinations)) Over (Partition by deaths.location order by deaths.location, deaths.date) as total_vaccinations
from PortfolioProject.dbo.CovidDeaths$ deaths
Join PortfolioProject.dbo.CovidVaccinations$ vaccinations
 On deaths.location = vaccinations.location and deaths.date = vaccinations.date
where deaths.continent is not null and vaccinations.new_vaccinations is not null
order by 2,3

--USINGG CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, total_vaccinations)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, SUM(Convert(bigint,vaccinations.new_vaccinations)) Over (Partition by deaths.location order by deaths.location, deaths.date) as total_vaccinations
from PortfolioProject.dbo.CovidDeaths$ deaths
Join PortfolioProject.dbo.CovidVaccinations$ vaccinations
 On deaths.location = vaccinations.location and deaths.date = vaccinations.date
where deaths.continent is not null and vaccinations.new_vaccinations is not null --and deaths.location = 'Albania'

)

Select *, (total_vaccinations/Population)*100 as Vaccination_Percentage
From PopvsVac


-- Using Temp table

Create Table #PercentVaccinat
(Continent nvarchar(255), Location nvarchar(255), Date datetime, population numeric, New_vaccinations numeric, total_vaccinations numeric)
Insert into #PercentVaccinat
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, SUM(Convert(bigint,vaccinations.new_vaccinations)) Over (Partition by deaths.location order by deaths.location, deaths.date) as total_vaccinations
from PortfolioProject.dbo.CovidDeaths$ deaths
Join PortfolioProject.dbo.CovidVaccinations$ vaccinations
 On deaths.location = vaccinations.location and deaths.date = vaccinations.date
where deaths.continent is not null and vaccinations.new_vaccinations is not null --and deaths.location = 'Albania'

Select *, (total_vaccinations/Population)*100 as Vaccination_Percentage
From #PercentVaccinat

-- Creating View to store data for late visulizations

Create View PercentVaccinat as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, SUM(Convert(bigint,vaccinations.new_vaccinations)) Over (Partition by deaths.location order by deaths.location, deaths.date) as total_vaccinations
from PortfolioProject.dbo.CovidDeaths$ deaths
Join PortfolioProject.dbo.CovidVaccinations$ vaccinations
 On deaths.location = vaccinations.location and deaths.date = vaccinations.date
where deaths.continent is not null and vaccinations.new_vaccinations is not null --and deaths.location = 'Albania'


Select*
From PercentVaccinat