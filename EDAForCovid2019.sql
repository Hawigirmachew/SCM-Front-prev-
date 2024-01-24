select * 
from dbo.CovidDeaths$
--WHERE location = 'Ethiopia'
ORDER BY 1,2

--total cases vs total death
SELECT  location, population, (total_deaths/total_cases) * 100 as DeathPercentage
from dbo.CovidDeaths$

--total cases vs population
SELECT location, population, total_cases, (total_cases / population ) * 100 as InfectedPop
FROM dbo.CovidDeaths$
order by InfectedPop desc

--countries with highest infection rate compared to population
SELECT continent,  MAX(CAST(total_cases as int)) as TotalDeaths,MAX(CAST(total_cases as int) / population ) * 100 as InfectedPop
FROM dbo.CovidDeaths$
WHERE continent is not null
GROUP BY continent
order by InfectedPop desc

select * 
from dbo.CovidDeaths$
--WHERE location = 'Ethiopia'
ORDER BY 1,2

--total cases vs total death
SELECT  location, population, (total_deaths/total_cases) * 100 as DeathPercentage
from dbo.CovidDeaths$

--total cases vs population
SELECT location, population, total_cases, (total_cases / population ) * 100 as InfectedPop
FROM dbo.CovidDeaths$
order by InfectedPop desc

--countries with highest infection rate compared to population
SELECT continent,  MAX(CAST(total_cases as int)) as TotalDeaths,MAX(CAST(total_cases as int) / population ) * 100 as InfectedPop
FROM dbo.CovidDeaths$
WHERE continent is not null
GROUP BY continent
order by InfectedPop desc

-- information of total new cases and total new deaths per day as well as the the percentage of death
SELECT  date, SUM(new_cases) as Total_new_cases, SUM(CAST(new_deaths as int)) as Total_new_deaths, ( SUM(CAST(new_deaths as int))/SUM(new_cases)) * 100 as DeathPercentage
from dbo.CovidDeaths$
where continent is not null
group by date
order by date desc

-- total values
SELECT   SUM(new_cases) as Total_new_cases, SUM(CAST(new_deaths as int)) as Total_new_deaths, ( SUM(CAST(new_deaths as int))/SUM(new_cases)) * 100 as DeathPercentage
from dbo.CovidDeaths$
where continent is not null
order by 1, 2


--joining the 2 tables
select cd.continent, cd.location, cd.date, cv.new_vaccinations, cd.population
from dbo.CovidDeaths$ as cd
join dbo.CovidVaccinations$ as cv
  on cv.location = cd.location 
  and cv.date = cd.date
where cd.continent is not null
order by 1,2,3

--CTE

WITH PopvsVac (Continent, Location, Date, New_vacination, Population, PopulationVaccinated)
as(
select cd.continent, cd.location, cd.date, cv.new_vaccinations, cd.population,
SUM(CAST(cv.new_vaccinations as int)) OVER (Partition by cd.location ORDER by cd.location, cd.date) as PopulationVaccinated
from dbo.CovidDeaths$ as cd
join dbo.CovidVaccinations$ as cv
  on cv.location = cd.location 
  and cv.date = cd.date
where cd.continent is not null and cv.new_vaccinations is not null
)

Select *, (PopulationVaccinated/Population) * 100 as PercentageOfPopVaccinated
from PopvsVac
--order by 3

--Temp Table

DROP table if exists #PercentagePopVaccinated
Create Table #PercentagePopVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
New_vaccinations numeric,
Population numeric,
PopVaccinated numeric
)

Insert into #PercentagePopVaccinated
select cd.continent, cd.location, cd.date, cv.new_vaccinations, cd.population,
SUM(CAST(cv.new_vaccinations as int)) OVER (Partition by cd.location ORDER by cd.location, cd.date) as PopulationVaccinated
from dbo.CovidDeaths$ as cd
join dbo.CovidVaccinations$ as cv
  on cv.location = cd.location 
  and cv.date = cd.date
where cd.continent is not null and cv.new_vaccinations is not null

Select *, (PopVaccinated/Population) * 100 as PercentageOfPopVaccinated
from #PercentagePopVaccinated
--order by 3


--view
Create View  PercentagePopVaccinated as 
select cd.continent, cd.location, cd.date, cv.new_vaccinations, cd.population,
SUM(CAST(cv.new_vaccinations as int)) OVER (Partition by cd.location ORDER by cd.location, cd.date) as PopulationVaccinated
from dbo.CovidDeaths$ as cd
join dbo.CovidVaccinations$ as cv
  on cv.location = cd.location 
  and cv.date = cd.date
where cd.continent is not null and cv.new_vaccinations is not null
