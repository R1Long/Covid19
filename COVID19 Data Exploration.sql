/* Covid 19 Data Exploration on deaths and vaccinations
Data source: Our World in Data

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

/* SELECT statement for all Covid deaths data, arranged by column three and four*/
SELECT *
FROM COVID19.dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4


/* SELECT statement for all Covid vaccinations data, arranged by columns three and four*/
SELECT *
FROM COVID19.dbo.CovidVaccines
ORDER BY 3,4


/* SELECT statment for data on the European Union, filtered by specific column data */
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM COVID19.dbo.CovidDeaths
WHERE location = 'European Union'
ORDER BY 1,2


/* SELECT statement looking at Total cases vs Total Deaths - 
Useed CAST as both data sets are ints (wholenumbers) therefore will not show up as floats (int with decimal points)
Useed column name or column number for Order By 
Shows likelyhood of dying if you contract covid in your country - rough estimates
Using Round to streamline data points */
SELECT location, date, total_cases, total_deaths, Round(CAST(total_deaths AS float)/CAST(total_cases AS float)*100, 2) AS DeathPercentage
FROM COVID19.dbo.CovidDeaths
WHERE location Like 'United States'
ORDER BY location, Date


/* SELECT statement test example showing max cases and max deaths for a particular country */
SELECT Max(total_cases), MAX(total_deaths)
FROM COVID19.dbo.CovidDeaths
WHERE location = 'Afghanistan'


/* In this example, an additional calcualted column is added onto the end of this data set. 
Made use of Max, Round and Cast
For example, if you lived in Afghanistan and caught Covid, you would have a 3.55% change of dying if you caught covid. 
Caveat - not full conclusion, missing more detialed data on population age breakdown, vaccination points, number of vaccinations, co-morbidities of pop, data on unvaccinated population and their death rate ect */
SELECT location, MAX(total_cases) AS HighestCaseVolume, MAX(total_deaths) AS HighestDeathVolume, Round(CAST(Max(total_deaths) AS float)/CAST(Max(total_cases) AS float)*100, 2) AS DeathPercentage
FROM COVID19.dbo.CovidDeaths
GROUP BY location
ORDER BY location 


/* SELECT statement Looking at the Total Cases vs Total Deaths
Shows percentage of population by location that contracted Covid19 */
SELECT location, date, population, total_cases, (CAST(total_cases AS float)/CAST(population AS float))*100 AS PercentofPopulationInfected
FROM COVID19.dbo.CovidDeaths
--WHERE location Like 'United States'
ORDER BY location, Date


/* SELECT statement Looking at Countries with highest Infection Rate compared to Population
Population size, density and country location will impact % of population contracting Covid19 */
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (CAST(MAX(total_cases) AS float)/CAST(population AS float))*100 AS PercentofPopulationInfected
FROM COVID19.dbo.CovidDeaths
--WHERE location Like 'United Kingdom'
GROUP BY location, population
ORDER BY PercentofPopulationInfected DESC


/* SELECT statement showing the Countries with the Highest Death Count per Population
Removed data where NULL was in specific column */
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM COVID19.dbo.CovidDeaths
--WHERE location Like 'United Kingdom'
--WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


/* SELECT statement showing MAX total death Breakdown by continent */
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM COVID19.dbo.CovidDeaths
--WHERE location Like 'United Kingdom'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


/* Various other examples  looking at Continent/Country death data */
SELECT continent, location, MAX(total_deaths) AS TotalDeathCount
FROM COVID19.dbo.CovidDeaths
WHERE continent = 'North America' 
	AND (location = 'United States' 
	OR	location = 'Canada'
	OR location = 'Mexico'
	OR location is NULL)
GROUP BY continent, location
ORDER BY TotalDeathCount DESC

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM COVID19.dbo.CovidDeaths
WHERE location = 'North America' 
	OR (location = 'United States' 
	OR	location = 'Canada'
	OR location = 'Mexico'
	OR location is NULL)
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT location, MAX(total_deaths) AS TotalDeaths
FROM COVID19.dbo.Coviddeaths
WHERE location = 'Canada'
	OR location = 'United States'
	OR location ='Mexico'
GROUP BY location
ORDER BY location

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM COVID19.dbo.CovidDeaths
--WHERE location Like 'United Kingdom'
WHERE continent is Not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


/* SELECT statement incorporating a Subquery with WHERE statement */
SELECT DISTINCT location, MAX(population) AS Max_Pop
FROM COVID19.dbo.CovidDeaths
WHERE location IN(
	SELECT Distinct continent
	FROM COVID19.dbo.CovidDeaths
	WHERE continent is Not NULL)
GROUP BY location;


/* Creating temp tables */
CREATE TABLE #temp_contpop(
location varchar(50),
Max_Pop bigint
)


/* View data present in Temp Table */
SELECT *
FROM #temp_contpop


