
select *
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4

select *
from [Portfolio Project]..CovidVaccinations
order by 3,4

select location, date,total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location like 'australia'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
from [Portfolio Project]..CovidDeaths
where location like 'australia'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths
--where location like 'australia'
group by location, population
order by 4 desc


--Showing Countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location like 'australia'
where continent is null
group by location
order by TotalDeathCount desc


--Let's Break Things Down by Continent

--Showing Continents with the Highest Death Count

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location like 'australia'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers

select date, sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
--where location like 'australia'
where  continent is not null
group by date
order by 1,2

--Looking at Total Population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
Select*, (RollingPeopleVaccinated/Population)*100
from PopvsVac





-- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3 

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating View to Store Data for later visualisations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select* 
from PercentPopulationVaccinated