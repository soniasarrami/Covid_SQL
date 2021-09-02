SELECT *
FROM portfolio_project..Deaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM portfolio_project..Vacc
--ORDER BY 3,4

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
from portfolio_project..Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--- Looking at total cases vs total deaths

--- Shows the likelihood of dying from covid in every country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolio_project..Deaths
Where location like '%iran%'
WHERE continent IS NOT NULL
ORDER BY 1,2

--- Looking at the total cases vs population
--- Shows what percentage of population have been infected with covid-19

SELECT location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
from portfolio_project..Deaths
Where location like '%iran%'
ORDER BY 1,2

--- Looking at countries with highest infection rate compared to population

SELECT location, population, Max(total_cases) as HighestInfectionCounts,  (Max(total_cases/population))*100 as PercentPopulationInfected
from portfolio_project..Deaths
Group by location, population
ORDER BY 4 Desc


-- Looking at countries with highest death rate compared to population

SELECT location, Max(cast (total_deaths as int)) as TotalDeathCount
from portfolio_project..Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 Desc


-- Looking at continents with the highest death count per population
SELECT continent , Max(cast (total_deaths as int)) as TotalDeathCount
from portfolio_project..Deaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY 2 Desc


-- Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from portfolio_project..Deaths
--Where location like '%iran%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at total population vs vaccination

SELECT Deaths.continent , Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations,
SUM(convert(int, vacc.new_vaccinations)) Over (partition by deaths.location order by deaths.location, deaths.date )
as CumulativeVaccinations,
--(CumulativeVaccinations/population)*100
FROM portfolio_project..Deaths 
JOIN portfolio_project..Vacc 
	on Deaths.location = Vacc.location
	and Deaths.date = Vacc.date
WHERE Deaths.continent is not null
order by 2 ,3


-- using a CTE

with PopvsVac (countinent, location , date, population,new_vaccinations, CumulativeVaccinations)

as
(
SELECT Deaths.continent , Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations,
SUM(convert(int, vacc.new_vaccinations)) Over (partition by deaths.location order by deaths.location, deaths.date )
as CumulativeVaccinations
--(CumulativeVaccinations/population)*100
FROM portfolio_project..Deaths 
JOIN portfolio_project..Vacc 
	on Deaths.location = Vacc.location
	and Deaths.date = Vacc.date
WHERE Deaths.continent is not null
--order by 2 ,3
)
SELECT * , (CumulativeVaccinations/population)*100 AS VaccinatedPercentage
FROM PopvsVac




-- Temp Table
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population BIGINT,
New_vaccinations BIGINT, 
CumulativeVaccinations BIGINT
)

insert into #PercentPopulationVaccinated
SELECT Deaths.continent , Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations,
SUM(CONVERT(int, vacc.new_vaccinations)) Over (partition by deaths.location order by deaths.location, deaths.date )
as CumulativeVaccinations
--(CumulativeVaccinations/population)*100
FROM portfolio_project..Deaths 
JOIN portfolio_project..Vacc 
	on Deaths.location = Vacc.location
	and Deaths.date = Vacc.date
WHERE Deaths.continent is not null
--order by 2 ,3


SELECT * , (CumulativeVaccinations/population)*100 AS VaccinatedPercentage
FROM #PercentPopulationVaccinated



-- Creating View to store data for visualizations

create view PercentPopulationVaccinated2 as
SELECT Deaths.continent , Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations,
SUM(CONVERT(int, vacc.new_vaccinations)) Over (partition by deaths.location order by deaths.location, deaths.date )
as CumulativeVaccinations
--(CumulativeVaccinations/population)*100
FROM portfolio_project..Deaths 
JOIN portfolio_project..Vacc 
	on Deaths.location = Vacc.location
	and Deaths.date = Vacc.date
WHERE Deaths.continent is not null
--order by 2 ,3



select *
from PercentPopulationVaccinated
