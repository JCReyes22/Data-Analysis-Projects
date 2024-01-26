Select * 
From CovidData..Deaths
Order by 3,4

Select *
From CovidData..Vaccinations
Order by 3,4

Select location, date, population, total_cases, new_cases, total_deaths
From CovidData..Deaths
Order by 1,2

-- Total Cases Vs. Total Deaths by Country

Select location, date, total_cases, total_deaths, 
Round(Cast(total_deaths as float)/Cast(total_cases as float)*100, 2) as DeathPercentage
From CovidData..Deaths
Where (total_deaths is not null) and (total_cases is not null)
Order by 1,2

--Total Cases Vs. Total Deaths by Continent 

Select continent, date, total_cases, total_deaths, 
Round(Cast(total_deaths as float)/Cast(total_cases as float)*100, 2) as DeathPercentage
From CovidData..Deaths
Where (total_deaths is not null) and (total_cases is not null) and (continent is not null)
Order by 1,2

--Total Cases Vs. Total Death in U.S.

Select location, date, total_cases, total_deaths, 
Round((Cast(total_deaths as float)/Cast(total_cases as float))*100, 2) as death_percentage
From CovidData..Deaths
Where location like '%states%' and total_deaths is not null and total_cases is not null
Order by 1,2

-- Total Cases Vs. Population by Continent

Select continent, date, population, total_cases,
Round((Cast(total_cases as float)/population)*100, 2) as percent_infected
From CovidData..Deaths
Where (continent is not null) and (total_cases is not null) and (population is not null)
Order by continent, percent_infected desc

-- Total Cases Vs. Population in the U.S.

Select location, date, population, total_cases,
Round((Cast(total_cases as float)/population)*100, 2) as percent_infected
From CovidData..Deaths
Where location like '%states%' and (total_cases is not null) and (population is not null)
Order by percent_infected desc

--Countries with highest infection rates per Population

Select location, population, Max(total_cases) as highest_cases, 
Max(Round((Cast(total_cases as float)/population)*100, 2)) as percent_infected
From CovidData..Deaths
Where (total_cases is not null) and (population is not null)
Group by location, population
Order by percent_infected desc

--Continents with highest death rate per Population

Select continent, population, Max(total_deaths) as total_death_count, 
Max(Round((Cast(total_deaths as float)/population)*100, 2)) as death_percentage
From CovidData..Deaths
Where (total_deaths is not null) and (population is not null) and (continent is not null)
Group by continent, population
Order by death_percentage desc

--GLOBAL 

Select Sum(Cast(new_deaths as int)) as total_deaths, Sum(new_cases) as total_cases,
(Sum(Cast(new_deaths as int))/Sum(new_cases))*100 as death_percentage
From CovidData..deaths
Where continent is not null 

-- Total Population Vs. Vaccinations

Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations,
Sum(Cast(Vacc.new_vaccinations as bigint)) 
Over (Partition by Deaths.location 
Order by Deaths.date) as rolling_vaccinations
From CovidData..Deaths as Deaths
Join CovidData..Vaccinations as Vacc
	On Deaths.location = Vacc.location
	and Deaths.date = Vacc.date
where Deaths.continent is not null and (Vacc.new_vaccinations is not null)
Order by 1,2,3

--USE CTE

With PopVsVacc (continent, location, date, population, new_vaccinations, rolling_vaccinations)
as
(
Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations,
Sum(Cast(Vacc.new_vaccinations as bigint)) 
Over (Partition by Deaths.location 
Order by Deaths.date) as rolling_vaccinations
From CovidData..Deaths as Deaths
Join CovidData..Vaccinations as Vacc
	On Deaths.location = Vacc.location
	and Deaths.date = Vacc.date
where Deaths.continent is not null and (Vacc.new_vaccinations is not null)
)
Select *, Round((rolling_vaccinations/population)*100, 2) as vacc_percentage
from PopVsVacc

--TEMP TABLE

Drop Table if exists #vacc_percentage
Create Table #vacc_percentage
(
continent nvarchar(255),
location nvarchar(255),
date date,
population float,
new_vaccinations float,
rolling_vaccinations float
)

Insert into #vacc_percentage
Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations,
Sum(Cast(Vacc.new_vaccinations as bigint)) 
Over (Partition by Deaths.location 
Order by Deaths.date) as rolling_vaccinations
From CovidData..Deaths as Deaths
Join CovidData..Vaccinations as Vacc
	On Deaths.location = Vacc.location
	and Deaths.date = Vacc.date
where Deaths.continent is not null and (Vacc.new_vaccinations is not null)

Select *, Round((rolling_vaccinations/population)*100, 2) as vacc_percentage
from #vacc_percentage

--View for visualizations

Create View vacc_percentage as 
Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations,
Sum(Cast(Vacc.new_vaccinations as bigint)) 
Over (Partition by Deaths.location 
Order by Deaths.date) as rolling_vaccinations
From CovidData..Deaths as Deaths
Join CovidData..Vaccinations as Vacc
	On Deaths.location = Vacc.location
	and Deaths.date = Vacc.date
where Deaths.continent is not null and (Vacc.new_vaccinations is not null)





























