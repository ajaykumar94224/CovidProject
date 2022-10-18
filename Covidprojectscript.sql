select * 
from portfolioproject..CovidDeaths
order by 3, 4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
-- Show likelihood of dying if you contract covid in Canada

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deaths_Percentage
from PortfolioProject..CovidDeaths
where location = 'Canada'
order by 1,2

-- Looking at total cases vs Population
-- Shows what percentage of people got Covid

select Location, date, population, total_cases, (total_cases/population)*100 as Covid_Percentage
from PortfolioProject..CovidDeaths
where location = 'Canada'
order by 1,2

-- Looking at highest covid cases compared to Population

select Location, population, max(total_cases) as highest_covid_cases, max((total_cases/population)*100) as Covid_Percentage
from PortfolioProject..CovidDeaths
--where location = 'Canada'
group by location, population
order by Covid_Percentage desc

-- showing countries with highest death count per population

select Location, max(cast(total_deaths as int)) as Total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by Total_death_count desc

-- Let's break this down by Continent

-- Showing continent with the highest deathcounts per population

select Location, max(cast(total_deaths as int)) as Total_death_count
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by Total_death_count desc

-- GLOBAL NUMBERS

select date, sum(cast(new_deaths as int)) as Deaths, sum(new_cases) as Cases, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_precentage
from PortfolioProject..CovidDeaths
--where location = 'Canada'
where continent is not null
group by date
order by 1,2

-- Total cases and deaths in whole world for given dataset

select sum(cast(new_deaths as int)) as Deaths, sum(new_cases) as Cases, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_precentage
from PortfolioProject..CovidDeaths
--where location = 'Canada'
where continent is not null
--group by date
order by 1,2

-- Join deaths and vaccination tables

select * 
from portfolioproject..CovidDeaths dea
join portfolioproject..covidvaccinations vac
on dea.location  = vac.location
and dea.date = vac.date

-- Looking at total vaccination vs population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from portfolioproject..CovidDeaths dea
join portfolioproject..covidvaccinations vac
on dea.location  = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from portfolioproject..CovidDeaths dea
join portfolioproject..covidvaccinations vac
on dea.location  = vac.location
and dea.date = vac.date
where dea.continent is not null)
--order by 2,3)

select *, (RollingPeopleVaccinated/population)*100 from
PopvsVac

--temp table

drop table if exists #percentpopulationvaccinated

create table #percentpopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
newvaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from portfolioproject..CovidDeaths dea
join portfolioproject..covidvaccinations vac
on dea.location  = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

select * from #percentpopulationvaccinated

create view percentpopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from portfolioproject..CovidDeaths dea
join portfolioproject..covidvaccinations vac
on dea.location  = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from percentpopulationvaccinated