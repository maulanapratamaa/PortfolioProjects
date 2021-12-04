SELECT *
FROM PortfolioProject..CovidDeath$
where continent is not null
order by 3,4


-- Exploration Data Per Location

-- Likelihood of dying in Indonesia
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeath$
where location like '%indonesia'
ORDER BY 1,2

-- Total cases vs Population
SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
FROM PortfolioProject..CovidDeath$
where location like '%indonesia'
ORDER BY 1,2

-- check countries with highest infection rate
SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeath$
--where location like 'indonesia'
GROUP BY location,population
ORDER BY PercentagePopulationInfected desc

-- Countries with the highest deathcount per population
SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeath$
--where location like 'indonesia'
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


-- Exploration Data Per Continent

-- continent with the highest death count per population
SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeath$
--where location like 'indonesia'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Exploration Global Data
SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeath$
--where location like 'indonesia'
where continent is not null
GROUP BY date
ORDER BY 1,2


-- Join Vaccine on Location
with Pop_vs_vac(continent,location,date,population,new_vaccinations,RollingPeoplevaccinated)
as
(
SELECT d.continent,d.location,d.date, d.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) as RollingPeoplevaccinated
FROM PortfolioProject..CovidDeath$ d
JOIN PortfolioProject..CovidVaccine$ vac
on d.location = vac.location
and d.date=vac.date
WHERE d.continent is not null
--ORDER BY 2,3
)

SELECT *,(RollingPeoplevaccinated/population)*100 as PopulationVaccinated
from Pop_vs_vac

--Create View

CREATE VIEW PercentPopulationVaccinated as
SELECT d.continent,d.location,d.date, d.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) as RollingPeoplevaccinated
FROM PortfolioProject..CovidDeath$ d
JOIN PortfolioProject..CovidVaccine$ vac
on d.location = vac.location
and d.date=vac.date
WHERE d.continent is not null
--ORDER BY 2,3

SELECT *
from PercentPopulationVaccinated