-- Verifying if the data was imported successfully

select *
from SQLDataExploration..CovidDeaths

select *
from SQLDataExploration..CovidVaccinations


select location, date, total_cases, new_cases, total_deaths, population
from SQLDataExploration..CovidDeaths
order by 1,2

-- Total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 "Death Percentage"
from SQLDataExploration..CovidDeaths
order by 1,2

-- Total cases vs total deaths country-wise

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 "Death Percentage"
from SQLDataExploration..CovidDeaths
where location='India'
order by 1,2

-- Total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 "Infection Rate"
from SQLDataExploration..CovidDeaths
where location='India'
order by 1,2

-- Countries with the highest infection rate compared to population

select location, population, max(total_cases) "Highest Infection count", 
max((total_cases/population))*100 "Infection Rate"
from SQLDataExploration..CovidDeaths
group by location, population
order by [Infection Rate] desc

-- Countries with the most deaths

select location, max(cast(total_deaths as int)) "Most Deaths"
from SQLDataExploration..CovidDeaths
where continent is not null
group by location
order by [Most Deaths] desc

-- Continents with the highest death count

select continent, max(cast(total_deaths as int)) "Most Deaths"
from SQLDataExploration..CovidDeaths
where continent is not null
group by continent
order by [Most Deaths] desc

-- Global numbers

select date, sum(new_cases) "New Cases per day",
sum(cast(new_deaths as int)) "Deaths per day",
(sum(cast(new_deaths as int))/sum(new_cases))*100 "Death Percentage"
from SQLDataExploration..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Total population vs vaccinations

-- (i) using CTE

with popvsvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
	"Rolling people vaccinated"
	from SQLDataExploration..CovidDeaths dea
	join SQLDataExploration..CovidVaccinations vac
		on dea.location = vac.location 
		and dea.date = vac.date
	where dea.continent is not null
	--order by 1,2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from popvsvac

-- (ii) using temp table

drop table if exists PercentagePopulationVaccinated

create table PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
	"Rolling people vaccinated"
	from SQLDataExploration..CovidDeaths dea
	join SQLDataExploration..CovidVaccinations vac
		on dea.location = vac.location 
		and dea.date = vac.date
	where dea.continent is not null
	--order by 1,2,3

select * 
from PercentagePopulationVaccinated