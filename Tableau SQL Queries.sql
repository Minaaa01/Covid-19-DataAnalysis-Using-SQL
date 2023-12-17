-- 1. Find Total Cases ,Total Deaths and Deaths Percentages 
-- We SET continent to not null as we want total cases in every location in the world
-- if we set it null we will get total cases in each continent and this is not acurate

Select SUM(CAST(CD.new_cases as INT)) as Total_Cases, SUM(CAST(CD.new_deaths AS INT)) AS total_deaths, SUM(cast(CD.new_deaths as int))/SUM(CD.New_Cases)*100 as DeathPercentage
From CovidDeaths CD
where CD.continent IS NOT NULL

-- 2. Find Total Deaths in eash continent
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select CD.location, SUM(cast(CD.new_deaths as int)) as TotalDeathCount
From CovidDeaths CD
Where CD.continent is NULL -- to include continent statistics only
and CD.location not in ('World', 'European Union', 'International')
Group by CD.location
order by TotalDeathCount DESC

-- 3. Find Total Infected people and The Percent of Population Infected in each location

Select CD.Location, CAST(CD.Population as INT) as Population, MAX(CAST(CD.total_cases as INT)) as Total_Infected_People,  Max((CD.total_cases/CD.population))*100 as Percent_Population_Infected
From CovidDeaths CD
where CD.continent IS NOT NULL -- To execlode continent statistics
Group by CD.Location
order by Percent_Population_Infected desc
-- 4. Find The New and total Infected People in EACH day and the percent of infected population
Select CD.Location, CD.date,CD.Population, CD.new_cases ,MAX(total_cases) as Total_Infected_People,Max((CD.total_cases/CD.population))*100 as Percent_Population_Infected_In_each_day
From CovidDeaths CD
where CD.continent IS NOT NULL
Group by CD.Location, CD.date

-- 5. Find The Countries with highest Death Count 
SELECT CD.location,Sum(CAST(CD.new_deaths as INT)) As deaths_Count,(SUM(CAST(CD.new_deaths as INT))/ CD.population )* 100 AS Death_Rate
FROM CovidDeaths CD
WHERE CD.continent is NOT NULL -- To remove continent statistics in location Column as we dont need it
GROUP By CD.location
ORDER BY deaths_Count DESC

-- 6.Find The Countries with highest infection rate compared to their population
SELECT CD.location,CAST(CD.population AS INT)AS POPULATION ,CAST(Max(CD.total_cases)AS INT) As Total_Infected_People,Max((CD.total_cases/CD.population))*100 AS Infection_Rate
FROM CovidDeaths CD
WHERE CD.continent is NOT NULL -- To remove continent statistics in location Column as we dont need it
GROUP By CD.location
ORDER BY Infection_Rate DESC

