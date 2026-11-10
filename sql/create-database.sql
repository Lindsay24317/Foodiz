/* 
   1. DATABASE CREATION
    */

USE master;
GO

-- Recreate the database if it already exists.
IF DB_ID('foodiz') IS NOT NULL
BEGIN
    ALTER DATABASE foodiz
        SET SINGLE_USER
        WITH ROLLBACK IMMEDIATE;

    DROP DATABASE foodiz;
END
GO

CREATE DATABASE foodiz;
GO

USE foodiz;
GO


/* 
   2. USERS
  */

CREATE TABLE dbo.users (
    id_user INT IDENTITY(1,1) NOT NULL,
    firstname NVARCHAR(100) NOT NULL,
    lastname NVARCHAR(100) NOT NULL,
    email NVARCHAR(150) NOT NULL,
    password_hash NVARCHAR(255) NOT NULL,
    created_at DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT PK_users PRIMARY KEY (id_user),
    CONSTRAINT UQ_users_email UNIQUE (email)
);
GO


/* 
   3. USER PREFERENCES
   */

CREATE TABLE dbo.user_preferences (
    id_preference INT IDENTITY(1,1) NOT NULL,
    user_id INT NOT NULL,
    budget DECIMAL(8,2) NOT NULL,
    budget_period NVARCHAR(20) NOT NULL,
    number_of_people INT NOT NULL,
    max_cooking_time INT NULL,

    CONSTRAINT PK_user_preferences PRIMARY KEY (id_preference),

    CONSTRAINT UQ_user_preferences_user UNIQUE (user_id),

    CONSTRAINT CK_user_preferences_budget
        CHECK (budget > 0),

    CONSTRAINT CK_user_preferences_people
        CHECK (number_of_people > 0),

    CONSTRAINT CK_user_preferences_period
        CHECK (budget_period IN ('weekly', 'monthly')),

    CONSTRAINT FK_user_preferences_users
        FOREIGN KEY (user_id)
        REFERENCES dbo.users(id_user)
        ON DELETE CASCADE
);
GO


/* 
   4. DIETARY CATEGORIES
   */

CREATE TABLE dbo.dietary_categories (
    id_category INT IDENTITY(1,1) NOT NULL,
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500) NULL,

    CONSTRAINT PK_dietary_categories PRIMARY KEY (id_category),
    CONSTRAINT UQ_dietary_categories_name UNIQUE (name)
);
GO


/* 
   5. USER DIETARY CATEGORIES
   */

CREATE TABLE dbo.user_dietary_categories (
    user_id INT NOT NULL,
    category_id INT NOT NULL,

    CONSTRAINT PK_user_dietary_categories
        PRIMARY KEY (user_id, category_id),

    CONSTRAINT FK_user_categories_users
        FOREIGN KEY (user_id)
        REFERENCES dbo.users(id_user)
        ON DELETE CASCADE,

    CONSTRAINT FK_user_categories_categories
        FOREIGN KEY (category_id)
        REFERENCES dbo.dietary_categories(id_category)
        ON DELETE CASCADE
);
GO


/* 
   6. ALLERGIES
    */

CREATE TABLE dbo.allergies (
    id_allergy INT IDENTITY(1,1) NOT NULL,
    name NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_allergies PRIMARY KEY (id_allergy),
    CONSTRAINT UQ_allergies_name UNIQUE (name)
);
GO


/* 
   7. USER ALLERGIES
   */

CREATE TABLE dbo.user_allergies (
    user_id INT NOT NULL,
    allergy_id INT NOT NULL,

    CONSTRAINT PK_user_allergies
        PRIMARY KEY (user_id, allergy_id),

    CONSTRAINT FK_user_allergies_users
        FOREIGN KEY (user_id)
        REFERENCES dbo.users(id_user)
        ON DELETE CASCADE,

    CONSTRAINT FK_user_allergies_allergies
        FOREIGN KEY (allergy_id)
        REFERENCES dbo.allergies(id_allergy)
        ON DELETE CASCADE
);
GO


/* 
   8. APPLIANCES
   */

CREATE TABLE dbo.appliances (
    id_appliance INT IDENTITY(1,1) NOT NULL,
    name NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_appliances PRIMARY KEY (id_appliance),
    CONSTRAINT UQ_appliances_name UNIQUE (name)
);
GO


/* 
   9. USER APPLIANCES
    */

