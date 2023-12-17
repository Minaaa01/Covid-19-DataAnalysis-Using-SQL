/*

Covid 19 Data Exploration 

Skills used: Joins, CTE's, Aggregate Functions, Creating Views, Converting Data Types, Create Tables

*/
-- EXPLORING THE DATA WE ARE GOING TO USE
	SELECT *
	FROM CovidDeaths CD
	ORDER BY CD.location

	SELECT *
	FROM CovidVaccinations CV
	ORDER BY CV.location
-- Selecting Data that we are going to use 
	SELECT CD.location,CD.date,CD.total_cases,CD.new_cases,CD.total_deaths,CD.new_deaths,CD.population
	FROM CovidDeaths CD
	WHERE CD.continent is NOT NULL -- To remove continent statistics in location Column as we dont need it
	ORDER BY CD.location
-- Analysing Total Cases Vs Total Deaths "Cumulatively"
	SELECT CD.location,CD.date,CD.total_cases,CD.total_deaths
	FROM CovidDeaths CD
	WHERE CD.continent is NOT NULL -- To remove continent statistics in location Column as we dont need it
	ORDER BY CD.location
-- Analysing Total Cases Vs Total Deaths in Egypt
	SELECT CD.location,CD.date,CD.total_cases,CD.total_deaths , (CD.new_deaths/CD.new_cases)*100 AS Death_Rate_Per_Day
	FROM CovidDeaths CD
	WHERE location = "Egypt" and CD.continent is NOT NULL -- To remove continent statistics in location Column as we dont need it
	ORDER BY CD.date DESC
-- Analysing Total Cases Vs Population To show the infection rate "Cumulatively"
	SELECT CD.location,CD.date,CD.population,CD.total_cases,(CD.total_cases/CD.population)*100 AS Infection_Rate
	FROM CovidDeaths CD
	WHERE CD.continent is NOT NULL -- To remove continent statistics in location Column as we dont need it
	ORDER BY CD.location

	SELECT CD.location,CD.date,CD.population,CD.total_cases,(CD.total_cases/CD.population)*100 AS Infection_Rate
	FROM CovidDeaths CD
	WHERE location = "Egypt"
	ORDER BY location
-- Find The Countries with highest infection rate compared to their population
	SELECT CD.location,CD.population,Max(CD.total_cases) As Highest_Infection,Max((CD.total_cases/CD.population))*100 AS Highest_Infection_Rate
	FROM CovidDeaths CD
	WHERE CD.continent is NOT NULL -- To remove continent statistics in location Column as we dont need it
	GROUP By CD.location
	ORDER BY Highest_Infection_Rate DESC
-- Find The Countries with highest Death Count 
	SELECT CD.location,Max(CAST(CD.total_deaths as INT)) As Highest_deaths_Count,Max((CD.total_deaths/CD.population))*100 AS Highest_Death_Rate
	FROM CovidDeaths CD
	WHERE CD.continent is NOT NULL -- To remove continent statistics in location Column as we dont need it
	GROUP By CD.location
	ORDER BY Highest_deaths_Count DESC
-- Find The Continent with highest Death Count 
	SELECT CD.location,Max(CAST(CD.total_deaths as INT)) As Highest_deaths_Count,Max((CD.total_deaths/CD.population))*100 AS Highest_Death_Rate
	FROM CovidDeaths CD
	WHERE CD.continent is NULL -- Continent names in location Column with null value tell us that is the whole continent 
	GROUP By CD.location
	ORDER BY Highest_deaths_Count DESC

	SELECT CD.continent,Max(CAST(CD.total_deaths as INT)) As Highest_deaths_Count,Max((CD.total_deaths/CD.population))*100 AS Highest_Death_Rate
	FROM CovidDeaths CD
	WHERE CD.continent is NOT NULL -- Continent names in Continent Column with Not null value tell us that is the whole continent 
	GROUP By CD.continent
	ORDER BY Highest_deaths_Count DESC
-- Analysis Some Global Number 
	-- Find Total Cases and total deaths in the whole world
			SELECT SUM(CD.total_cases) AS Total_CasesCAST(SUM(CD.new_cases) as INT) AS Total_Cases,CAST(SUM(CD.new_deaths) as INT) AS Total_Deaths 
			FROM CovidDeaths CD 
			WHERE CD.continent is NULL 
	-- Find Total Cases and total deaths in the Each continent
			SELECT CD.location,SUM(CD.total_cases) AS Total_CasesCAST(SUM(CD.new_cases) as INT) AS Total_Cases,CAST(SUM(CD.new_deaths) as INT) AS Total_Deaths
			FROM CovidDeaths CD 
			WHERE CD.continent is NULL 
			GROUP BY CD.location
			ORDER BY Total_Cases DESC
	-- Find Total Cases and total deaths in the Each Location
			SELECT CD.location,CAST(SUM(CD.new_cases) as INT) AS Total_Cases,CAST(SUM(CD.new_deaths) as INT) AS Total_Deaths 
			FROM CovidDeaths CD 
			WHERE CD.continent is Not NULL -- To Remove continent statictics
			GROUP BY CD.location
			ORDER BY Total_Cases DESC
