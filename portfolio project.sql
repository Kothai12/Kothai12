SELECT * from covidproject..CovidDeaths
ORDER BY 3,4

SELECT * FROM covidproject..CovidVaccinations
order by 3,4

SELECT location,date,total_cases,new_cases,total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--LOOKING TOTAL CASES VS TOTAL DEATHS

SELECT location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%state%'
ORDER BY 1,2

--Looking at contries with higheszt infection compared to population

SELECT location, population, MAX(total_cases) as HighInfectioncount, MAX((total_cases/population))*100 as Percentageinfected
FROM covidproject..CovidDeaths
--WHERE location like '%state%'
GROUP BY location,population
ORDER BY  Percentageinfected desc

--Showing countries with highest death over population


SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM covidproject..CovidDeaths

--WHERE location like '%state%'
GROUP BY location,population
ORDER BY  TotalDeathCount desc 


--BREAK THINGS BY CONTINENT

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM covidproject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location like '%state%'
GROUP BY continent
ORDER BY  TotalDeathCount desc

--GLOBAL NUMBERS

SELECT date,SUM(new_cases)as Total_cases,SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as  DeathPercentage
FROM covidproject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location like '%state%'
GROUP BY date
ORDER BY  1,2

--looking at total population vs vaccinations



   SELECT dea.continent,dea.location,vac.new_vaccinations,dea.date, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location,dea.date) 
   as RollingpeopleVaccinated--,(RollingpeopleVaccinated/population)*100

 FROM covidproject..CovidDeaths dea
    JOIN covidproject..CovidVaccinations vac
  ON dea.location = vac.location    
   AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
  ORDER BY 2,3


  --USE CTE

;WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingpeopleVaccinated) AS (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location, dea.date) AS RollingpeopleVaccinated
    FROM
        covidproject..CovidDeaths dea
    JOIN
        covidproject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
		order by 2,3
)
SELECT
    continent,
    location,
    date,
    population,
    new_vaccinations,
    RollingpeopleVaccinated
FROM
    PopvsVac;


	--TEMP TABLE

	DROP TABLE IF EXISTS #PercentPopulationVaccinated


	Create table PercentPopulationVaccinated
	(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	new_vaccinations numeric,
	population numeric,
  RollingpeopleVaccinated numeric
	
	)
	INSERT INTO PercentPopulationVaccinated

	SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location, dea.date) AS RollingpeopleVaccinated
    FROM
        covidproject..CovidDeaths dea
    JOIN
        covidproject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
   WHERE dea.continent IS NOT NULL
		order by 2,3
  
  SELECT * ,(RollingpeopleVaccinated/population)*100 from PercentPopulationVaccinated


  --CREATING VIEW FOR FURTHER VISUALISATIONS

 IF OBJECT_ID(tempdb... PercentPopulationVaccinated)is not null
 drop table  PercentPopulationVaccinated
 
	Create table PercentPopulationVaccinated
	(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	new_vaccinations numeric,
	population numeric,
  RollingpeopleVaccinated numeric
	
	)
	INSERT INTO PercentPopulationVaccinated

	SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location, dea.date) AS RollingpeopleVaccinated
    FROM
        covidproject..CovidDeaths dea
    JOIN
        covidproject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
   WHERE dea.continent IS NOT NULL
		order by 2,3
  
  SELECT * ,(RollingpeopleVaccinated/population)*100 from PercentPopulationVaccinated


  Create view  PercentPopulationVaccinated as
  	SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingpeopleVaccinated--,(RollingpeopleVaccinated / population) * 100
    FROM
        covidproject..CovidDeaths dea
    JOIN
        covidproject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
   WHERE dea.continent IS NOT NULL
	--order by 2,3
	
	SELECT * FROM  PercentPopulationVaccinated
  