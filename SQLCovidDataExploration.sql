/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[total_tests]
      ,[new_tests]
      ,[total_tests_per_thousand]
      ,[new_tests_per_thousand]
      ,[new_tests_smoothed]
      ,[new_tests_smoothed_per_thousand]
      ,[positive_rate]
      ,[tests_per_case]
      ,[tests_units]
      ,[total_vaccinations]
      ,[people_vaccinated]
      ,[people_fully_vaccinated]
      ,[total_boosters]
      ,[new_vaccinations]
      ,[new_vaccinations_smoothed]
      ,[total_vaccinations_per_hundred]
      ,[people_vaccinated_per_hundred]
      ,[people_fully_vaccinated_per_hundred]
      ,[total_boosters_per_hundred]
      ,[new_vaccinations_smoothed_per_million]
      ,[new_people_vaccinated_smoothed]
      ,[new_people_vaccinated_smoothed_per_hundred]
      ,[stringency_index]
      ,[population_density]
      ,[median_age]
      ,[aged_65_older]
      ,[aged_70_older]
      ,[gdp_per_capita]
      ,[extreme_poverty]
      ,[cardiovasc_death_rate]
      ,[diabetes_prevalence]
      ,[female_smokers]
      ,[male_smokers]
      ,[handwashing_facilities]
      ,[hospital_beds_per_thousand]
      ,[life_expectancy]
      ,[human_development_index]
      ,[excess_mortality_cumulative_absolute]
      ,[excess_mortality_cumulative]
      ,[excess_mortality]
      ,[excess_mortality_cumulative_per_million]
  FROM [project].[dbo].[covidVaccinations$]

   select * from coviddeaths$ order by 3,4;

  select * from covidVaccinations$;

  select location,total_cases,new_cases,total_deaths, population,date from coviddeaths$;

  -- Total Cases vs Total Deaths
  select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100
  as percentage_deaths from coviddeaths$ 
  order by 1,2 ;
 
 -- Total Cases vs Total Deaths in the UK
  select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100
  as percentage_deaths 
  from coviddeaths$ 
  where location like '%kingdom%'
  order by 1,2 ;

  --Total deaths vs Population in the UK
  select location,date,total_deaths,population, (total_deaths/population)*100
  as percentage_deaths_per_population 
  from coviddeaths$ 
  where location like '%kingdom%'
  order by 1,2 ;

  --Countries with the highest infection rate
  select location, max(total_cases) as highestinfectioncount,population, max(total_cases/population)*100
  as percentage_infection_per_population 
  from coviddeaths$ 
  group by location,population
  order by 4 desc ;

  -- Countries with the highest death rate
  select location, max(cast (total_deaths as int)) as highestdeathcount,population, max((cast(total_deaths as int))/population)*100
  as percentage_deaths_per_population 
  from coviddeaths$ 
  group by location,population
  order by 4 desc ;

    -- Countries with the highest death count
  select location, max(cast (total_deaths as int)) as highestdeathcount
  from coviddeaths$ 
  where continent is not null
  group by location,population
  order by 2 desc ;

  -- Continents with the highest death count
  select continent, max(cast (total_deaths as int)) as highestdeathcount
  from coviddeaths$ 
  where continent is not null
  group by continent
  order by 2 desc ;


-- Joining covid deaths and covid vaccinations table
-- 
select * from coviddeaths$ dea
join covidVaccinations$ vac on 
dea.location = vac.location
and dea.date = vac.date;

-- Total population vs Vaccination
select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations 
from coviddeaths$ dea
join covidVaccinations$ vac on 
dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;

--new vaccines administered per day
select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations ,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location 
order by dea.location,dea.date) as  new_vaccinations_per_day
from coviddeaths$ dea
join covidVaccinations$ vac on 
dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

--Using a CTE
with vaccinations (continent,location,date,population,newvaccinations,vaccinations_per_day) as 
(
select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations ,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location 
order by dea.location,dea.date) as  new_vaccinations_per_day
from coviddeaths$ dea
join covidVaccinations$ vac on 
dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)

select *,(vaccinations_per_day/population)*100 from vaccinations order by 1,2,3;

--Using views
create view population_vaccinated_per_day as
select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations ,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location 
order by dea.location,dea.date) as  new_vaccinations_per_day
from coviddeaths$ dea
join covidVaccinations$ vac on 
dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3;

select * from population_vaccinated_per_day;