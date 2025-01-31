use pokemon;
select * from pokemon_dataset;


-- creating copy of orignal data set 

create table pokemon_copy like pokemon_dataset;
insert pokemon_copy select * from pokemon_dataset;
select * from pokemon_copy;

-- checking number of rows and columns
 
select( select count(*) from pokemon_copy) as row_counts,
(select count(*) from INFORMATION_SCHEMA.COLUMNS where table_name = 'pokemon_copy' and table_schema = 'pokemon') as column_counts

-- Finding duplicates

with duplicate_cte as(
 select *, row_number() over(partition by 
primary_type, 
secondary_type,
first_appreance,  
generation,
category ,
total_base_stats, 
hp,
attack,  
defense, 
special_attack,  
special_defense,
speed) as row_num from pokemon_copy) select * from duplicate_cte where row_num > 1;
-- creating another table to delete duplicates  i have to add another column row num to delete it 

CREATE TABLE `pokemon_copy2` (
  `pokemon_id` int DEFAULT NULL,
  `name` text,
  `primary_type` text,
  `secondary_type` text,
  `first_appreance` text,
  `generation` text,
  `category` text,
  `total_base_stats` int DEFAULT NULL,
  `hp` int DEFAULT NULL,
  `attack` int DEFAULT NULL,
  `defense` int DEFAULT NULL,
  `special_attack` int DEFAULT NULL,
  `special_defense` int DEFAULT NULL,
  `speed` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into pokemon_copy2
select *, row_number() over(partition by 
primary_type, 
secondary_type,
first_appreance,  
generation,
category ,
total_base_stats, 
hp,
attack,  
defense, 
special_attack,  
special_defense,
speed) as row_num from pokemon_copy;
select * from pokemon_copy2;

delete from pokemon_copy2 where  row_num > 1;

-- checking for null  values

SELECT * FROM pokemon_copy2 
WHERE 
primary_type IS NULL OR primary_type = '' OR
secondary_type IS NULL OR secondary_type = '' OR
first_appreance IS NULL OR first_appreance = '' OR
generation IS NULL OR generation = '' OR
category IS NULL OR category = '' OR
total_base_stats IS NULL OR total_base_stats = '' OR
hp IS NULL OR hp = '' OR
attack IS NULL OR attack = '' OR
defense IS NULL OR defense = '' OR
special_attack IS NULL OR special_attack = '' OR
special_defense IS NULL OR special_defense = '' OR
speed IS NULL OR speed = '';

-- updating  null/ empty colums 
update pokemon_copy2  set secondary_type = 'unknown' where  secondary_type is null or secondary_type ='';

select * from pokemon_copy2;
select max(hp),min(hp),avg(hp),
min(attack),max(attack),avg(attack),
min(defense),max(defense),avg(defense),
min(speed),max(speed),avg(speed)
from  pokemon_copy2;

select generation, count(*) from pokemon_copy2 group by generation order by generation;

with year_cte as(select first_appreance,count(*) from pokemon_copy2 group by first_appreance) select * from year_cte order by  first_appreance;

-- fastest pokemon

with fastest_pokemon as(select name,generation,category,speed, attack, row_number() over(partition by generation order by speed,attack ) as speed_rank
from pokemon_copy2) select  name,generation,category,speed,attack from fastest_pokemon where speed_rank = 1 order by generation;

-- pokemon per generation
select name,generation,(select  count(*) from pokemon_copy2 pc2 where pc2.generation = pc1.generation) as pokemon_per_generation 
from pokemon_copy2 pc1 order by name,generation;								

-- strongest pokemon per generaton
 with ranked_poke as(select name, generation,total_base_stats,
 row_number() over(partition by generation order by total_base_stats) as strongest_pokemon from pokemon_copy2)
select name, generation,total_base_stats from ranked_poke where strongest_pokemon <5 order by generation,total_base_stats desc;

-- categorial stats of pokemon
with ranked_category as(select category, avg(hp) as avg_hp,
avg(attack) as avg_attack,  
avg(defense) as avg_defence, 
avg(special_attack) as avg_special_attack,  
avg(special_defense) as avg_special_defence,
avg(speed) as avg_speed, avg(total_base_stats) as avg_base_stats 
from  pokemon_copy2 where category in ('regular','legendary','paradox','ultra beast','mythical') group by category)
select * from ranked_category order by avg_base_stats;

-- analysing the best combination of each pokemon
select primary_type,secondary_type,count(*) as count  from pokemon_copy2 where secondary_type is not null group by primary_type,secondary_type
having count(*) >5 order by  count  desc;



