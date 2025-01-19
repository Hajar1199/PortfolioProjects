-- Select Data that we are going to be starting with
Select location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_project.covid_deaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolio_project.covid_deaths
Where location like '%states%'
and continent is not null 
order by 1,2

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolio_project.covid_deaths
Where location like '%saudi%'
and continent is not null 
order by 3

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM portfolio_project.covid_deaths
Where location like '%saudi%'
and continent is not null 
order by 2,1

-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM portfolio_project.covid_deaths
-- Where location like '%saudi%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as decimal)) as TotalDeathCount
FROM portfolio_project.covid_deaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc;

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as decimal)) as TotalDeathCount
From portfolio_project.covid_deaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as decimal)) as total_deaths, SUM(cast(new_deaths as decimal))/SUM(New_Cases)*100 as DeathPercentage
From portfolio_project.covid_deaths
where continent is not null 
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as decimal)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From portfolio_project.covid_deaths dea
Join portfolio_project.covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as decimal)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From portfolio_project.covid_deaths dea
Join portfolio_project.covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists percent_population_vaccinated;
CREATE TABLE percent_population_vaccinated
(continent text,
location text,
date text,
population int,
new_vaccinations text,
RollingPeopleVaccinated int
);

Insert into percent_population_vaccinated
select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as double)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From portfolio_project.covid_deaths dea
Join portfolio_project.covid_vaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date;
Select *, (RollingPeopleVaccinated/Population)*100
From percent_population_vaccinated; 

-- Creating View to store data for later visualizations

create View PercentPopulationVaccinated_view as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as decimal)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From portfolio_project.covid_deaths dea
Join portfolio_project.covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;




