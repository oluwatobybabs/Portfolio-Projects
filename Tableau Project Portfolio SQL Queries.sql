/* Queries used for Tableau Project */

/* 1. Total Cases, Total Deaths, and Death Percentage */
SELECT 
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths::INT) AS total_deaths, 
    (SUM(new_deaths::NUMERIC) / NULLIF(SUM(new_cases), 0)) * 100 AS death_percentage
FROM public.CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1, 2;


/* 2. Locations with the Highest Death Counts (excluding continents & global groups) */
SELECT location, SUM(new_deaths::INT) AS total_death_count
FROM public.CovidDeaths
WHERE continent IS NULL 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY total_death_count DESC;


/* 3. Countries with the Highest Infection Rate Compared to Population */
SELECT location, population, 
       MAX(total_cases) AS highest_infection_count,  
       MAX((total_cases::NUMERIC / NULLIF(population, 0)) * 100) AS percent_population_infected
FROM public.CovidDeaths
GROUP BY location, population
ORDER BY percent_population_infected DESC;


/* 4. Highest Infection Count Per Date */
SELECT location, population, date, 
       MAX(total_cases) AS highest_infection_count,  
       MAX((total_cases::NUMERIC / NULLIF(population, 0)) * 100) AS percent_population_infected
FROM public.CovidDeaths
GROUP BY location, population, date
ORDER BY percent_population_infected DESC;


/* 5. Rolling People Vaccinated by Country */
SELECT dea.continent, dea.location, dea.date, dea.population, 
       MAX(vac.total_vaccinations) AS rolling_people_vaccinated
FROM public.CovidDeaths dea
JOIN public.CovidVaccinations vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
GROUP BY dea.continent, dea.location, dea.date, dea.population
ORDER BY 1, 2, 3;


/* 6. Population vs Vaccination using CTE */
WITH pop_vs_vac AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(vac.new_vaccinations::INT) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
    FROM public.CovidDeaths dea
    JOIN public.CovidVaccinations vac 
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL 
)
SELECT *, (rolling_people_vaccinated::NUMERIC / NULLIF(population, 0)) * 100 AS percent_people_vaccinated
FROM pop_vs_vac;


/* 7. Highest Infection Count Per Date (Alternative) */
SELECT location, population, date, 
       MAX(total_cases) AS highest_infection_count,  
       MAX((total_cases::NUMERIC / NULLIF(population, 0)) * 100) AS percent_population_infected
FROM public.CovidDeaths
GROUP BY location, population, date
ORDER BY percent_population_infected DESC;
