/* =============================================================================
   Migration : comptes utilisateurs et livres favoris
   -----------------------------------------------------------------------------
   À exécuter sur une base demo_pdo existante :

       sqlcmd -S localhost -E -d demo_pdo -i sql/add-utilisateurs-favoris.sql

   Nécessite des droits d'administration : demo_user n'a que db_datareader et
   db_datawriter, il ne peut pas créer de table. Il n'a pas besoin de droits
   supplémentaires ensuite : ces deux rôles couvrent automatiquement les
   nouvelles tables du schéma dbo.

   ENCODAGE : fichier UTF-8 AVEC BOM (voir create-database.sql).
   ============================================================================= */

USE demo_pdo;
GO

/* -----------------------------------------------------------------------------
   1. Utilisateurs
   -------------------------------------------------------------------------- */

DROP TABLE IF EXISTS dbo.favori;
DROP TABLE IF EXISTS dbo.utilisateur;
GO

CREATE TABLE dbo.utilisateur (
    id            INT           IDENTITY (1, 1) NOT NULL,
    email         NVARCHAR (180) NOT NULL,

    -- 255 caractères : on ne stocke JAMAIS le mot de passe, mais son empreinte
    -- produite par password_hash(). Bcrypt en fait 60, mais les algorithmes plus
    -- récents (argon2id) sont plus longs : on prévoit large.
    mot_de_passe  NVARCHAR (255) NOT NULL,
    role          NVARCHAR (10)  NOT NULL,
        CONSTRAINT UQ_utilisateur_role DEFAULT 'user',

    date_creation DATETIME2      NOT NULL
        CONSTRAINT DF_utilisateur_date DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_utilisateur PRIMARY KEY (id),

    -- email est NOT NULL : la contrainte UNIQUE ne pose donc pas le problème
    -- des NULL multiples rencontré sur l'ISBN.
    CONSTRAINT UQ_utilisateur_email UNIQUE (email)
);
GO

/* -----------------------------------------------------------------------------
   2. Favoris — table de liaison
   -----------------------------------------------------------------------------
   Un utilisateur aime plusieurs livres, un livre est aimé par plusieurs
   utilisateurs : c'est une relation PLUSIEURS-À-PLUSIEURS. Elle ne peut pas se
   représenter par une simple clé étrangère dans l'une des deux tables — il faut
   une table intermédiaire, qui ne contient que les deux clés.
   -------------------------------------------------------------------------- */

CREATE TABLE dbo.favori (
    utilisateur_id INT       NOT NULL,
    livre_id       INT       NOT NULL,
    date_ajout     DATETIME2 NOT NULL
        CONSTRAINT DF_favori_date DEFAULT SYSUTCDATETIME(),

    -- Clé primaire COMPOSÉE des deux colonnes : c'est elle qui garantit qu'un
    -- même livre ne peut pas être mis deux fois en favori par le même
    -- utilisateur. La garantie est dans la base, pas seulement dans le code PHP.
    CONSTRAINT PK_favori PRIMARY KEY (utilisateur_id, livre_id),

    -- ON DELETE CASCADE des deux côtés : supprimer un utilisateur ou un livre
    -- retire les lignes de favoris correspondantes, qui n'auraient plus de sens.
    CONSTRAINT FK_favori_utilisateur FOREIGN KEY (utilisateur_id)
        REFERENCES dbo.utilisateur (id) ON DELETE CASCADE,

    CONSTRAINT FK_favori_livre FOREIGN KEY (livre_id)
        REFERENCES dbo.livre (id) ON DELETE CASCADE
);
GO

-- La clé primaire indexe déjà (utilisateur_id, livre_id), ce qui couvre les
-- recherches « les favoris de tel utilisateur ». L'index inverse sert aux
-- recherches « qui a mis ce livre en favori ».
CREATE INDEX IX_favori_livre_id ON dbo.favori (livre_id);
GO

/* -----------------------------------------------------------------------------
   3. Vérification
   -------------------------------------------------------------------------- */

SELECT  t.name        AS [table],
        COUNT(c.column_id) AS colonnes
FROM    sys.tables t
        JOIN sys.columns c ON c.object_id = t.object_id
WHERE   t.name IN ('utilisateur', 'favori')
GROUP BY t.name;
GO