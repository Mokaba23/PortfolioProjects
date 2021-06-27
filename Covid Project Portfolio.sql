SELECT *
FROM [dbo].[Covid-19 deaths]

SELECT location,date,total_cases,total_deaths,population
FROM [dbo].[Covid-19 deaths]
ORDER BY 1,2

----Total death vs total cases

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 DeathPercentage
FROM [dbo].[Covid-19 deaths]
WHERE location like '%south africa%'
ORDER BY 1,2

----Total death vs Population
SELECT location,date,total_cases,population, (total_cases/population)*100 PopulationInfectionPercentage
FROM [dbo].[Covid-19 deaths]
WHERE location like '%south africa%'
ORDER BY 1,2

------ Countries with the highest infection rate compared to population

SELECT location,population,MAX(total_cases) as HighInfection,MAX((total_cases/population))*100 as PopulationInfectionPercentage
FROM [dbo].[Covid-19 deaths]
GROUP BY location,population
ORDER BY PopulationInfectionPercentage desc

-----------Highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as DeathCount
FROM [dbo].[Covid-19 deaths]
WHERE continent is not null
GROUP BY location
ORDER BY DeathCount desc

-----------------------------------

SELECT location, MAX(cast(total_deaths as int)) as DeathCount
FROM [dbo].[Covid-19 deaths]
WHERE continent is null
GROUP BY location
ORDER BY DeathCount desc

-------------------------------------------------------------------------------------
WITH PopVsVac(Continent,Location,Date,Population,New_vaccinations,PeopleVaccinated)
as
(
SELECT cd.location,cd.continent,cd.date,cd.population,cv.new_vaccinations,
SUM(Cast(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location order by cd.date) as PeopleVaccinated
FROM [dbo].[Covid-19 deaths]  cd
JOIN [dbo].[Coronavirus_vaccine] cv
ON  cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent is not null
--ORDER BY 2,3
)

SELECT *, (PeopleVaccinated/Population)*100
FROM PopVsVac

---------------------------------------TEMP TABLE---------------------------------------------------------

CREATE TABLE PercentagePeopleVaccinated
(
Location nvarchar(255),
Continent nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into PercentagePeopleVaccinated
SELECT cd.location,cd.continent,cd.date,cd.population,cv.new_vaccinations,
SUM(Cast(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location order by cd.date) as PeopleVaccinated
FROM [dbo].[Covid-19 deaths]  cd
JOIN [dbo].[Coronavirus_vaccine] cv
ON  cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent is not null

SELECT *, (PeopleVaccinated/Population)*100
FROM PercentagePeopleVaccinated


----------------------------------------Create View
CREATE VIEW  #PercentagePeopleVaccinated
as 
SELECT cd.location,cd.continent,cd.date,cd.population,cv.new_vaccinations,
SUM(Cast(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location order by cd.date) as PeopleVaccinated
FROM [dbo].[Covid-19 deaths]  cd
JOIN [dbo].[Coronavirus_vaccine] cv
ON  cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent is not null