CREATE TABLE dbo.user_appliances (
    user_id INT NOT NULL,
    appliance_id INT NOT NULL,

    CONSTRAINT PK_user_appliances
        PRIMARY KEY (user_id, appliance_id),

    CONSTRAINT FK_user_appliances_users
        FOREIGN KEY (user_id)
        REFERENCES dbo.users(id_user)
        ON DELETE CASCADE,

    CONSTRAINT FK_user_appliances_appliances
        FOREIGN KEY (appliance_id)
        REFERENCES dbo.appliances(id_appliance)
        ON DELETE CASCADE
);
GO


/* 
   10. RECIPES
    */

CREATE TABLE dbo.recipes (
    id_recipe INT IDENTITY(1,1) NOT NULL,
    name NVARCHAR(150) NOT NULL,
    description NVARCHAR(MAX) NULL,
    instructions NVARCHAR(MAX) NOT NULL,
    preparation_time INT NULL,
    cooking_time INT NULL,
    estimated_cost DECIMAL(8,2) NOT NULL,
    servings INT NOT NULL,
    image NVARCHAR(255) NULL,

    CONSTRAINT PK_recipes PRIMARY KEY (id_recipe),

    CONSTRAINT CK_recipes_cost
        CHECK (estimated_cost >= 0),

    CONSTRAINT CK_recipes_servings
        CHECK (servings > 0),

    CONSTRAINT CK_recipes_preparation_time
        CHECK (preparation_time >= 0 OR preparation_time IS NULL),

    CONSTRAINT CK_recipes_cooking_time
        CHECK (cooking_time >= 0 OR cooking_time IS NULL)
);
GO


/* 
   11. INGREDIENTS
   */

CREATE TABLE dbo.ingredients (
    id_ingredient INT IDENTITY(1,1) NOT NULL,
    name NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_ingredients PRIMARY KEY (id_ingredient),
    CONSTRAINT UQ_ingredients_name UNIQUE (name)
);
GO


/* 
   12. RECIPE INGREDIENTS
   */

CREATE TABLE dbo.recipe_ingredients (
    recipe_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    quantity DECIMAL(10,2) NULL,
    unit NVARCHAR(30) NULL,

    CONSTRAINT PK_recipe_ingredients
        PRIMARY KEY (recipe_id, ingredient_id),

    CONSTRAINT CK_recipe_ingredients_quantity
        CHECK (quantity >= 0 OR quantity IS NULL),

    CONSTRAINT FK_recipe_ingredients_recipes
        FOREIGN KEY (recipe_id)
        REFERENCES dbo.recipes(id_recipe)
        ON DELETE CASCADE,

    CONSTRAINT FK_recipe_ingredients_ingredients
        FOREIGN KEY (ingredient_id)
        REFERENCES dbo.ingredients(id_ingredient)
        ON DELETE CASCADE
);
GO


/* 
   13. RECIPE CATEGORIES
  */

CREATE TABLE dbo.recipe_categories (
    recipe_id INT NOT NULL,
    category_id INT NOT NULL,

    CONSTRAINT PK_recipe_categories
        PRIMARY KEY (recipe_id, category_id),

    CONSTRAINT FK_recipe_categories_recipes
        FOREIGN KEY (recipe_id)
        REFERENCES dbo.recipes(id_recipe)
        ON DELETE CASCADE,

    CONSTRAINT FK_recipe_categories_categories
        FOREIGN KEY (category_id)
        REFERENCES dbo.dietary_categories(id_category)
        ON DELETE CASCADE
);
GO


/* 
   14. RECIPE APPLIANCES
   */

CREATE TABLE dbo.recipe_appliances (
    recipe_id INT NOT NULL,
    appliance_id INT NOT NULL,

    CONSTRAINT PK_recipe_appliances
        PRIMARY KEY (recipe_id, appliance_id),

    CONSTRAINT FK_recipe_appliances_recipes
        FOREIGN KEY (recipe_id)
        REFERENCES dbo.recipes(id_recipe)
        ON DELETE CASCADE,

    CONSTRAINT FK_recipe_appliances_appliances
        FOREIGN KEY (appliance_id)
        REFERENCES dbo.appliances(id_appliance)
        ON DELETE CASCADE
);
GO


/* 
   15. RECIPE ALLERGIES
   */

