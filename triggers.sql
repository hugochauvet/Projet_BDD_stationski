----------------------------------------- TRIGGERS ---------------------------------------------


----- TRIGGERS 1 & 2 -----

--- FONCTION TRIGGERS 1 & 2 ---

CREATE OR REPLACE FUNCTION carte_utilisee() RETURNS trigger AS $carte_util$ 
DECLARE 
-- ici on déclare les variables dont on a besoin si on n'a pas de variable à déclarer alors on ne met pas le mot DECLARE
nb_forfaits INTEGER; 
new_date_debut DATE; 
new_duree_forfait INTEGER;
BEGIN 
-- On teste la date de début du nouveau forfait, si elle est nulle alors on met la date du jour dans date_debut 
IF (NEW.date_debut IS NULL) THEN 
new_date_debut = (SELECT CURRENT_DATE); 
ELSE
new_date_debut = NEW.date_debut; 
END IF; 
-- on récupère la durée du forfait 
new_duree_forfait = (SELECT duree_forfait 
                     FROM type_forfait 
                     WHERE id_type_forfait=NEW.id_type_forfait); 
-- requête qui compte le nombre de forfait valides utilisant la carte 
nb_forfaits = (SELECT count (id_forfait) 
               FROM forfait NATURAL JOIN type_forfait 
              	WHERE id_carte=NEW.id_carte 
               AND ((new_date_debut,new_date_debut + new_duree_forfait) OVERLAPS  (date_debut,date_debut+duree_forfait)
						OR (date_debut is NULL))
					
			   );
	
			   
-- Ajoutez à la requête précédente la condition de vérification il n'existe pas de forfait avec date_debut=NULL 
-- si la carte est déja utilisée, alors je lève une exception 
IF ( nb_forfaits > 0) THEN 
RAISE EXCEPTION 'La carte % nest pas disponible !!!', NEW.id_carte;
-- ceci permet de produire un texte d erreur qui sera affiché si on essaye d'ajouter un forfait affecté à une carte déja utilisée 
END IF; 
-- si tout se passe bien, alors on retourne NEW qui est la variable contenant la ligne que l'on est en train de rajouter 
RETURN NEW; 
END

$carte_util$ LANGUAGE plpgsql;

--- CREATION TRIGGER 1 & 2 ---

CREATE TRIGGER carte_utilisee BEFORE INSERT 
ON forfait FOR EACH ROW 
EXECUTE PROCEDURE carte_utilisee();

--- TEST TRIGGER 1 ---

insert into forfait (id_forfait,date_debut,id_carte,id_type_forfait)
values (123456789,'2022-10-12',1,7); 

insert into forfait (id_forfait,date_debut,id_carte,id_type_forfait)
values (12345678,'2022-10-15',1,7);

delete from forfait
where date_debut in ('15/10/2022','12/10/2022');

--- TEST TRIGGER 2 ---

insert into forfait (id_forfait,date_debut,id_carte,id_type_forfait)
values (123456789,NULL,1,1);

insert into forfait (id_forfait,date_debut,id_carte,id_type_forfait)
values (12345678,NULL,1,1);

delete from forfait
where date_debut is NULL;


----- TRIGGER 3 -----

CREATE OR REPLACE FUNCTION expire() RETURNS trigger AS $before_insert_passage$

DECLARE 

date_fin DATE;
heure_fin_t TIME;
new_heure_passage timestamp without time zone;
date_heure_fin timestamp without time zone;
id_forfait_t integer;

moment_interdit timestamp without time zone;
duree_remontee_t interval;
dernier_passage timestamp without time zone;
BEGIN 
-- Si l'heure de passage est null mettre la date et heure acctuelle
-- Mais heure_passage fait partie de la clé primaire donc ne peut pas etre null.
if (new.heure_passage is NULL) then
new_heure_passage = NOW();
else 
new_heure_passage=new.heure_passage;
end if;

-- On cherche le forfait le plus récent pour la carte à ajouter
id_forfait_t =(select distinct (id_forfait)
				from forfait
				where id_carte = new.id_carte
				and date_debut in (select distinct max(date_debut)
									from forfait
									where id_carte = new.id_carte
									)
							   );

-- On determine la date de fin du forfait ainsi que l'heure de fin du forfait		   
date_fin = (select date_debut+duree_forfait
			from type_forfait natural join forfait 
			where id_forfait = id_forfait_t);

heure_fin_t = (select heure_fin
				from type_forfait natural join forfait 
				where id_forfait = id_forfait_t);

date_heure_fin =date_fin+heure_fin_t;		
			
-- Si le fofait est expiré on declanche une erreur
IF ( date_heure_fin  < new_heure_passage) THEN 
RAISE EXCEPTION 'Le forfait est expiré !!!';

END IF; 

----- TRIGGER 4 -----

--On cherche la derniere fois que la carte est passé est passer dans cette remontée
dernier_passage = (select max(heure_passage)
				  from passage
				  where id_remontee= new.id_remontee
				  and id_carte = new.id_carte);

--On determine ensuite la période ou le forfait n'a pas le droit d'etre utilisée pour cette remontée
duree_remontee_t = (select duree_remontee 
					from remontee
					where id_remontee= new.id_remontee
				   );
				
					
moment_interdit = dernier_passage + duree_remontee_t;

--Si la carte repasse dans la meme remontée avant la fin de la période une erreur est déclanché
if (new_heure_passage < moment_interdit) then 
RAISE EXCEPTION 'Vous venez juste de passer sur cette remontée, attender % pour réessayer !!', moment_interdit;
end if;

RETURN NEW; 
END

$before_insert_passage$ LANGUAGE plpgsql;

--- CREATION TRIGGERS 3 & 4 ---

CREATE TRIGGER benfore_insert_passage BEFORE INSERT 
ON passage  FOR EACH ROW 
EXECUTE PROCEDURE expire();

----- TEST TRIGGERS 3 & 4 -----

insert into passage(id_carte,id_remontee,heure_passage)
values (3,4,NOW());
-- On test avec une carte qui à une date expiré 
--ce qui declanche le trigeer car la date est expiré

INSERT into forfait (id_forfait,date_debut,id_carte,id_type_forfait)
values (123456789,NOW(),3,7);
--On insere un nouveau forfait pour la meme carte qui aura une date valide 
--car il n y en a pas dans la base


select count(*)
from passage
where id_carte = 3
and id_remontee = 4;
-- On s'assure que l'ajout dans la table passage n'existe pas 
--pour pouvoir le supprimer facilement apres


insert into passage(id_carte,id_remontee,heure_passage)
values (3,4,NOW());
-- On test l'ajout dans passage
-- Ceci ne declanche pas le trigger !! 

insert into passage(id_carte,id_remontee,heure_passage)
values (3,4,NOW());
--On insere la meme carte pour la meme remontee toute de suite apres
--Ce qui declanche le trigger car le passage vien d'etre effectuer

--suppressions des données test :
-- DELETE from passage 
-- where passage.id_carte = 3
-- and id_remontee=4 ;

-- DELETE from forfait where id_forfait = 123456789;