/* =============================================================================
   Création de la base de démonstration PHP / PDO / SQL Server
   -----------------------------------------------------------------------------
   Exécution :
     - SSMS / Azure Data Studio : ouvrir le fichier et exécuter (F5)
     - Ligne de commande :
         sqlcmd -S "(localdb)\MSSQLLocalDB" -E -i create-database.sql
         sqlcmd -S localhost -E -i create-database.sql
   ============================================================================= */
/* -----------------------------------------------------------------------------
   1. Base de données
   -------------------------------------------------------------------------- */
USE master;


GO
-- Le script est réexécutable : on repart d'une base propre.
-- SINGLE_USER ... ROLLBACK IMMEDIATE ferme les connexions en cours,
-- sans quoi le DROP échouerait.
IF DB_ID('demo_pdo') IS NOT NULL
    BEGIN
        ALTER DATABASE demo_pdo
            SET SINGLE_USER 
            WITH ROLLBACK IMMEDIATE;
        DROP DATABASE demo_pdo;
    END


GO
CREATE DATABASE demo_pdo;


GO
/* -----------------------------------------------------------------------------
   2. Connexion (login) et utilisateur (user)
   -----------------------------------------------------------------------------
   Différence essentielle avec MySQL : SQL Server sépare deux notions.

     LOGIN  -> niveau SERVEUR   : permet de se connecter à l'instance
     USER   -> niveau BASE      : permet d'accéder à une base précise

   Un LOGIN sans USER peut se connecter mais ne voit aucune base.
   -------------------------------------------------------------------------- */
USE master;


GO
IF SUSER_ID('demo_user') IS NOT NULL
    DROP LOGIN demo_user;


GO
CREATE LOGIN demo_user
    WITH PASSWORD = 'Test1234=', DEFAULT_DATABASE = demo_pdo, CHECK_POLICY = OFF;


GO
USE demo_pdo;


GO
CREATE USER demo_user FOR LOGIN demo_user;


GO
-- Droits minimaux : lecture + écriture sur les données.
-- On évite db_owner, qui donnerait tous les droits (dont DROP TABLE).
ALTER ROLE db_datareader ADD MEMBER demo_user;

ALTER ROLE db_datawriter ADD MEMBER demo_user;


GO
/* -----------------------------------------------------------------------------
   3. Tables liées (relation 1-N : un auteur écrit plusieurs livres)
   -------------------------------------------------------------------------- */
USE demo_pdo;


GO
-- Ordre de suppression inverse de l'ordre de création :
-- la table qui porte la clé étrangère part en premier.
DROP TABLE IF EXISTS dbo.livre;

DROP TABLE IF EXISTS dbo.auteur;


GO
CREATE TABLE dbo.auteur (
    id          INT            IDENTITY (1, 1) NOT NULL,
    nom         NVARCHAR (100) NOT NULL,
    prenom      NVARCHAR (100) NOT NULL,
    nationalite NVARCHAR (60)  NULL,
    CONSTRAINT PK_auteur PRIMARY KEY (id)
);


GO
CREATE TABLE dbo.livre (
    id        INT            IDENTITY (1, 1) NOT NULL,
    titre     NVARCHAR (200) NOT NULL,
    annee     SMALLINT       NULL,
    prix      DECIMAL (6, 2) NULL,
    isbn      CHAR (13)      NULL,
    auteur_id INT            NOT NULL,
    CONSTRAINT PK_livre PRIMARY KEY (id),
    CONSTRAINT CK_livre_prix CHECK (prix >= 0),
    -- La clé étrangère : c'est elle qui « lie » les deux tables.
    -- ON DELETE CASCADE : supprimer un auteur supprime ses livres.
    CONSTRAINT FK_livre_auteur FOREIGN KEY (auteur_id) REFERENCES dbo.auteur (id) ON DELETE CASCADE ON UPDATE NO ACTION
);


GO
-- Index sur la clé étrangère : SQL Server ne le crée pas automatiquement,
-- contrairement à MySQL/InnoDB. Utile dès que l'on fait des JOIN.
CREATE INDEX IX_livre_auteur_id
    ON dbo.livre(auteur_id);


GO
-- QUOTED_IDENTIFIER ON est OBLIGATOIRE pour créer un index filtré.
-- SSMS l'active par défaut, sqlcmd NON : sans cette ligne, le script échoue
-- en ligne de commande avec « Msg 1934 ... incorrect settings: QUOTED_IDENTIFIER ».
SET QUOTED_IDENTIFIER ON;