/* showing how to insert data into temp table with a WHERE subquery */
INSERT INTO #temp_contpop
SELECT DISTINCT location, MAX(population) AS Max_Pop
FROM COVID19.dbo.CovidDeaths
WHERE location IN(
	SELECT Distinct continent
	FROM COVID19.dbo.CovidDeaths
	WHERE continent is Not NULL)
GROUP BY location;


/* Showing how to drop tables or temp tables */
Drop table if exists #temp_continent


/* SELECT statement showing continenets with the highest death count, incorporating a subquery */
SELECT Distinct location, MAX(total_deaths) AS TotalDeathCount
FROM COVID19.dbo.CovidDeaths
WHERE location IN(
	SELECT Distinct continent
	FROM COVID19.dbo.CovidDeaths
	WHERE continent is Not NULL)
GROUP BY location
ORDER BY TotalDeathCount DESC


/* GLOBAL NUMBERS from data
Use float as standard rather than interger
Cannot sum total cases as its culmulative
Use additional AND in WHERE statement to negate calculation deviding by zero 
! means not equal to
Total daily death percentage value */
SELECT date, SUM(CAST(new_cases as float)) AS TotalCases, SUM(CAST(new_deaths as float)) AS TotalDeaths, ROUND(SUM(CAST(new_deaths as float))/Sum(CAST(new_cases as float))*100,2) AS GlobalDeathPercentage 
FROM COVID19.dbo.CovidDeaths
--WHERE location Like 'United States'
WHERE continent is NOT NULL
AND new_cases !=0
GROUP BY date
ORDER BY 1, 2


/* Reviewing total death percentage value without date breakdown */
SELECT SUM(CAST(new_cases as float)) AS TotalCases, SUM(CAST(new_deaths as float)) AS TotalDeaths, ROUND(SUM(CAST(new_deaths as float))/Sum(CAST(new_cases as float))*100,2) AS GlobalDeathPercentage 
FROM COVID19.dbo.CovidDeaths
--WHERE location Like 'United States'
WHERE continent is NOT NULL
AND new_cases !=0
ORDER BY 1, 2


/* Incorporating join tables
Looking at total population vs vaccinations
Remember depending on size of value/wholenumber = use int or bigint or smallint or tinyint ect
Alternative option - SUM(CONVERT(bigint, vaccines.new_vaccinations)) */
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations,
	SUM(CAST(vaccines.new_vaccinations as bigint)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM COVID19.dbo.CovidDeaths AS deaths
JOIN COVID19.dbo.CovidVaccines As vaccines
	ON deaths.location = vaccines.location
	AND deaths.date = vaccines.date
WHERE deaths.continent is NOT NULL
ORDER BY 2,3


/* Using a CTE to show % of population vaccinated */
WITH popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations,
	SUM(CAST(vaccines.new_vaccinations as float)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM COVID19.dbo.CovidDeaths AS deaths
JOIN COVID19.dbo.CovidVaccines As vaccines
	ON deaths.location = vaccines.location
	AND deaths.date = vaccines.date
WHERE deaths.continent is NOT NULL
--ORDER BY 2,3
)
Select * , (RollingPeopleVaccinated/population)*100 
From popvsvac


/* Using a CTE to show Max  % of population vaccinated by location */
WITH popvsvac (continent, location, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
Select deaths.continent, deaths.location , deaths.population, vaccines.new_vaccinations,
	SUM(CAST(vaccines.new_vaccinations as float)) OVER (PARTITION BY deaths.location ORDER BY deaths.location) AS RollingPeopleVaccinated
FROM COVID19.dbo.CovidDeaths AS deaths
JOIN COVID19.dbo.CovidVaccines As vaccines
	ON deaths.location = vaccines.location
	AND deaths.date = vaccines.date
WHERE deaths.continent is NOT NULL
)
Select continent, location, population, Max((RollingPeopleVaccinated/population)*100) AS PopVacc
From popvsvac
Group By  continent, location, population
ORDER BY PopVacc DESC


/* Create or drop a TEMP TABLE */
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continenet nvarchar(255), 
Location nvarchar (255),
Date datetime,
Population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations,
	SUM(CAST(vaccines.new_vaccinations as float)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM COVID19.dbo.CovidDeaths AS deaths
JOIN COVID19.dbo.CovidVaccines As vaccines
	ON deaths.location = vaccines.location
	AND deaths.date = vaccines.date
WHERE deaths.continent is NOT NULL
--ORDER BY 2,3

Select * , Round((RollingPeopleVaccinated/population)*100, 2)
From #PercentPopulationVaccinated


/* CREATING VIEW TO STORE DATA FOR LATER VISUALISATIONS */
CREATE VIEW PercentPopulationVaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations,
	SUM(CAST(vaccines.new_vaccinations as float)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM COVID19.dbo.CovidDeaths AS deaths
JOIN COVID19.dbo.CovidVaccines As vaccines
	ON deaths.location = vaccines.location
	AND deaths.date = vaccines.date
WHERE deaths.continent is NOT NULL
--ORDER BY 2,3

Select *
FROM PercentPopulationVaccinated
