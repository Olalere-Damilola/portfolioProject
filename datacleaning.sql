select * 
from covidDeaths
where continent is not null
order by 3,4

select * 
from covidVaccinations
where continent is not null
order by 3,4

--Selecting important data

select location, date, total_cases, new_cases, total_deaths, population
from covidDeaths
where continent is not null
order by 1,2

--Exploring total cases against total deaths in Nigeria
--Shows likelihood of dying after contracting Covid

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from covidDeaths
where location = 'Nigeria' and continent is not null
order by 1,2


--Exploring total cases against population
--Shows the % of population that contract Covid

select location, date,  population, total_cases, (total_cases/population)*100 as percentOfPopulationInfected
from covidDeaths
where location = 'Nigeria' and continent is not null
order by 1,2


--Exploring countries with highest infection rate compared to population

select location, population, max(total_cases) as highestInfectionCount, (max(total_cases)/population)*100 as percentOfPopulationInfected
from covidDeaths
where continent is not null
group by location, population
order by percentOfPopulationInfected desc

--Showing Countries with Highest Death Count per Population

select location, MAX(cast(Total_deaths as int)) as totalDeathCount
from covidDeaths
where continent is not null
group by location
order by totalDeathCount desc


-- CONTINENT BREAKDOWN

select location, MAX(cast(Total_deaths as int)) as totalDeathCount
from covidDeaths
where continent is null and not location = 'World' and not location = 'High income' and not location = 'Upper middle income' and not location = 'Lower middle income' and not location = 'European Union Low income'
group by location
order by totalDeathCount desc


select continent, MAX(cast(Total_deaths as int)) as totalDeathCount
from covidDeaths
where continent is not null
group by continent
order by totalDeathCount desc

--Showing continents with the highest death count per population

select continent, MAX(cast(Total_deaths as int)) as totalDeathCount
from covidDeaths
where continent is not null
group by continent
order by totalDeathCount desc


--GLOBAL NUMBERS

select  SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as deathPercentage
from covidDeaths
where  continent is not null


--Exploring total population against Vaccinations

select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
from covidDeaths dea  join covidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with popVsVac (continent, location, date, population,new_vaccinations, rollingPeopleVaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
--,(rollingPeopleVaccinated/population)*100
from covidDeaths dea  join covidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingPeopleVaccinated/population)*100
from popVsVac


--USE TEMP

DROP TABLE if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)

insert into #percentPopulationVaccinated
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
--,(rollingPeopleVaccinated/population)*100
from covidDeaths dea  join covidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated

--Create view for visualization

create view percentPopulationVaccinated as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
--,(rollingPeopleVaccinated/population)*100
from covidDeaths dea  join covidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
