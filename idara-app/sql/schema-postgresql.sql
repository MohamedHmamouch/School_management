-- Initialize the database.
-- Drop any existing data and create empty tables.
-- 
-- psql "postgresql://flaskrpgadmin:flaskrpgadminpass@localhost:5432/flaskrpg" < flaskrpg/schema-postgresql.sql
-- 

drop table if exists star;
drop table if exists post;
drop table if exists "user";

CREATE TABLE seance (
    id INT PRIMARY KEY,
    Type VARCHAR(255),
    salle VARCHAR(255),
    date_debut DATETIME,
    date_fin DATETIME,
    groupe VARCHAR(255)
);

CREATE TABLE utilisateur (
    id INT PRIMARY KEY,
    nom VARCHAR(255),
    email VARCHAR(255),
    mdp VARCHAR(255),
    tel VARCHAR(255),
    role_user VARCHAR(255) check (Type in ('Vcataire','Doctorant','Responsable de Module','Responsable option'))
);

CREATE TABLE Compétence (
    id INT PRIMARY KEY,
    Libellé VARCHAR(255)
);

CREATE TABLE Option (
    id INT PRIMARY KEY,
    Nom VARCHAR(255),
    Descriptif TEXT,
    Nombre_d'étudiants INT,
    Responsable INT,
    Niveau VARCHAR(255),
    FOREIGN KEY (Responsable) REFERENCES Utilisateur(id)
);

CREATE TABLE Parcours (
    id INT PRIMARY KEY,
    Descriptif TEXT,
    Nombre_d'étudiants INT,
    Durée VARCHAR(255),
    option_id INT,
    FOREIGN KEY (option_id) REFERENCES Option(id)
);

CREATE TABLE Module (
    id INT PRIMARY KEY,
    Objectif TEXT,
    Descriptif TEXT,
    responsable_id INT,
    FOREIGN KEY (responsable_id) REFERENCES Utilisateur(id)
);

CREATE TABLE Cours (
    id INT PRIMARY KEY,
    Intitulé VARCHAR(255)
);

CREATE TABLE composé (
    id INT PRIMARY KEY,
    parcours_id INT,
    module_id INT,
    FOREIGN KEY (parcours_id) REFERENCES Parcours(id),
    FOREIGN KEY (module_id) REFERENCES Module(id)
);

CREATE TABLE appartient (
    id INT PRIMARY KEY,
    cours_id INT,
    module_id INT,
    FOREIGN KEY (cours_id) REFERENCES Cours(id),
    FOREIGN KEY (module_id) REFERENCES Module(id)
);

CREATE TABLE composé_de (
    id INT PRIMARY KEY,
    cours_id INT,
    séance_id INT,
    FOREIGN KEY (cours_id) REFERENCES Cours(id),
    FOREIGN KEY (séance_id) REFERENCES Séance(id)
);

CREATE TABLE demande (
    id INT PRIMARY KEY,
    cours_id INT,
    compétence_id INT,
);
