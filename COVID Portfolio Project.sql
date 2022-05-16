SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases VS Total Deaths
--Shows liklihood of dying if you contract covid in your country
SELECT Location, date, total_cases,total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT Location, date,  Population, total_cases, (Total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX (total_cases) AS HighestInfectionCount, MAX ((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc


--Lets Break Down By Countinent

--Showing the Continents with the highest death count


SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--Group By date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
   WHERE dea.continent is not null
   ORDER BY 2,3


   --	USE CTE

   With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
   as
   (
   SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
   WHERE dea.continent is not null
   --ORDER BY 2,3
   )
   SELECT *, (RollingPeopleVaccinated/population)*100
   FROM PopvsVac


   -- TEMP TABLE

   DROP TABLE IF EXISTS #PercentPopulationVaccinated
   Create Table #PercentPopulationVaccinated
   (
   Continent nvarchar (255),
   Location nvarchar (255),
   Date datetime,
   Population numeric,
   New_vaccinations numeric,
   RollingPeopleVaccinated numeric
   )


   Insert into #PercentPopulationVaccinated
   SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
   WHERE dea.continent is not null
   --order by 2,3

   SELECT *, (RollingPeopleVaccinated/population)*100
   FROM #PercentPopulationVaccinated




 --Creating View to store data for later visualizations

 CREATE VIEW PercentPopulationVaccinated as 
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
   WHERE dea.continent is not null
   --ORDER BY 2,3


   SELECT *
   FROM PercentPopulationVaccinated
