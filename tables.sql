CREATE TABLE Type_Forfait(
   id_type_forfait INT,
   libelle_type_forfait VARCHAR(30),
   prix INT,
   heure_debut TIME,
   heure_fin TIME,
   duree_forfait INT,
   conditions VARCHAR(30),
   PRIMARY KEY(id_type_forfait)
);

CREATE TABLE Type_Remontee(
   id_type_remontee INT,
   libelle_type_remontee VARCHAR(30),
   PRIMARY KEY(id_type_remontee)
);

CREATE TABLE Carte(
   id_carte INT,
   PRIMARY KEY(id_carte)
);

CREATE TABLE Forfait(
   id_forfait INT,
   date_debut DATE,
   id_carte INT NOT NULL,
   id_type_forfait INT NOT NULL,
   PRIMARY KEY(id_forfait),
   FOREIGN KEY(id_carte) REFERENCES Carte(id_carte),
   FOREIGN KEY(id_type_forfait) REFERENCES Type_Forfait(id_type_forfait)
);

CREATE TABLE Remontee(
   id_remontee INT,
   nom_remontee VARCHAR(30),
   duree_remontee INTERVAL,
   id_type_remontee INT NOT NULL,
   PRIMARY KEY(id_remontee),
   FOREIGN KEY(id_type_remontee) REFERENCES Type_Remontee(id_type_remontee)
);

CREATE TABLE Passage(
   id_remontee INT,
   id_carte INT,
   heure_passage TIMESTAMP,
   PRIMARY KEY(id_remontee, id_carte, heure_passage),
   FOREIGN KEY(id_remontee) REFERENCES Remontee(id_remontee),
   FOREIGN KEY(id_carte) REFERENCES Carte(id_carte)
);