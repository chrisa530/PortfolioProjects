SELECT * FROM CV
where continent is not null
order by 3, 4
SELECT * FROM CD


--Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CD
where continent is not null
order by 1, 2


--Looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (Total_deaths/total_cases) * 100 as [Death Percentages]
FROM CD
WHERE location like '%states%'
order by 1, 2


--looking at the Total Cases vs Population
--Shows what percentages of population got Covid
SELECT location, date, population, total_cases, (total_cases/population) * 100 as [US Case Percentages]
FROM CD
WHERE location like '%states%'
order by 1, 2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as [Highest Infection Count], Max(total_cases/population)*100 as 
[Percent Populated Infected]
FROM CD
where continent is not null
Group by location, Population
Order by [Percent Populated Infected] DESC


--Showing Countries with Highest Death COunt per Population
SELECT location, MAX(cast(total_deaths as int)) as [Total Death Count]
FROM CD
where continent is not null
Group by location
Order by [Total Death Count] DESC

--Let's Break things down by continent

SELECT location, MAX(cast(total_deaths as int)) as [Total Death Count]
FROM CD
where continent is null
Group by location
Order by [Total Death Count] DESC

Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as [Total Death Count]
FROM CD
where continent is not null
Group by continent
Order by [Total Death Count] DESC


--Global numbers

SELECT sum(new_cases) AS [Total Cases], sum(cast(new_deaths as int)) as [Total Deaths],
sum(cast(new_deaths as int))/sum(new_cases) * 100 as [Death Percentages]
FROM CD
where continent is not null
order by 1, 2

--Join both tables via locations and date columns
--Looking at Total Population vs Vaccination

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations FROM CD
Join CV ON CD.locati
on = CV.location and CD.date = CV.date
where cd.continent is not null
order by 2, 3

--Rolling count
--Cant make calculations on a column you currently making a column on. this would not work "(cd.[Rolling Count])/(cd.population)*100"
--So we needed to used a CTE

WITH popvsvacc (Continent, Location, Date, Population, New_Vaccinations, [Rolling Count])
AS
(
    SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
    SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.Location, cd.Date) AS [Rolling Count]
    FROM CD
    JOIN CV ON CD.location = CV.location AND CD.date = CV.date
    WHERE cd.continent IS NOT NULL
)
SELECT *, ([Rolling Count] / Population) * 100 AS [Rolling Percentage]
FROM popvsvacc;


--Temp Table Another way

CREATE TABLE #PERCENTPOPULATIONVACCINATED
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
[Rolling Count] numeric
)


INSERT INTO #PERCENTPOPULATIONVACCINATED
    SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
    SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.Location, cd.Date) AS [Rolling Count]
    FROM CD
    JOIN CV ON CD.location = CV.location AND CD.date = CV.date
    WHERE cd.continent IS NOT NULL


SELECT *, ([Rolling Count] / Population) * 100 AS [Rolling Percentage]
FROM #PERCENTPOPULATIONVACCINATED;

--If you make any alterations use Drop Table if exists temp_name (ex: #PERCENTPOPULATIONVACCINATED;)

--Creating View to store data for later Visualizations

Create View PercentPopulationVaccinnated as
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
    SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.Location, cd.Date) AS [Rolling Count]
    FROM CD
    JOIN CV ON CD.location = CV.location AND CD.date = CV.date
    WHERE cd.continent IS NOT NULL