CREATE TABLE dbo.recipe_allergies (
    recipe_id INT NOT NULL,
    allergy_id INT NOT NULL,

    CONSTRAINT PK_recipe_allergies
        PRIMARY KEY (recipe_id, allergy_id),

    CONSTRAINT FK_recipe_allergies_recipes
        FOREIGN KEY (recipe_id)
        REFERENCES dbo.recipes(id_recipe)
        ON DELETE CASCADE,

    CONSTRAINT FK_recipe_allergies_allergies
        FOREIGN KEY (allergy_id)
        REFERENCES dbo.allergies(id_allergy)
        ON DELETE CASCADE
);
GO


/* 
   16. SAVED RECIPES
    */

CREATE TABLE dbo.saved_recipes (
    user_id INT NOT NULL,
    recipe_id INT NOT NULL,
    saved_at DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT PK_saved_recipes
        PRIMARY KEY (user_id, recipe_id),

    CONSTRAINT FK_saved_recipes_users
        FOREIGN KEY (user_id)
        REFERENCES dbo.users(id_user)
        ON DELETE CASCADE,

    CONSTRAINT FK_saved_recipes_recipes
        FOREIGN KEY (recipe_id)
        REFERENCES dbo.recipes(id_recipe)
        ON DELETE CASCADE
);
GO


/* 
   17. FOOD BANKS
   */

CREATE TABLE dbo.food_banks (
    id_food_bank INT IDENTITY(1,1) NOT NULL,
    name NVARCHAR(150) NOT NULL,
    address NVARCHAR(255) NOT NULL,
    postal_code NVARCHAR(20) NULL,
    city NVARCHAR(100) NOT NULL,
    latitude DECIMAL(10,7) NULL,
    longitude DECIMAL(10,7) NULL,
    opening_hours NVARCHAR(MAX) NULL,
    phone NVARCHAR(30) NULL,

    CONSTRAINT PK_food_banks PRIMARY KEY (id_food_bank),

    CONSTRAINT CK_food_banks_latitude
        CHECK (latitude BETWEEN -90 AND 90 OR latitude IS NULL),

    CONSTRAINT CK_food_banks_longitude
        CHECK (longitude BETWEEN -180 AND 180 OR longitude IS NULL)
);
GO


/* 
   18. INITIAL DIETARY CATEGORIES
    */

INSERT INTO dbo.dietary_categories (name, description)
VALUES
(N'Vegan', N'No animal products'),
(N'Vegetarian', N'No meat or fish'),
(N'Lactose-free', N'No lactose'),
(N'Gluten-free', N'No gluten'),
(N'Pescatarian', N'Fish and seafood allowed, no meat'),
(N'Regular', N'No specific dietary restrictions');
GO


/* 
   19. INITIAL APPLIANCES
    */

INSERT INTO dbo.appliances (name)
VALUES
(N'Oven'),
(N'Microwave'),
(N'Stovetop'),
(N'Air fryer'),
(N'Blender'),
(N'Food processor'),
(N'Rice cooker');
GO


/* 
   20. INITIAL ALLERGIES
    */

INSERT INTO dbo.allergies (name)
VALUES
(N'Peanuts'),
(N'Tree nuts'),
(N'Milk'),
(N'Eggs'),
(N'Soy'),
(N'Fish'),
(N'Shellfish'),
(N'Wheat'),
(N'Sesame');
GO


/* 
   21. INDEXES
    */

CREATE INDEX IX_user_preferences_user_id
    ON dbo.user_preferences(user_id);

CREATE INDEX IX_user_categories_category_id
    ON dbo.user_dietary_categories(category_id);

CREATE INDEX IX_recipe_categories_category_id
    ON dbo.recipe_categories(category_id);

CREATE INDEX IX_recipe_ingredients_ingredient_id
    ON dbo.recipe_ingredients(ingredient_id);

CREATE INDEX IX_food_banks_city
    ON dbo.food_banks(city);
GO


/* 
   22. DATABASE VERIFICATION
    */

-- Display all tables.
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;


-- Display the number of dietary categories.
SELECT COUNT(*) AS total_dietary_categories
FROM dbo.dietary_categories;


-- Display all dietary categories.
SELECT *
FROM dbo.dietary_categories
ORDER BY id_category;


-- Display all appliances.
SELECT *
FROM dbo.appliances
ORDER BY id_appliance;


-- Display all allergies.
SELECT *
FROM dbo.allergies
ORDER BY id_allergy;
GO

