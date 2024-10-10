-- query the CovidDeath table to check if the data is pulled out or not, order by "location" and "date"
select *
from [Porfolio Project]..CovidDeathsV2
order by 3,4;

-- query the CovidVaccination table to check if the data is pulled out or not, order by "location" and "date"
select *
from [Porfolio Project]..CovidVaccinations
order by 3,4;

--check the data type of columns of CovidDeathsV2 table
select column_name, data_type, character_maximum_length
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'CovidDeathsV2';

-- select the data that i am going to be using.
select location, date, population,total_cases, new_cases
from [Porfolio Project]..CovidDeathsV2
order by 1,2;

-- I am going to looking for the Total Cases vs the Total Death
select location, date, total_cases, total_deaths, (cast(total_deaths as float
)/cast(total_cases as float))*100 as death_ratio
from [Porfolio Project]..CovidDeathsV2
order by 1,2;

-- query the maximum death_ratio
select top(1) location, date, total_cases, total_deaths, max((cast(total_deaths as float
)/cast(total_cases as float))*100) as Max_death_ratio
from [Porfolio Project]..CovidDeathsV2
group by location, date, total_cases, total_deaths
order by 5 desc;

--query the minimum death_ratio
select top(1) location, date, total_cases, total_deaths, min((cast(total_deaths as float
)/cast(total_cases as float))*100) as Min_death_ratio
from [Porfolio Project]..CovidDeathsV2
group by location, date, total_cases, total_deaths
having min((cast(total_deaths as float
)/cast(total_cases as float))*100) is not null
order by 5 asc;
--------The minimum death ratio is 0.04%  in Quatar in 19-05-2020, the total cases at that day is 35606 and total deaths is 15.


--query the total cases, total deaths and the death ratio in Vietnam
select top(1) location, date, total_cases, total_deaths, (cast(total_deaths as float
)/cast(total_cases as float))*100 as death_ratio
from [Porfolio Project]..CovidDeathsV2
where location like '%viet%'
order by total_cases desc;
--------The total cases, total deaths and the death ratio till 30-04-2021 in Vietnam are 2928, 35, 1.19535519125683, respectively.


--looking at Total cases vs Population
--Shows what percentage of population got infection
select location, date, population, total_cases, (cast(total_cases as float)/cast(population as float))*100 as Infection_rate
from [Porfolio Project]..CovidDeathsV2
order by 1,2;


--query the infection rate of Vietnam
select location, date, population, total_cases, (cast(total_cases as float)/cast(population as float))*100 as Infection_rate
from [Porfolio Project]..CovidDeathsV2
where location like '%viet%'
order by 1,2;
-------- The minimum infection rate in Vietnam was 2.05468370132325E-06 on 23-01-2020 and the maximum infection rate in Vietnam was 0.00300805693873723 in 30-04-2021

--shows how fast the infection rate in Vietnam
select (max(Infection_rate)/min(Infection_rate)) as infection_rate_velocity
from 
(select location, (cast(total_cases as float)/cast(population as float))*100 as Infection_rate 
from [Porfolio Project]..CovidDeathsV2) as temp
where location like '%viet%'
group by location;
--------The infection rate has increased 1464 times from 23-02-2020 to 30-4-2021

--Looking at the top 10 countries with the highest infection rate compared to population
select top(10) location, population, max(total_cases) as highest_infection_count, max((cast(total_cases as float)/cast(population as float))*100) as highest_Infection_rate
from [Porfolio Project]..CovidDeathsV2
group by location, population
order by highest_Infection_rate desc;
--------The highest infection rate from 23-02-2020 to 30-4-2021 was belong to Andorra

--Looking at the top 10 countries with the highest death count
select top(10) location, population, max(total_deaths) as highest_death_count
from [Porfolio Project]..CovidDeathsV2
where continent is not null
group by location, population
order by highest_death_count desc;
--------The country had the highest death was United State with 576232 cases.

--Break things down by continent
--showing the continent with the highest death count per population
select continent, max(total_deaths) as highest_death_count
from [Porfolio Project]..CovidDeathsV2
where continent is not null
group by continent
order by highest_death_count desc;
--------The continent had the highest death count was North America


--Looking at Total population vs vaccination
select a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(convert(int,b.new_vaccinations)) over (partition by a.location order by a.location, a.date) as sum_new_vaccinations 
from [Porfolio Project]..CovidDeathsV2 a
join [Porfolio Project]..CovidVaccinations b 
	on a.location = b.location
	and a.date = b.date
where a.continent is not null
order by 1,2,3;

--USING CTE to calculate the vaccination ratio compared to population
with pop_vs_vac (continent, location, date, population, new_vaccinations, sum_new_vaccinations)
as 
(
select a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(convert(int,b.new_vaccinations)) over (partition by a.location order by a.location, a.date) as sum_new_vaccinations 
from [Porfolio Project]..CovidDeathsV2 a
join [Porfolio Project]..CovidVaccinations b 
	on a.location = b.location
	and a.date = b.date
where a.continent is not null
)
select *, (cast(sum_new_vaccinations as float)/population)*100 as vaccination_ratio
from pop_vs_vac;


--USING TEMP TABLE to calculate the vaccination ratio compared to population
drop table if exists #population_vs_vaccination 
create table #population_vs_vaccination
(
continent nvarchar(50), 
location nvarchar(50), 
date datetime, 
population int, 
new_vaccinations float, 
sum_new_vaccinations float
)
insert into #population_vs_vaccination
select a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(convert(int,b.new_vaccinations)) over (partition by a.location order by a.location, a.date) as sum_new_vaccinations 
from [Porfolio Project]..CovidDeathsV2 a
join [Porfolio Project]..CovidVaccinations b 
	on a.location = b.location
	and a.date = b.date
where a.continent is not null

select *, (sum_new_vaccinations/population)*100 as vaccination_ratio
from #population_vs_vaccination

--Create View for later visualization

create view population_vs_vaccination
as
select a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(convert(int,b.new_vaccinations)) over (partition by a.location order by a.location, a.date) as sum_new_vaccinations 
from [Porfolio Project]..CovidDeathsV2 a
join [Porfolio Project]..CovidVaccinations b 
	on a.location = b.location
	and a.date = b.date
where a.continent is not null;

select * 
from population_vs_vaccination
