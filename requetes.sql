-- Projet BDD requêtes

-- 1)
select id_forfait, date_debut, id_type_forfait
from forfait
where id_carte = 1 
order by date_debut DESC
LIMIT 1

-- 2)
select distinct(nom_remontee)
from remontee natural join type_remontee
where libelle_type_remontee = 'tÃ©lÃ©siÃ¨ge'

-- 3)
select distinct(nom_remontee)
from forfait natural join carte natural join passage natural join remontee
where id_forfait = 1

-- 4)
select distinct(nom_remontee)
from remontee
where id_remontee not in (select id_remontee
						from forfait natural join carte natural join passage natural join remontee
						where id_forfait = 2)
						
-- 5)
select libelle_type_forfait, count(id_forfait) as nb_vente
from type_forfait natural join forfait
group by libelle_type_forfait

-- 6)
with toto as(
	select id_forfait
	from passage natural join carte natural join forfait natural join remontee
	group by id_forfait 
	having count(distinct(id_remontee)) = 
			(select count(id_remontee)
			from remontee))
select count(*) as forfait_util
from toto
		
-- 7)
select id_carte, count(id_forfait)
from carte natural join forfait
group by id_carte 
having count(id_forfait) >= 
		ALL(select count(id_forfait)
		from carte natural join forfait
		group by id_carte)

-- 8)
select nom_remontee, count(id_remontee)
from passage natural join remontee
group by nom_remontee

-- 9)
select date(heure_passage) as dateh, nom_remontee, count(id_remontee)
from passage natural join remontee
group by nom_remontee, dateh

-- 10)
select nom_remontee, count(id_remontee)
from passage natural join remontee
group by nom_remontee 
having count(id_remontee) >= 
		ALL (select count(id_remontee)
		from passage natural join remontee
		group by nom_remontee) 
		
-- 11)
select nom_remontee, count(id_remontee)
from type_remontee natural join remontee natural join passage
where libelle_type_remontee = 'tÃ©lÃ©siÃ¨ge'
group by nom_remontee
having count(id_remontee) <= 
		ALL (select count(id_remontee)
		from passage natural join remontee natural join type_remontee
		where libelle_type_remontee = 'tÃ©lÃ©siÃ¨ge'	 
		group by nom_remontee)

-- 12)
select DATE(heure_passage), id_forfait, count(id_forfait)
from carte natural join forfait natural join passage
group by DATE(heure_passage), id_forfait
having count(id_carte) >= 
		ALL (select count(id_forfait)
		from passage natural join carte natural join forfait	 
		group by DATE(heure_passage), id_forfait)

-- 13)
select sum(prix)
from type_forfait natural join forfait

-- 14)
select extract (MONTH from date_debut) as mois, extract (YEAR from date_debut) as annee, sum(prix)
from type_forfait natural join forfait
group by annee, mois

-- Bonus) Type de forfait le plus vendue sur une journée
select date_debut, libelle_type_forfait, count(id_type_forfait)
from forfait natural join type_forfait
group by date_debut, libelle_type_forfait
having count(id_type_forfait) >=
		ALL (select count(id_type_forfait)
		from forfait natural join type_forfait
		group by date_debut, libelle_type_forfait) 
order by date_debut