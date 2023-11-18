USE portfolio_project;
SELECT *
FROM portfolio_project.covid_deaths;

SELECT location, real_date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1;

-- Shows likelihood of dying from COVID in Nigeria
SELECT location, real_date, total_cases, total_deaths, round((total_deaths/total_cases)*100,3) AS death_rate
FROM covid_deaths
WHERE total_cases > total_deaths AND location = "Nigeria"
ORDER BY morbidity_rate;

-- Shows incidence rate in Africa and Ethiopia
SELECT location, real_date, total_cases, population, (total_cases/population)*100 AS incidence_rate
FROM covid_deaths
WHERE location IN ('Africa', 'Ethiopia');

-- Highest incidence rate compared to population
SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population)*100) AS incidence_rate
FROM covid_deaths
WHERE total_cases > total_deaths AND continent IS NOT NULL
GROUP BY location, population
ORDER BY incidence_rate desc;

-- Country with most death Counts
SELECT location, population, MAX(total_deaths) as highest_death_count
FROM covid_deaths
WHERE total_cases > total_deaths AND continent IS NOT NULL
GROUP BY location, population
ORDER BY highest_death_count desc;

-- Country with most death Counts
SELECT continent, MAX(total_deaths) as highest_death_count
FROM covid_deaths
WHERE total_cases > total_deaths AND continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count desc;

-- Global Numbers showing new cases and deaths per day
SELECT SUM(new_cases) AS new_cases_daily, SUM(new_deaths) AS total_deaths_daily, (SUM(new_deaths)/SUM(new_cases))*100 AS death_percent
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date;

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS death_percent
FROM covid_deaths
WHERE continent IS NOT NULL;

-- Looking at percentage of population vaccinated by Location
SELECT dea.continent, dea.location, dea.real_date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.real_date) AS total_vac_per_location
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON 	dea.location = vac.location
    AND dea.real_date = vac.real_date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.real_date;

-- Using CTEs
WITH pops_vac (continent, location, date, population, new_vaccinations, total_vac_per_population)
AS
(
SELECT dea.continent, dea.location, dea.real_date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.real_date) AS total_vac_per_location
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON 	dea.location = vac.location
    AND dea.real_date = vac.real_date
WHERE dea.continent IS NOT NULL
)
SELECT *, (total_vac_per_population/population)*100
FROM pops_vac;

-- Using Temp Table
DROP TABLE IF EXISTS percent_pop_vaccinated;
CREATE TEMPORARY TABLE percent_pop_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vac_per_location
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON 	dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
SELECT *
FROM percent_pop_vaccinated;

-- Creating Views for future visualizations
CREATE VIEW percent_pop_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vac_per_location
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON 	dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
SELECT *
FROM percent_pop_vaccinated