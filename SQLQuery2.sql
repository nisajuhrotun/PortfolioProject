-- Analayze two tables : Covid Deaths, Covid Vaccinations
Select *
From PortfolioProject. .CovidDeaths
Order By 3,4

--Select *
--From PortfolioProject. .CovidVaccinations
--Order By 3,4

-- Select the data that we're going using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject. .CovidDeaths
Order By 1,2

-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if your contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrecentage
From PortfolioProject. .CovidDeaths
--Where location like '%indo%'
Order By 1,2



-- Looking at Total Cases vs Population
-- Show what precentage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as PrecentPopulationInfected
From PortfolioProject. .CovidDeaths
Order By 1,2

-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PrecentPopulationInfected
From PortfolioProject. .CovidDeaths
-- Where location like '%indo%'
Group By location, population
Order By PrecentPopulationInfected desc


-- Showing countries with highest deaths count per-population

Select location, MAX(total_deaths) as TotalDeathsCount
From PortfolioProject. .CovidDeaths
-- Where location like '%indo%'
Group By location
Order By TotalDeathsCount desc

-- Let's break things down by continent
Select continent, MAX(CAST(total_cases as int)) as HighestInfectionCount
From PortfolioProject. .CovidDeaths
Where continent is not null
Group By continent
Order By HighestInfectionCount Desc

-- GLOBAL NUMBER

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPrecentage
From PortfolioProject. .CovidDeaths
Where continent is not null
--Group By date
Order By 1,2


-- Looking at Total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject. .CovidDeaths dea
Join PortfolioProject. .CovidVaccinations vac
    On dea.location = vac.location
	And dea.date = vac.date

-- Show precentage of population that has received at least one covid vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject. .CovidDeaths dea
Join PortfolioProject. .CovidVaccinations vac
    On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
Order By 2,3

-- USE CTE

With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject. .CovidDeaths dea
Join PortfolioProject. .CovidVaccinations vac
    On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE

DROP Table if exists #PrecentPopulationVaccinated
Create table #PrecentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PrecentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject. .CovidDeaths dea
Join PortfolioProject. .CovidVaccinations vac
    On dea.location = vac.location
	And dea.date = vac.date
-- Where dea.continent is not null
-- Order By 2,3

Select *, (RollingPeopleVaccinated/population)*100
FROM #PrecentPopulationVaccinated

-- Creating view to store data for lare visualization

Create View PrecentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject. .CovidDeaths dea
Join PortfolioProject. .CovidVaccinations vac
    On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
-- Order By 2,3