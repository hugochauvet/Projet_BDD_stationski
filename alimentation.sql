-- Carte
INSERT INTO carte (id_carte)
SELECT DISTINCT(id_carte) 
FROM bd_station
ORDER BY id_carte;

-- Type Forfait
INSERT INTO type_forfait (id_type_forfait, libelle_type_forfait, prix, heure_debut, heure_fin, duree_forfait, conditions)
SELECT DISTINCT id_type_forfait, libelle_type_forfait, prix, heure_debut, heure_fin, duree_forfait, condition
FROM bd_station;

-- Type Remontee
INSERT INTO type_remontee (id_type_remontee, libelle_type_remontee)
SELECT DISTINCT id_type_remontee, libelle_type_remontee
FROM bd_station;

-- Forfait
INSERT INTO forfait (id_forfait, id_carte, id_type_forfait, date_debut)
SELECT DISTINCT id_forfait, id_carte, id_type_forfait, date_debut
FROM bd_station
ORDER BY id_forfait;

-- Remontee
INSERT INTO remontee (id_remontee, nom_remontee, duree_remontee, id_type_remontee)
SELECT DISTINCT id_remontee, nom_remontee, duree_remontee, id_type_remontee
FROM bd_station
ORDER BY id_remontee;

-- Passage
INSERT INTO passage ( id_carte, id_remontee, heure_passage)
SELECT DISTINCT id_carte, id_remontee, heure_passage
FROM bd_station;