--Michael G Armijo SQL requests using Microsoft SQL Server Management Studio

--Hannah Ritchie, Edouard Mathieu, Lucas Rodés-Guirao, Cameron Appel, Charlie Giattino, 
--Esteban Ortiz-Ospina, Joe Hasell, Bobbie Macdonald, Diana Beltekian and Max Roser (2020) - "Coronavirus Pandemic (COVID-19)". 
--Published online at OurWorldInData.org. Retrieved from: 'https://ourworldindata.org/coronavirus' [Online Resource]

--Death Percentage

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100
as DeathPercentage
from Portfolioproject..CovidDeaths1$
where location like '%states%'
and continent is not null
order by 1,2

select *
from Portfolioproject..CovidDeaths1$
where continent is not null
order by 3,4

select location, date, total_cases, population, (total_cases/population)
*100 as PercentPopulationInfected
from Portfolioproject..CovidDeaths1$
where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount,
max((total_cases/population))*100 as PercentPopulationInfected
from Portfolioproject..CovidDeaths1$
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

select location, max(cast(Total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths1$
--where location like '%states%'
where continent is not null
group by location, population
order by TotalDeathCount desc

--Break Down by Continent

select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths1$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Correct Numbers

select location, max(cast(Total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths1$
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

--Showing Continents with the highest death count per population

select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths1$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

select  sum(new_cases) as total_cases, sum(cast(new_deaths as int))
as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Portfolioproject..CovidDeaths1$
--where location like '%states%'and
where continent is not null
--group by date
order by 1,2

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location)
from Portfolioproject..CovidDeaths1$ dea
join Portfolioproject..CovidVaccinations1$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order
by dea.location, dea.date) as RollingPeopleVaccinated

from Portfolioproject..CovidDeaths1$ dea
join Portfolioproject..CovidVaccinations1$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

with PopvsVac (Continent, location, date, population,
New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order
by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeaths1$ dea
join Portfolioproject..CovidVaccinations1$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *
from PopvsVac

--Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order
by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeaths1$ dea
join Portfolioproject..CovidVaccinations1$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visual -- This is permanent not temp table

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order
by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeaths1$ dea
join Portfolioproject..CovidVaccinations1$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select  sum(new_cases) as total_cases, sum(cast(new_deaths as int))
as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Portfolioproject..CovidDeaths1$
--where location like '%states%'and
where continent is not null
--group by date
order by 1,2


select location, max(cast(Total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths1$
--where location like '%states%'
where continent is not null
group by location, population
order by TotalDeathCount desc
