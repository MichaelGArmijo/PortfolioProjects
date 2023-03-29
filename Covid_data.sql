--Michael G Armijo SQL requests using Microsoft SQL Server Management Studio

--Hannah Ritchie, Edouard Mathieu, Lucas Rodés-Guirao, Cameron Appel, Charlie Giattino, 
--Esteban Ortiz-Ospina, Joe Hasell, Bobbie Macdonald, Diana Beltekian and Max Roser (2020) - "Coronavirus Pandemic (COVID-19)". 
--Published online at OurWorldInData.org. Retrieved from: 'https://ourworldindata.org/coronavirus' [Online Resource]

--Death Percentage

--This query selects the location, date, total number of cases, total number of deaths, and the death percentage. 
--The death percentage is calculated by dividing the total number of deaths by the total number of cases and multiplying the result by 100.
--The query filters the results to only include records where the location contains the word "states" and the continent is not null. It then sorts the results in ascending order by the location and date.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100
AS DeathPercentage
FROM Portfolioproject..CovidDeaths1$
WHERE location LIKE '%states%'
AND continent IS NOT null
ORDER BY 1,2;

--This SQL query selects all columns from table CovidDeaths1$, where the continent column is not null.
--ascending order by the third and fourth columns of the table. The third column contains the total number of cases fourth column contains the total number of deaths.

SELECT *
FROM Portfolioproject..CovidDeaths1$
WHERE continent IS NOT null
ORDER BY 3,4;

--This query selects each states calculated percentage of population infected. Then order by the location and the date.

SELECT location, date, total_cases, population, (total_cases/population)
*100 AS PercentPopulationInfected
FROM Portfolioproject..CovidDeaths1$
WHERE location LIKE '%states%'
ORDER BY 1,2;

--looking at countries with highest infection rate compared to population

--this query is used to retrieve information on the location, population, highest infection count, and percentage of population infected for each location
--The selected columns are location, population, the maximum total number of cases for each location as "HighestInfectionCount", and the calculated percentage of population infected.
--The calculated percentage of population infected is obtained by dividing the maximum total number of cases for each location by the population, and then multiplying by 100.


SELECT location, population, max(total_cases) AS HighestInfectionCount,
max((total_cases/population))*100 AS PercentPopulationInfected
FROM Portfolioproject..CovidDeaths1$
--where location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Showing Countries with Highest Death Count per Population
-- Creating a table for countries with the highest death count per population
-- to filter the data to only continents that are not null, sorted by descending order based on the TotalDeathCount.

SELECT location, max(cast(Total_deaths AS int)) AS TotalDeathCount
FROM Portfolioproject..CovidDeaths1$
WHERE continent IS NOT null
GROUP BY location, population
ORDER BY TotalDeathCount DESC;

--Break Down by Continent
--maximum total number of deaths for each continent

SELECT continent, max(cast(Total_deaths AS int)) AS TotalDeathCount
FROM Portfolioproject..CovidDeaths1$
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Correct Numbers

SELECT location, max(cast(Total_deaths AS int)) AS TotalDeathCount
FROM Portfolioproject..CovidDeaths1$
WHERE continent IS null
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Showing Continents with the highest death count per population

SELECT continent, max(cast(Total_deaths AS int)) AS TotalDeathCount
FROM Portfolioproject..CovidDeaths1$
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Global Numbers

SELECT  sum(new_cases) AS total_cases, sum(cast(new_deaths AS int))
AS total_deaths, sum(cast(new_deaths AS int))/sum(new_cases)*100 AS DeathPercentage
FROM Portfolioproject..CovidDeaths1$
WHERE continent IS NOT null
ORDER BY 1,2;

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations AS bigint)) over (partition BY dea.location)
FROM Portfolioproject..CovidDeaths1$ dea
JOIN Portfolioproject..CovidVaccinations1$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2,3;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition BY dea.location ORDER
BY dea.location, dea.date) AS RollingPeopleVaccinated;

FROM Portfolioproject..CovidDeaths1$ dea
JOIN Portfolioproject..CovidVaccinations1$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2,3;

--Use CTE COMMON TABLE EXPRESSION

with PopvsVac (Continent, location, date, population,
New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition BY dea.location ORDER
BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths1$ dea
JOIN Portfolioproject..CovidVaccinations1$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT null;
--order by 2,3
)
SELECT *
FROM PopvsVac

--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition BY dea.location ORDER
BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths1$ dea
JOIN Portfolioproject..CovidVaccinations1$ vac
ON dea.location = vac.location
AND dea.date = vac.date;


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visual -- This is permanent not temp table

CREATE view PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition BY dea.location ORDER
BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths1$ dea
JOIN Portfolioproject..CovidVaccinations1$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT null;
order by 2,3

SELECT  sum(new_cases) AS total_cases, sum(cast(new_deaths AS int))
AS total_deaths, sum(cast(new_deaths AS int))/sum(new_cases)*100 AS DeathPercentage
FROM Portfolioproject..CovidDeaths1$
WHERE continent IS NOT null
ORDER BY 1,2;


SELECT location, max(cast(Total_deaths AS int)) AS TotalDeathCount
FROM Portfolioproject..CovidDeaths1$
WHERE continent IS NOT null
GROUP BY location, population
ORDER BY TotalDeathCount DESC;