GO
-- Unicité de l'ISBN.
--
-- ATTENTION : une CONSTRAINT ... UNIQUE (isbn) ne convient PAS ici.
-- SQL Server traite NULL comme une valeur ordinaire dans une contrainte UNIQUE
-- et n'en accepte donc QU'UN SEUL : le deuxième livre sans ISBN serait rejeté
-- avec « Violation of UNIQUE KEY constraint ... duplicate key value is (<NULL>) ».
-- La plupart des autres SGBD (MySQL, PostgreSQL) acceptent plusieurs NULL.
--
-- La solution SQL Server est un index unique FILTRÉ : l'unicité ne s'applique
-- qu'aux lignes qui ont réellement un ISBN.
CREATE UNIQUE INDEX UQ_livre_isbn
    ON dbo.livre(isbn) WHERE isbn IS NOT NULL;


GO
/* -----------------------------------------------------------------------------
   4. Jeu de données de test
   -------------------------------------------------------------------------- */
-- Les auteurs sont insérés en premier : la table livre porte la clé étrangère,
-- elle ne peut référencer que des auteurs qui existent déjà.
-- La base vient d'être créée, donc les IDENTITY partent de 1 dans l'ordre
-- d'insertion : Tolkien = 1, Le Guin = 2, etc.
INSERT  INTO dbo.auteur (
    nom,
    prenom,
    nationalite
)
VALUES                 (N'Tolkien', N'J.R.R.', N'Britannique'),
(N'Le Guin', N'Ursula K.', N'Américaine'),
(N'Pratchett', N'Terry', N'Britannique'),
(N'Gaiman', N'Neil', N'Britannique'),
(N'Hobb', N'Robin', N'Américaine'),
(N'Bottero', N'Pierre', N'Française'),
(N'Jaworski', N'Jean-Philippe', N'Française'),
(N'Ende', N'Michael', N'Allemande');


GO
-- Les ISBN ci-dessous sont FICTIFS : ils respectent le format à 13 chiffres
-- pour les exercices, mais ne correspondent pas aux éditions réelles.
--
-- Trois livres ont volontairement un ISBN à NULL, et l'un d'eux n'a ni année
-- ni prix : c'est ce qui permet de vérifier que les colonnes facultatives
-- fonctionnent, et que l'index unique FILTRÉ accepte bien plusieurs NULL
-- (ce qu'une contrainte UNIQUE classique refuserait sous SQL Server).
INSERT  INTO dbo.livre (
    titre,
    annee,
    prix,
    isbn,
    auteur_id
)
VALUES                (N'Le Hobbit', 1937, 9.90, '9781000000011', 1),
(N'La Communauté de l''anneau', 1954, 12.50, '9781000000028', 1),
(N'Le Silmarillion', 1977, 14.20, '9781000000035', 1),
(N'Le Sorcier de Terremer', 1968, 8.60, '9781000000042', 2),
(N'Les Tombeaux d''Atuan', 1971, 8.60, '9781000000059', 2),
(N'La Main gauche de la nuit', 1969, 9.20, NULL, 2),
(N'La Huitième Couleur', 1983, 7.90, '9781000000066', 3),
(N'Mortimer', 1987, 7.90, '9781000000073', 3),
(N'Les Petits Dieux', 1992, 8.40, NULL, 3),
(N'Neverwhere', 1996, 10.90, '9781000000080', 4),
(N'American Gods', 2001, 13.50, '9781000000097', 4),
(N'Coraline', 2002, 6.50, '9781000000103', 4),
(N'L''Assassin royal : L''Apprenti assassin', 1995, 11.80, '9781000000110', 5),
(N'L''Assassin royal : L''Assassin du roi', 1996, 11.80, '9781000000127', 5),
(N'La Quête d''Ewilan : D''un monde à l''autre', 2003, 8.90, '9781000000134', 6),
(N'Gagner la guerre', 2009, 16.00, '9781000000141', 7),
(N'L''Histoire sans fin', 1979, 10.20, '9781000000158', 8),
(N'Momo', NULL, NULL, NULL, 8);


GO
/* -----------------------------------------------------------------------------
   5. Vérification
   -------------------------------------------------------------------------- */
SELECT   a.nom + ' ' + a.prenom AS auteur,
         COUNT(l.id) AS nb_livres
FROM     dbo.auteur AS a
         LEFT OUTER JOIN
         dbo.livre AS l
         ON l.auteur_id = a.id
GROUP BY a.nom, a.prenom
ORDER BY auteur;