select * from portproj..CovidDeaths$ order by 3,4

--select *
--from PortProj..CovidVacs$
--order by 3,4

--select *
--from PortProj..Covidall$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortProj..CovidDeaths$
order by 1,2

--looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortProj..CovidDeaths$
where location like '%state%'
order by 1,2

--looking at total cases vs population
--percent of population that contracted Covid

select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from PortProj..CovidDeaths$
where location like '%state%'
order by 1,2

--looking at countries with Highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfefctionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortProj..CovidDeaths$
--where continent is not null
group by location, population
order by PercentPopulationInfected desc

--looking at countries with highest death count per population

select location, max(cast(total_deaths as bigint)) as TotalDeathCount
from PortProj..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

--break down by continent


-- showing continents with highest death count per population

select continent, max(cast(total_deaths as bigint)) as TotalDeathCount
from PortProj..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc


--Global numbers

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as bigint)) as TotalDeaths, sum(cast(new_deaths as bigint))/sum(new_cases)*100 as DeathPercentage
from PortProj..CovidDeaths$
where continent is not null
group by date
order by 1,2

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as OngoingVaccinationCount
from PortProj..CovidDeaths$ dea
join PortProj..CovidVacs$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE (number of columns has to match number of columns in CTE)

with popvsvac (continent, location, date, population, new_vaccinations, OngoingVaccinationCount)
as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as OngoingVaccinationCount
from PortProj..CovidDeaths$ dea
join PortProj..CovidVacs$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (OngoingVaccinationCount/population)*100 as OngoingVaccinationPercent
from popvsvac


--Temp Table

drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_Vaccinations numeric,
OngoingVaccinationCount numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as OngoingVaccinationCount
from PortProj..CovidDeaths$ dea
join PortProj..CovidVacs$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (OngoingVaccinationCount/population)*100 as OngoingVaccinationPercent
from #PercentPopulationVaccinated


--creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as OngoingVaccinationCount
from PortProj..CovidDeaths$ dea
join PortProj..CovidVacs$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated