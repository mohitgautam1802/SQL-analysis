select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Analysis..covid_deaths$

where continent is not null
Group by Location
order by TotalDeathCount desc


select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Analysis..covid_deaths$
where continent is null
Group by Location
order by TotalDeathCount desc


--showing the continent with the highest death count per population

--global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Analysis..covid_deaths$
where continent is not null
group by date
order by 1, 2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Analysis..covid_deaths$
where continent is not null
--group by date
order by 1, 2


--Looking at total population vs vaccinations

select *
From Analysis..covid_deaths$ dea
join Analysis..covid_vaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as bigint))  over (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinations

From Analysis..covid_deaths$ dea
join Analysis..covid_vaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as bigint))  over (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinations

From Analysis..covid_deaths$ dea
join Analysis..covid_vaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinations/Population)*100
from PopvsVac

-- temp table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinations numeric
)

Insert into  #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as bigint))  over (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinations

From Analysis..covid_deaths$ dea
join Analysis..covid_vaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinations/Population)*100
from #PercentPopulationVaccinated 


--creating view to store date fro later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as bigint))  over (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinations

From Analysis..covid_deaths$ dea
join Analysis..covid_vaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
from PercentPopulationVaccinated