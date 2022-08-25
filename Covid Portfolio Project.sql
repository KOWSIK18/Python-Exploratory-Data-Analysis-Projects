/*
Covid19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
select * 
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 3,4



-- Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 1,2

-- Looking at Total cases vs Total deaths
-- shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage 
from [Portfolio Project]..CovidDeaths$
where location like '%india%' and continent is not null
order by 1,2


-- Looking at Total Cases Vs Population
-- Shows what percentage of population got covid

Select location, date, population, total_cases,  (total_cases/population)*100 as PercentpopulationInfected
from [Portfolio Project]..CovidDeaths$
--where location like '%india%'
order by 1,2



-- Looking at countries with Highest Infection rate compared to population

Select location, population, max(total_cases) as HighestInfectionCount,  max(total_cases/population)*100 as percentpopulationInfected 
from [Portfolio Project]..CovidDeaths$
--where location like '%india%'
group by location, population
order by percentpopulationInfected desc



-- Showing countries with Highest Death Count per population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths$
--where location like '%india%'
where continent is not null
group by location, population
order by TotalDeathCount desc




-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing Continents with the highest death Count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths$
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc



-- Global Numbers

Select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage  --total_deaths, (total_deaths/total_cases)*100 as Deathpercentage 
from [Portfolio Project]..CovidDeaths$
--where location like '%india%' 
where continent is not null
--group by date
order by 1,2

select * 
from [Portfolio Project]..CovidVaccinations$
order by 3,4

-- Looking at total population vs vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpepolevaccinated
--,(Rollingpepolevaccinated/population)*100
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

with popvsvac (continent, location, date, population, new_vaccinations, Rollingpepolevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpepolevaccinated
--,(Rollingpepolevaccinated/population)*100
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Rollingpepolevaccinated/population)*100 
from popvsvac





-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpepolevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpepolevaccinated
--,(Rollingpepolevaccinated/population)*100
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (Rollingpepolevaccinated/population)*100 
from #percentpopulationvaccinated




-- Creating view to store data for later visualizations

create view percentagepopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpepolevaccinated
--,(Rollingpepolevaccinated/population)*100
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from percentagepopulationvaccinated



