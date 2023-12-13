select *
From PortfolioProject..CovidDeaths
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


--Total Cases vs Total Deaths in Nigeria (show the likelihood of dying if you contact covid in Nigeria)

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%Nigeria'
order by 1,2


--Total Cases vs Population (shows total population that got covid)

Select location, date, population, total_cases,(total_cases/population)*100 as PercetagePopulationInfected
From PortfolioProject..CovidDeaths
order by 1,2

--Top 20 Countries with the Highest percentage of population infected, also showing total deaths and Percentage of people in those countries that died

Select Top 20 location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercetagePopulationInfected, MAX(Cast(total_deaths as int)) as Total_death, MAX(Cast(total_deaths as int)/population)*100 as PercentageOfPopulationDeath
From PortfolioProject..CovidDeaths
Group by location, population
order by 4 Desc

--Top 20 countries with Highest death count per population

Select Top 20 location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
order by 3 Desc

-- Total Death Counts by Continents

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by 2 Desc


-- Continents with the highest death count


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by 2 Desc

-- Worldwide Numbers

--Shows the total number of cases and the death percentage across the globe
Select date, Sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths, Sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2

Select Sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths, Sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

Select*
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidDeaths Vac
	on dea.location = vac.location
	and dea.date = vac.date

--shows rolling number of people vacinatted Per Location over time
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations Vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Shows percentage of population vacinated over time
With PopvsVac (continent, location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations Vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null) 

Select *, (RollingPeopleVaccinated/Population) * 100 Pecentage_of_population_Vacinated
from PopvsVac

--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations Numeric,
RollingPeopleVaccinated Numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations Vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population) * 100 as PercentageOfPopulationVacinated
from #PercentPopulationVaccinated
Where location like 'Nigeria'

-- Creating view to store data for Data Visualisation later

DROP View if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations Vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated