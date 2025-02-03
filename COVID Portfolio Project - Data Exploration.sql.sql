-- COVID-19 project, Data Exploration---
-- will explore this massive amount of data and go through some of these numbers.

-- Let's take a quick glimpse at the data ---- 
Select *
From portfolio_project.covid_deaths
Where continent is not null 
order by 4;

-- the date column need to be converted in covid_deaths and covid_vaccinations tables---------
Select `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM portfolio_project.covid_deaths;

Update portfolio_project.covid_deaths
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

Select date, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM portfolio_project.covid_vaccinations;

Update portfolio_project.covid_vaccinations
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');


-- let's focus on the columns that will give us more info about this data---- 
Select location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_project.covid_deaths
Where continent is not null 
order by 2 desc;

-- Total Cases vs Total Deaths
-- Shows the Percentage of covid deaths in Saudi Arabia in 2020---------------
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolio_project.covid_deaths
Where location like '%Saudi%'
and `date` like '%2020%'
and continent is not null 
order by 2;

-- Total Cases vs Total Deaths (worldwide in 2020)---------------
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolio_project.covid_deaths
where `date` like '%2020%'
and continent is not null 
order by 2;

-- order by the total_cases column --------
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolio_project.covid_deaths
where continent is not null 
order by 3;

-- Total Cases vs Population-------------------------------------
-- Shows what percentage of population infected with Covid in Saudi--- 
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM portfolio_project.covid_deaths
Where location like '%saudi%'
and continent is not null 
order by 2,1;

-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM portfolio_project.covid_deaths
Group by Location, Population
order by PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population------
Select Location, MAX(CONVERT(total_deaths, UNSIGNED)) as TotalDeathCount
FROM portfolio_project.covid_deaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc;

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population-------------------
Select continent, MAX(CONVERT(total_deaths, UNSIGNED)) as TotalDeathCount
From portfolio_project.covid_deaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS-----------------------------
Select SUM(new_cases) as total_cases, SUM(convert(new_deaths, UNSIGNED)) as total_deaths, SUM(convert(new_deaths, UNSIGNED))/SUM(New_Cases)*100 as DeathPercentage
From portfolio_project.covid_deaths
where continent is not null 
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine--------------------------
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as UNSIGNED)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From portfolio_project.covid_deaths dea
Join portfolio_project.covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

-- change the data type from text to int for the new_vaccinations column ------
Update portfolio_project.covid_vaccinations
SET new_vaccinations = new_vaccinations + 0;

-- Using CTE to perform Calculation on Partition By in previous query---------------------------------------------------------
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
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
(`continent` text,
`location` text,
`date` date,
`population` int,
`new_vaccinations` int,
`RollingPeopleVaccinated` int
);
Insert into percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From portfolio_project.covid_deaths dea
Join portfolio_project.covid_vaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date;
Select *, (RollingPeopleVaccinated/Population)*100
From percent_population_vaccinated; 

-- Creating View to store data for later visualizations
drop view if exists PercentPopulationVaccinated_view;
create View PercentPopulationVaccinated_view as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From portfolio_project.covid_deaths dea
Join portfolio_project.covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;