-- JOINING OUR TWO TABLES 
	SELECT *
	FROM CovidDeaths CD INNER JOIN CovidVaccinations CV
	ON CD.location=CV.location AND CD.date =CV.date

	/*
	SELECT *
	FROM CovidDeaths CD,CovidVaccinations CV
	WHERE CD.location=CV.location AND CD.date =CV.date -- INNER JOIN

	SELECT *
	FROM CovidDeaths CD JOIN CovidVaccinations CV
	ON CD.location=CV.location AND CD.date =CV.date -- INNER JOIN
	*/
-- Find The TOTAL VACCINATION VS TOTAL POPULATION IN EACH continent
	SELECT CD.location,CD.date,CD.population,CV.new_vaccinations
	FROM CovidDeaths CD INNER JOIN CovidVaccinations CV
	ON CD.location=CV.location AND CD.date =CV.date 
	WHERE  CD.continent IS NULL
-- Find The TOTAL VACCINATION VS TOTAL POPULATION IN EACH LOCATION Per each day
	SELECT CD.continent, CD.location,CD.date,CD.population,CV.new_vaccinations
	FROM CovidDeaths CD INNER JOIN CovidVaccinations CV
	ON CD.location=CV.location AND CD.date =CV.date 
	WHERE  CD.continent IS NOT NULL
-- Analysis The Total Vaccinated People FOLLOWING each day
	SELECT CD.continent, CD.location,CD.date,CD.population,CV.new_vaccinations ,SUM(CAST(CV.new_vaccinations AS INT)) OVER (PARTITION by CD.location ORDER BY CD.date) AS Rolling_Vaccination_of_People
	FROM CovidDeaths CD INNER JOIN CovidVaccinations CV
	ON CD.location=CV.location AND CD.date =CV.date 
	WHERE  CD.continent IS NOT NULL
-- Find Vaccinated People rate in each location
	with Vaccrate( Continent,Location,Date,population,New_vaccinations,Rolling_Vaccination_of_People)
	as
	(
	SELECT CD.continent, CD.location, CD.date,CD.population,CV.new_vaccinations ,SUM(CAST(CV.new_vaccinations AS INT)) OVER (PARTITION by CD.location ORDER BY CD.date) AS Rolling_Vaccination_of_People
	FROM CovidDeaths CD INNER JOIN CovidVaccinations CV
	ON CD.location=CV.location AND CD.date = CV.date
	WHERE  CD.continent IS NOT NULL
	)
	SELECT *,(Rolling_Vaccination_of_People/population) *100 as Vaccination_rate
	FROM Vaccrate
--Create tabel for vaccinated location
	DROP Table if exists VacInEachLoc
	Create Table VacInEachLoc
	(
	Location nvarchar(255),
	Datee datetime,
	Population REAL,
	New_vaccinations REAL,
	RollingPeopleVaccinated REAL
	)
	Insert into VacInEachLoc
	Select CD.location, CD.date, CD.population, CV.new_vaccinations
	, SUM(CAST(CV.new_vaccinations AS INT)) OVER (PARTITION by CD.location ORDER BY CD.date)
	FROM CovidDeaths CD INNER JOIN CovidVaccinations CV
	ON CD.location=CV.location AND CD.date = CV.date
	WHERE  CD.continent IS NOT NULL

	Select *, (RollingPeopleVaccinated/Population)*100 as Vaccinated_Rate
	From VacInEachLoc
-- Create Views to store data for later visualizations

	Create View Vaccinated_People_In_Each_Continated
	As 
	Select CD.location, CD.population, SUM(CV.total_vaccinations) As Total_Vaccinated_People
	FROM CovidDeaths CD INNER JOIN CovidVaccinations CV
	ON CD.location=CV.location AND CD.date = CV.date
	WHERE  CD.Continent IS NULL
	GROUP by CV.location

	Create View Vaccinated_People_In_Each_Location
	As 
	Select CD.location, CD.population, SUM(CV.total_vaccinations) As Total_Vaccinated_People
	FROM CovidDeaths CD INNER JOIN CovidVaccinations CV
	ON CD.location=CV.location AND CD.date = CV.date
	WHERE  CD.Continent IS Not NULL
	GROUP by CV.location
