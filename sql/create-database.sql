USE master;
GO

IF DB_ID('foodiz') IS NOT NULL
BEGIN
    ALTER DATABASE foodiz SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE foodiz;
END;
GO

CREATE DATABASE foodiz;
GO

USE foodiz;
GO

/* -----------------------------------------------------------------------------
   Connexion (login) et utilisateur (user)
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
    WITH PASSWORD = 'Test1234=', 
    DEFAULT_DATABASE = foodiz, 
    CHECK_POLICY = OFF;


GO
USE foodiz;


GO
CREATE USER demo_user 
FOR LOGIN demo_user;


GO
-- Droits minimaux : lecture + écriture sur les données.
-- On évite db_owner, qui donnerait tous les droits (dont DROP TABLE).
ALTER ROLE db_datareader ADD MEMBER demo_user;

ALTER ROLE db_datawriter ADD MEMBER demo_user;


GO

/*
   1. USERS
 */

CREATE TABLE dbo.users (
    id_user INT IDENTITY(1,1) NOT NULL,
    firstname NVARCHAR(100) NOT NULL,
    lastname NVARCHAR(100) NOT NULL,
    email NVARCHAR(150) NOT NULL,
    password NVARCHAR(255) NOT NULL,
    role VARCHAR(10) NOT NULL DEFAULT 'user',
    created_at DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT PK_users PRIMARY KEY (id_user),
    CONSTRAINT UQ_users_email UNIQUE (email)
);
GO

/*
   2. USER PREFERENCES
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
    CONSTRAINT CK_user_preferences_budget CHECK (budget > 0),
    CONSTRAINT CK_user_preferences_people CHECK (number_of_people > 0),
    CONSTRAINT CK_user_preferences_period
        CHECK (budget_period IN ('weekly', 'monthly')),
    CONSTRAINT CK_user_preferences_time
        CHECK (max_cooking_time > 0 OR max_cooking_time IS NULL),
    CONSTRAINT FK_user_preferences_users FOREIGN KEY (user_id)
        REFERENCES dbo.users(id_user) ON DELETE CASCADE
);
GO

/*
   3. DIETARY CATEGORIES
*/

CREATE TABLE dbo.dietary_categories (
    id_category INT IDENTITY(1,1) NOT NULL,
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500) NULL,

    CONSTRAINT PK_dietary_categories PRIMARY KEY (id_category),
    CONSTRAINT UQ_dietary_categories_name UNIQUE (name)
);
GO

CREATE TABLE dbo.user_dietary_categories (
    user_id INT NOT NULL,
    category_id INT NOT NULL,

    CONSTRAINT PK_user_dietary_categories
        PRIMARY KEY (user_id, category_id),

    CONSTRAINT FK_user_categories_users FOREIGN KEY (user_id)
        REFERENCES dbo.users(id_user) ON DELETE CASCADE,

    CONSTRAINT FK_user_categories_categories FOREIGN KEY (category_id)
        REFERENCES dbo.dietary_categories(id_category) ON DELETE CASCADE
);
GO

/*
   4. ALLERGIES
 */

CREATE TABLE dbo.allergies (
    id_allergy INT IDENTITY(1,1) NOT NULL,
    name NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_allergies PRIMARY KEY (id_allergy),
    CONSTRAINT UQ_allergies_name UNIQUE (name)
);
GO

CREATE TABLE dbo.user_allergies (
    user_id INT NOT NULL,
    allergy_id INT NOT NULL,

    CONSTRAINT PK_user_allergies
        PRIMARY KEY (user_id, allergy_id),

    CONSTRAINT FK_user_allergies_users FOREIGN KEY (user_id)
        REFERENCES dbo.users(id_user) ON DELETE CASCADE,

    CONSTRAINT FK_user_allergies_allergies FOREIGN KEY (allergy_id)
        REFERENCES dbo.allergies(id_allergy) ON DELETE CASCADE
);
GO

/*
   5. APPLIANCES
*/

CREATE TABLE dbo.appliances (
    id_appliance INT IDENTITY(1,1) NOT NULL,
    name NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_appliances PRIMARY KEY (id_appliance),
    CONSTRAINT UQ_appliances_name UNIQUE (name)
);
GO

CREATE TABLE dbo.user_appliances (
    user_id INT NOT NULL,
    appliance_id INT NOT NULL,

    CONSTRAINT PK_user_appliances
        PRIMARY KEY (user_id, appliance_id),

    CONSTRAINT FK_user_appliances_users FOREIGN KEY (user_id)
        REFERENCES dbo.users(id_user) ON DELETE CASCADE,

    CONSTRAINT FK_user_appliances_appliances FOREIGN KEY (appliance_id)
        REFERENCES dbo.appliances(id_appliance) ON DELETE CASCADE
);
GO

/*
   6. RECIPES
*/

CREATE TABLE dbo.recipes (
    id_recipe VARCHAR(10) NOT NULL,
    name NVARCHAR(150) NOT NULL,
    description NVARCHAR(MAX) NULL,
    instructions NVARCHAR(MAX) NOT NULL,
    preparation_time INT NULL,
    cooking_time INT NULL,
    estimated_cost DECIMAL(8,2) NOT NULL,
    image NVARCHAR(255) NULL,

    CONSTRAINT PK_recipes PRIMARY KEY (id_recipe),
    CONSTRAINT UQ_recipes_name UNIQUE (name),
    CONSTRAINT CK_recipes_cost CHECK (estimated_cost >= 0),
    CONSTRAINT CK_recipes_preparation_time
        CHECK (preparation_time >= 0 OR preparation_time IS NULL),
    CONSTRAINT CK_recipes_cooking_time
        CHECK (cooking_time >= 0 OR cooking_time IS NULL)
);
GO

/*
   7. INGREDIENTS
 */

CREATE TABLE dbo.ingredients (
    id_ingredient INT IDENTITY(1,1) NOT NULL,
    name NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_ingredients PRIMARY KEY (id_ingredient),
    CONSTRAINT UQ_ingredients_name UNIQUE (name)
);
GO

/*
   8. RECIPE INGREDIENTS
 */

CREATE TABLE dbo.recipe_ingredients (
    recipe_id VARCHAR(10) NOT NULL,
    ingredient_id INT NOT NULL,
    quantity DECIMAL(10,2) NULL,
    unit NVARCHAR(30) NULL,

    CONSTRAINT PK_recipe_ingredients
        PRIMARY KEY (recipe_id, ingredient_id),

    CONSTRAINT CK_recipe_ingredients_quantity
        CHECK (quantity >= 0 OR quantity IS NULL),

    CONSTRAINT FK_recipe_ingredients_recipes FOREIGN KEY (recipe_id)
        REFERENCES dbo.recipes(id_recipe) ON DELETE CASCADE,

    CONSTRAINT FK_recipe_ingredients_ingredients FOREIGN KEY (ingredient_id)
        REFERENCES dbo.ingredients(id_ingredient) ON DELETE CASCADE
);
GO

/* 
   9. RECIPE CATEGORIES
 */

CREATE TABLE dbo.recipe_categories (
    recipe_id VARCHAR(10) NOT NULL,
    category_id INT NOT NULL,

    CONSTRAINT PK_recipe_categories
        PRIMARY KEY (recipe_id, category_id),

    CONSTRAINT FK_recipe_categories_recipes FOREIGN KEY (recipe_id)
        REFERENCES dbo.recipes(id_recipe) ON DELETE CASCADE,

    CONSTRAINT FK_recipe_categories_categories FOREIGN KEY (category_id)
        REFERENCES dbo.dietary_categories(id_category) ON DELETE CASCADE
);
GO

/* 
   10. RECIPE APPLIANCES
   */

CREATE TABLE dbo.recipe_appliances (
    recipe_id VARCHAR(10) NOT NULL,
    appliance_id INT NOT NULL,

    CONSTRAINT PK_recipe_appliances
        PRIMARY KEY (recipe_id, appliance_id),

    CONSTRAINT FK_recipe_appliances_recipes FOREIGN KEY (recipe_id)
        REFERENCES dbo.recipes(id_recipe) ON DELETE CASCADE,

    CONSTRAINT FK_recipe_appliances_appliances FOREIGN KEY (appliance_id)
        REFERENCES dbo.appliances(id_appliance) ON DELETE CASCADE
);
GO

/*
   11. RECIPE ALLERGIES
   */

CREATE TABLE dbo.recipe_allergies (
    recipe_id VARCHAR(10) NOT NULL,
    allergy_id INT NOT NULL,

    CONSTRAINT PK_recipe_allergies
        PRIMARY KEY (recipe_id, allergy_id),

    CONSTRAINT FK_recipe_allergies_recipes FOREIGN KEY (recipe_id)
        REFERENCES dbo.recipes(id_recipe) ON DELETE CASCADE,

    CONSTRAINT FK_recipe_allergies_allergies FOREIGN KEY (allergy_id)
        REFERENCES dbo.allergies(id_allergy) ON DELETE CASCADE
);
GO

/* 
   12. SAVED RECIPES
   */

CREATE TABLE dbo.saved_recipes (
    user_id INT NOT NULL,
    recipe_id VARCHAR(10) NOT NULL,
    saved_at DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT PK_saved_recipes
        PRIMARY KEY (user_id, recipe_id),

    CONSTRAINT FK_saved_recipes_users FOREIGN KEY (user_id)
        REFERENCES dbo.users(id_user) ON DELETE CASCADE,

    CONSTRAINT FK_saved_recipes_recipes FOREIGN KEY (recipe_id)
        REFERENCES dbo.recipes(id_recipe) ON DELETE CASCADE
);
GO

/* 

   13. FOOD BANKS
  */

CREATE TABLE dbo.food_banks (
    id_food_bank INT IDENTITY(1,1) NOT NULL,
    name NVARCHAR(150) NOT NULL,
    category NVARCHAR(100) NOT NULL,
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
   14. INDEXES
 */

CREATE INDEX IX_user_categories_category_id
ON dbo.user_dietary_categories(category_id);

CREATE INDEX IX_user_allergies_allergy_id
ON dbo.user_allergies(allergy_id);

CREATE INDEX IX_user_appliances_appliance_id
ON dbo.user_appliances(appliance_id);

CREATE INDEX IX_recipe_categories_category_id
ON dbo.recipe_categories(category_id);

CREATE INDEX IX_recipe_ingredients_ingredient_id
ON dbo.recipe_ingredients(ingredient_id);

CREATE INDEX IX_recipe_appliances_appliance_id
ON dbo.recipe_appliances(appliance_id);

CREATE INDEX IX_recipe_allergies_allergy_id
ON dbo.recipe_allergies(allergy_id);

CREATE INDEX IX_food_banks_city
ON dbo.food_banks(city);
GO

/*
   15. SEED DATA
  */

/* Dietary categories */

INSERT INTO dbo.dietary_categories (name, description)
VALUES
('Vegan', 'No animal products'),
('Vegetarian', 'No meat or fish'),
('Lactose-free', 'No lactose'),
('Gluten-free', 'No gluten'),
('Pescatarian', 'Fish and seafood allowed, no meat'),
('Regular', 'No specific dietary restrictions');
GO

/* Appliances */

INSERT INTO dbo.appliances (name)
VALUES
('Oven'),
('Microwave'),
('Stovetop'),
('Air fryer'),
('Blender'),
('Food processor'),
('Rice cooker');
GO

/* Allergies */

INSERT INTO dbo.allergies (name)
VALUES
('Peanuts'),
('Tree nuts'),
('Milk'),
('Eggs'),
('Soy'),
('Fish'),
('Shellfish'),
('Wheat'),
('Sesame');
GO

INSERT INTO dbo.recipes (
    id_recipe,
    name,
    description,
    instructions,
    preparation_time,
    cooking_time,
    estimated_cost,
    image
)
VALUES
('R001', 'Chickpea Coconut Curry',
 'A creamy vegan curry made with chickpeas, coconut milk and spices.',
 'Chop the onion and tomatoes. Cook the onion with garlic and curry powder. Add chickpeas, tomatoes and coconut milk. Simmer for 15 minutes. Serve with cooked rice.',
 10, 20, 2.80, 'images/chickpea-coconut-curry.jpg'),

('R002', 'Lentil Bolognese',
 'A plant-based alternative to traditional Bolognese sauce.',
 'Cook the lentils. Chop the onion and carrot. Cook the vegetables with garlic, then add tomato sauce and lentils. Simmer for 20 minutes. Serve with cooked spaghetti.',
 15, 25, 2.20, 'images/lentil-bolognese.jpg'),

('R003', 'Tofu Vegetable Stir-Fry',
 'A quick vegan stir-fry with tofu and fresh vegetables.',
 'Cut the tofu and vegetables into pieces. Cook the tofu in a pan. Add broccoli, carrots and tamari sauce. Cook until the vegetables are tender. Serve with rice.',
 10, 15, 2.90, 'images/tofu-vegetable-stir-fry.jpg'),

('R004', 'Sweet Potato and Black Bean Bowl',
 'A colourful bowl with roasted sweet potatoes and black beans.',
 'Cut the sweet potato into cubes and roast until tender. Heat the black beans. Prepare the rice. Serve everything in a bowl with lettuce and olive oil.',
 10, 25, 2.50, 'images/sweet-potato-black-bean-bowl.jpg'),

('R005', 'Red Lentil Soup',
 'A comforting soup made with red lentils and vegetables.',
 'Chop the onion and carrot. Cook them with garlic. Add red lentils and vegetable stock. Simmer until the lentils are soft. Blend the soup if desired.',
 10, 25, 1.80, 'images/red-lentil-soup.jpg'),

('R006', 'Falafel Pita',
 'A vegan pita sandwich filled with falafel and fresh vegetables.',
 'Mash the chickpeas with garlic and parsley. Add flour and spices. Shape into small balls and cook in a pan. Serve inside pita bread with lettuce and tahini.',
 15, 15, 2.60, 'images/falafel-pita.jpg'),

('R007', 'Stuffed Bell Peppers',
 'Bell peppers filled with rice, beans and vegetables.',
 'Cut the top of the bell pepper and remove the seeds. Mix cooked rice with black beans, tomatoes and onion. Fill the pepper and bake until tender.',
 15, 30, 2.40, 'images/stuffed-bell-peppers.jpg'),

('R008', 'Spinach and Ricotta Lasagna',
 'A vegetarian lasagna with spinach, ricotta and tomato sauce.',
 'Cook the spinach. Mix it with ricotta. Layer lasagna sheets, spinach mixture and tomato sauce in a baking dish. Add mozzarella and bake until golden.',
 15, 35, 3.50, 'images/spinach-ricotta-lasagna.jpg'),

('R009', 'Creamy Mushroom Risotto',
 'A creamy Italian risotto with mushrooms and Parmesan.',
 'Cook the onion and mushrooms in olive oil. Add Arborio rice. Gradually add vegetable stock while stirring. Finish with cream and Parmesan.',
 10, 25, 3.20, 'images/mushroom-risotto.jpg'),

('R010', 'Vegetable Quiche',
 'A savoury vegetarian quiche with vegetables and cheese.',
 'Place the shortcrust pastry in a baking dish. Whisk eggs with cream. Add spinach, zucchini and grated cheese. Pour the mixture over the pastry and bake until set.',
 15, 35, 3.00, 'images/vegetable-quiche.jpg'),

('R011', 'Pesto Mozzarella Pasta',
 'A simple pasta dish with basil pesto and mozzarella.',
 'Cook the pasta. Drain and mix with basil pesto. Add cherry tomatoes and mozzarella. Mix well and serve.',
 5, 15, 2.70, 'images/pesto-mozzarella-pasta.jpg'),

('R012', 'Sweet Potato and Feta Salad',
 'A fresh vegetarian salad with sweet potato, feta and walnuts.',
 'Cut the sweet potato into cubes and roast until tender. Mix with lettuce, feta and walnuts. Add olive oil and lemon juice.',
 10, 25, 3.00, 'images/sweet-potato-feta-salad.jpg'),

('R013', 'Classic Shakshuka',
 'Eggs cooked in a flavourful tomato and pepper sauce.',
 'Cook the onion and bell pepper in olive oil. Add tomatoes and spices. Simmer until the sauce thickens. Make small spaces and crack the eggs into them. Cook until set.',
 10, 20, 2.20, 'images/classic-shakshuka.jpg'),

('R014', 'Spinach and Cheese Stuffed Shells',
 'Pasta shells filled with spinach and ricotta cheese.',
 'Cook the pasta shells. Mix cooked spinach with ricotta. Fill each shell with the mixture. Cover with tomato sauce and mozzarella. Bake until golden.',
 15, 25, 3.40, 'images/spinach-cheese-stuffed-shells.jpg'),

('R015', 'Lemon Garlic Chicken and Rice',
 'Chicken breast served with lemon, garlic and rice.',
 'Season the chicken with lemon juice, garlic and olive oil. Cook in a pan until fully cooked. Prepare the rice and serve with the chicken.',
 10, 20, 3.50, 'images/lemon-garlic-chicken-rice.jpg'),

('R016', 'Baked Salmon and Potatoes',
 'Oven-baked salmon served with roasted potatoes.',
 'Cut the potatoes into pieces. Season with olive oil and parsley. Bake until nearly tender. Add the salmon with lemon juice and bake until cooked through.',
 10, 30, 4.80, 'images/baked-salmon-potatoes.jpg'),

('R017', 'Chicken Coconut Curry',
 'Chicken cooked in a creamy coconut curry sauce.',
 'Cut the chicken into pieces. Cook the onion and garlic. Add chicken and curry powder. Pour in coconut milk and simmer until the chicken is fully cooked. Serve with rice.',
 10, 25, 3.80, 'images/chicken-coconut-curry.jpg'),

('R018', 'Beef and Vegetable Tacos',
 'Tacos filled with seasoned beef and fresh vegetables.',
 'Cook the minced beef with onion and spices. Warm the corn tortillas. Add the beef, tomatoes and lettuce. Serve immediately.',
 10, 15, 3.50, 'images/beef-vegetable-tacos.jpg'),

('R019', 'Roasted Vegetable Quinoa Bowl',
 'A healthy bowl with quinoa and roasted vegetables.',
 'Cook the quinoa. Cut the zucchini and bell pepper into pieces. Roast the vegetables with olive oil. Serve over quinoa with lemon juice.',
 10, 25, 2.80, 'images/roasted-vegetable-quinoa-bowl.jpg'),

('R020', 'Tomato Basil Chicken Pasta',
 'Pasta with chicken, tomatoes and fresh basil.',
 'Cook the pasta. Cut and cook the chicken in a pan. Add cherry tomatoes and tomato sauce. Mix with the pasta and fresh basil.',
 10, 20, 3.40, 'images/tomato-basil-chicken-pasta.jpg'),

('R021', 'Garlic Shrimp Rice Bowl',
 'A rice bowl with garlic shrimp and fresh vegetables.',
 'Cook the rice. Cook the shrimp with garlic and olive oil until fully cooked. Add vegetables and serve over rice.',
 10, 15, 3.90, 'images/garlic-shrimp-rice-bowl.jpg'),

('R022', 'Chicken and Vegetable Rice Bowl',
 'A gluten-free rice bowl with chicken and vegetables.',
 'Cook the rice. Cut the chicken and vegetables into pieces. Cook the chicken thoroughly, then add the vegetables. Season and serve with rice.',
 10, 20, 3.50, 'images/chicken-vegetable-rice-bowl.jpg'),

('R023', 'Stuffed Zucchini Boats',
 'Zucchini halves filled with beef, tomatoes and vegetables.',
 'Cut the zucchini in half and remove some of the centre. Cook minced beef with onion and tomatoes. Fill the zucchini and bake until tender.',
 15, 30, 3.20, 'images/stuffed-zucchini-boats.jpg'),

('R024', 'Shrimp Rice Noodle Stir-Fry',
 'Rice noodles stir-fried with shrimp and vegetables.',
 'Prepare the rice noodles. Cook the shrimp with garlic. Add carrots and vegetables. Add the noodles and gluten-free soy sauce. Stir-fry briefly.',
 10, 15, 3.80, 'images/shrimp-rice-noodle-stir-fry.jpg'),

('R025', 'Sweet Potato and Bean Chili',
 'A hearty gluten-free chili with sweet potatoes and beans.',
 'Cut the sweet potato into cubes. Cook the onion and tomatoes. Add sweet potato, black beans and vegetable stock. Simmer until tender.',
 10, 30, 2.30, 'images/sweet-potato-bean-chili.jpg'),

('R026', 'Chicken and Quinoa Skillet',
 'A one-pan meal with chicken, quinoa and vegetables.',
 'Cut the chicken into pieces. Cook with onion and bell pepper. Add quinoa and vegetable stock. Simmer until the quinoa is cooked and the chicken is fully cooked.',
 10, 25, 3.60, 'images/chicken-quinoa-skillet.jpg'),

('R027', 'Tuna Stuffed Baked Potatoes',
 'Baked potatoes filled with tuna and fresh vegetables.',
 'Bake the potato until tender. Mix tuna with sweetcorn and olive oil. Cut the potato open and add the tuna mixture.',
 10, 35, 2.80, 'images/tuna-stuffed-baked-potatoes.jpg'),

('R028', 'Garden Vegetable Omelette',
 'A simple omelette with fresh vegetables.',
 'Beat the eggs. Chop the vegetables. Cook them briefly in a pan. Pour in the eggs and cook until the omelette is set.',
 5, 10, 1.80, 'images/garden-vegetable-omelette.jpg'),

('R029', 'Salmon Teriyaki Bowl',
 'A salmon rice bowl with a sweet and savoury teriyaki sauce.',
 'Cook the rice. Season the salmon with teriyaki sauce and cook thoroughly. Serve with cucumber and rice.',
 10, 20, 4.50, 'images/salmon-teriyaki-bowl.jpg'),

('R030', 'Mediterranean Tuna Pasta',
 'Pasta with tuna, tomatoes and black olives.',
 'Cook the pasta. Drain the tuna. Mix the pasta with tuna, cherry tomatoes, black olives and olive oil. Season and serve.',
 5, 15, 2.90, 'images/mediterranean-tuna-pasta.jpg'),

('R031', 'Garlic Shrimp Spaghetti',
 'Spaghetti with garlic shrimp and fresh parsley.',
 'Cook the spaghetti. Cook the shrimp with garlic and olive oil until fully cooked. Add parsley and mix with the spaghetti.',
 5, 15, 3.50, 'images/garlic-shrimp-spaghetti.jpg'),

('R032', 'Baked Cod and Vegetables',
 'Oven-baked cod served with roasted vegetables.',
 'Cut the vegetables into pieces and roast with olive oil. Add the cod with lemon juice and parsley. Bake until the fish is cooked through.',
 10, 25, 4.20, 'images/baked-cod-vegetables.jpg'),

('R033', 'Salmon and Avocado Sushi Bowl',
 'A sushi-inspired bowl with salmon, avocado and cucumber.',
 'Cook the sushi rice and season with rice vinegar. Cook the salmon thoroughly and cut into pieces. Serve with avocado and cucumber.',
 15, 20, 4.80, 'images/salmon-avocado-sushi-bowl.jpg'),

('R034', 'Creamy Salmon Spinach Pasta',
 'Pasta with salmon, spinach and lactose-free cream.',
 'Cook the pasta. Cook the salmon thoroughly. Add spinach and lactose-free cream. Simmer briefly and mix with the pasta.',
 10, 20, 4.20, 'images/creamy-salmon-spinach-pasta.jpg'),

('R035', 'Tuna and Chickpea Salad',
 'A fresh salad with tuna, chickpeas and vegetables.',
 'Drain the tuna and chickpeas. Mix with lettuce, tomatoes and red onion. Add lemon juice and olive oil.',
 10, 0, 2.80, 'images/tuna-chickpea-salad.jpg'),

('R036', 'Spaghetti Bolognese',
 'Classic spaghetti served with a rich beef and tomato sauce.',
 'Cook the spaghetti. Brown the minced beef with onion and carrot. Add tomato sauce and simmer. Serve over the spaghetti.',
 10, 25, 3.20, 'images/spaghetti-bolognese.jpg'),

('R037', 'Creamy Chicken Mushroom Pasta',
 'Pasta with chicken, mushrooms and creamy sauce.',
 'Cook the pasta. Cook the chicken and mushrooms in a pan. Add cream and season. Mix with the pasta and serve.',
 10, 20, 3.50, 'images/creamy-chicken-mushroom-pasta.jpg'),

('R038', 'Classic Beef Burger',
 'A homemade beef burger with cheese and fresh vegetables.',
 'Shape the minced beef into a patty and cook thoroughly. Toast the burger bun. Add cheddar, lettuce and tomato. Assemble the burger.',
 10, 15, 3.80, 'images/classic-beef-burger.jpg'),

('R039', 'Chicken Fajitas',
 'Chicken strips cooked with peppers and fajita seasoning.',
 'Cut the chicken and peppers into strips. Cook the chicken thoroughly with fajita seasoning. Add the peppers and onion. Serve in warm tortillas.',
 10, 15, 3.40, 'images/chicken-fajitas.jpg'),

('R040', 'Chicken Parmesan',
 'Breaded chicken topped with tomato sauce and mozzarella.',
 'Coat the chicken in flour, egg and breadcrumbs. Cook until golden and fully cooked. Add tomato sauce and mozzarella. Bake until the cheese melts.',
 15, 25, 3.90, 'images/chicken-parmesan.jpg'),

('R041', 'Classic Beef Lasagna',
 'Traditional lasagna with minced beef, tomato sauce and cheese.',
 'Cook the minced beef with onion and tomato sauce. Layer the sauce with lasagna sheets and cheese. Bake until the pasta is tender and the top is golden.',
 20, 40, 4.00, 'images/classic-beef-lasagna.jpg'),

('R042', 'Chicken Fried Rice',
 'Fried rice with chicken, vegetables and soy sauce.',
 'Cook the rice and let it cool. Cut and cook the chicken thoroughly. Add vegetables and rice. Stir-fry with soy sauce until heated through.',
 10, 15, 3.20, 'images/chicken-fried-rice.jpg');
GO



DECLARE @RecipeIngredients TABLE (
    recipe_id VARCHAR(10),
    ingredient_name NVARCHAR(100),
    quantity DECIMAL(10,2),
    unit NVARCHAR(30)
); 

INSERT INTO @RecipeIngredients
(recipe_id, ingredient_name, quantity, unit)
VALUES

/* R001 - Chickpea Coconut Curry */
('R001', 'Chickpeas', 120, 'g'),
('R001', 'Coconut milk', 100, 'ml'),
('R001', 'Tomatoes', 100, 'g'),
('R001', 'Onion', 50, 'g'),
('R001', 'Rice', 75, 'g'),

/* R002 - Lentil Bolognese */
('R002', 'Red lentils', 80, 'g'),
('R002', 'Spaghetti', 100, 'g'),
('R002', 'Carrot', 50, 'g'),
('R002', 'Tomato sauce', 120, 'ml'),
('R002', 'Onion', 50, 'g'),

/* R003 - Tofu Vegetable Stir-Fry */
('R003', 'Tofu', 120, 'g'),
('R003', 'Broccoli', 80, 'g'),
('R003', 'Carrot', 50, 'g'),
('R003', 'Rice', 75, 'g'),
('R003', 'Tamari sauce', 15, 'ml'),

/* R004 - Sweet Potato and Black Bean Bowl */
('R004', 'Sweet potato', 150, 'g'),
('R004', 'Black beans', 100, 'g'),
('R004', 'Rice', 60, 'g'),
('R004', 'Lettuce', 30, 'g'),
('R004', 'Olive oil', 10, 'ml'),

/* R005 - Red Lentil Soup */
('R005', 'Red lentils', 100, 'g'),
('R005', 'Carrot', 60, 'g'),
('R005', 'Onion', 50, 'g'),
('R005', 'Garlic', 5, 'g'),
('R005', 'Vegetable stock', 300, 'ml'),

/* R006 - Falafel Pita */
('R006', 'Chickpeas', 120, 'g'),
('R006', 'Pita bread', 1, 'piece'),
('R006', 'Tahini', 15, 'g'),
('R006', 'Parsley', 10, 'g'),
('R006', 'Garlic', 5, 'g'),
('R006', 'Chickpea flour', 20, 'g'),

/* R007 - Stuffed Bell Peppers */
('R007', 'Bell pepper', 1, 'piece'),
('R007', 'Rice', 60, 'g'),
('R007', 'Black beans', 80, 'g'),
('R007', 'Tomatoes', 80, 'g'),
('R007', 'Onion', 40, 'g'),

/* R008 - Spinach and Ricotta Lasagna */
('R008', 'Lasagna sheets', 100, 'g'),
('R008', 'Spinach', 100, 'g'),
('R008', 'Ricotta', 80, 'g'),
('R008', 'Mozzarella', 40, 'g'),
('R008', 'Tomato sauce', 100, 'ml'),

/* R009 - Creamy Mushroom Risotto */
('R009', 'Arborio rice', 90, 'g'),
('R009', 'Mushrooms', 100, 'g'),
('R009', 'Parmesan', 25, 'g'),
('R009', 'Cream', 30, 'ml'),
('R009', 'Vegetable stock', 250, 'ml'),

/* R010 - Vegetable Quiche */
('R010', 'Shortcrust pastry', 100, 'g'),
('R010', 'Eggs', 2, 'piece'),
('R010', 'Cream', 50, 'ml'),
('R010', 'Spinach', 50, 'g'),
('R010', 'Grated cheese', 30, 'g'),
('R010', 'Zucchini', 50, 'g'),

/* R011 - Pesto Mozzarella Pasta */
('R011', 'Pasta', 100, 'g'),
('R011', 'Basil pesto', 25, 'g'),
('R011', 'Mozzarella', 60, 'g'),
('R011', 'Cherry tomatoes', 80, 'g'),
('R011', 'Olive oil', 5, 'ml'),

/* R012 - Sweet Potato and Feta Salad */
('R012', 'Sweet potato', 150, 'g'),
('R012', 'Feta cheese', 50, 'g'),
('R012', 'Lettuce', 50, 'g'),
('R012', 'Walnuts', 15, 'g'),
('R012', 'Lemon', 0.5, 'piece'),

/* R013 - Classic Shakshuka */
('R013', 'Eggs', 2, 'piece'),
('R013', 'Tomatoes', 150, 'g'),
('R013', 'Bell pepper', 60, 'g'),
('R013', 'Onion', 40, 'g'),
('R013', 'Olive oil', 10, 'ml'),

/* R014 - Spinach and Cheese Stuffed Shells */
('R014', 'Pasta', 100, 'g'),
('R014', 'Spinach', 80, 'g'),
('R014', 'Ricotta', 70, 'g'),
('R014', 'Mozzarella', 40, 'g'),
('R014', 'Tomato sauce', 100, 'ml'),

/* R015 - Lemon Garlic Chicken and Rice */
('R015', 'Chicken breast', 150, 'g'),
('R015', 'Rice', 75, 'g'),
('R015', 'Garlic', 5, 'g'),
('R015', 'Lemon', 0.5, 'piece'),
('R015', 'Olive oil', 10, 'ml'),

/* R016 - Baked Salmon and Potatoes */
('R016', 'Salmon', 150, 'g'),
('R016', 'Potatoes', 200, 'g'),
('R016', 'Lemon', 0.5, 'piece'),
('R016', 'Parsley', 5, 'g'),
('R016', 'Olive oil', 10, 'ml'),

/* R017 - Chicken Coconut Curry */
('R017', 'Chicken breast', 150, 'g'),
('R017', 'Coconut milk', 100, 'ml'),
('R017', 'Rice', 75, 'g'),
('R017', 'Onion', 50, 'g'),
('R017', 'Garlic', 5, 'g'),

/* R018 - Beef and Vegetable Tacos */
('R018', 'Minced beef', 120, 'g'),
('R018', 'Corn tortillas', 2, 'piece'),
('R018', 'Tomatoes', 60, 'g'),
('R018', 'Lettuce', 30, 'g'),
('R018', 'Onion', 30, 'g'),

/* R019 - Roasted Vegetable Quinoa Bowl */
('R019', 'Quinoa', 75, 'g'),
('R019', 'Zucchini', 100, 'g'),
('R019', 'Bell pepper', 80, 'g'),
('R019', 'Lemon', 0.5, 'piece'),
('R019', 'Olive oil', 10, 'ml'),

/* R020 - Tomato Basil Chicken Pasta */
('R020', 'Chicken breast', 120, 'g'),
('R020', 'Pasta', 100, 'g'),
('R020', 'Cherry tomatoes', 100, 'g'),
('R020', 'Tomato sauce', 80, 'ml'),
('R020', 'Fresh basil', 5, 'g'),

/* R021 - Garlic Shrimp Rice Bowl */
('R021', 'Shrimp', 120, 'g'),
('R021', 'Rice', 75, 'g'),
('R021', 'Garlic', 5, 'g'),
('R021', 'Broccoli', 60, 'g'),
('R021', 'Olive oil', 10, 'ml'),

/* R022 - Chicken and Vegetable Rice Bowl */
('R022', 'Chicken breast', 150, 'g'),
('R022', 'Rice', 75, 'g'),
('R022', 'Carrot', 50, 'g'),
('R022', 'Broccoli', 60, 'g'),
('R022', 'Olive oil', 10, 'ml'),

/* R023 - Stuffed Zucchini Boats */
('R023', 'Zucchini', 1, 'piece'),
('R023', 'Minced beef', 100, 'g'),
('R023', 'Tomatoes', 80, 'g'),
('R023', 'Onion', 40, 'g'),
('R023', 'Olive oil', 10, 'ml'),

/* R024 - Shrimp Rice Noodle Stir-Fry */
('R024', 'Shrimp', 120, 'g'),
('R024', 'Rice noodles', 100, 'g'),
('R024', 'Carrot', 50, 'g'),
('R024', 'Broccoli', 60, 'g'),
('R024', 'Tamari sauce', 15, 'ml'),

/* R025 - Sweet Potato and Bean Chili */
('R025', 'Sweet potato', 150, 'g'),
('R025', 'Black beans', 100, 'g'),
('R025', 'Tomatoes', 100, 'g'),
('R025', 'Onion', 50, 'g'),
('R025', 'Vegetable stock', 150, 'ml'),

/* R026 - Chicken and Quinoa Skillet */
('R026', 'Chicken breast', 150, 'g'),
('R026', 'Quinoa', 75, 'g'),
('R026', 'Bell pepper', 60, 'g'),
('R026', 'Onion', 40, 'g'),
('R026', 'Vegetable stock', 150, 'ml'),

/* R027 - Tuna Stuffed Baked Potatoes */
('R027', 'Potatoes', 250, 'g'),
('R027', 'Canned tuna', 100, 'g'),
('R027', 'Sweetcorn', 50, 'g'),
('R027', 'Olive oil', 10, 'ml'),
('R027', 'Lemon', 0.5, 'piece'),

/* R028 - Garden Vegetable Omelette */
('R028', 'Eggs', 2, 'piece'),
('R028', 'Spinach', 40, 'g'),
('R028', 'Tomatoes', 50, 'g'),
('R028', 'Bell pepper', 40, 'g'),
('R028', 'Olive oil', 5, 'ml'),

/* R029 - Salmon Teriyaki Bowl */
('R029', 'Salmon', 150, 'g'),
('R029', 'Rice', 75, 'g'),
('R029', 'Cucumber', 50, 'g'),
('R029', 'Honey', 10, 'g'),
('R029', 'Tamari sauce', 15, 'ml'),

/* R030 - Mediterranean Tuna Pasta */
('R030', 'Pasta', 100, 'g'),
('R030', 'Canned tuna', 100, 'g'),
('R030', 'Cherry tomatoes', 80, 'g'),
('R030', 'Black olives', 20, 'g'),
('R030', 'Olive oil', 10, 'ml'),

/* R031 - Garlic Shrimp Spaghetti */
('R031', 'Shrimp', 120, 'g'),
('R031', 'Spaghetti', 100, 'g'),
('R031', 'Garlic', 5, 'g'),
('R031', 'Parsley', 5, 'g'),
('R031', 'Olive oil', 10, 'ml'),

/* R032 - Baked Cod and Vegetables */
('R032', 'Cod', 150, 'g'),
('R032', 'Potatoes', 100, 'g'),
('R032', 'Zucchini', 80, 'g'),
('R032', 'Lemon', 0.5, 'piece'),
('R032', 'Olive oil', 10, 'ml'),

/* R033 - Salmon and Avocado Sushi Bowl */
('R033', 'Salmon', 120, 'g'),
('R033', 'Sushi rice', 75, 'g'),
('R033', 'Avocado', 0.5, 'piece'),
('R033', 'Cucumber', 50, 'g'),
('R033', 'Rice vinegar', 10, 'ml'),

/* R034 - Creamy Salmon Spinach Pasta */
('R034', 'Salmon', 120, 'g'),
('R034', 'Pasta', 100, 'g'),
('R034', 'Spinach', 60, 'g'),
('R034', 'Lactose-free cream', 50, 'ml'),
('R034', 'Garlic', 5, 'g'),

/* R035 - Tuna and Chickpea Salad */
('R035', 'Canned tuna', 100, 'g'),
('R035', 'Chickpeas', 80, 'g'),
('R035', 'Lettuce', 50, 'g'),
('R035', 'Tomatoes', 60, 'g'),
('R035', 'Red onion', 20, 'g'),

/* R036 - Spaghetti Bolognese */
('R036', 'Spaghetti', 100, 'g'),
('R036', 'Minced beef', 120, 'g'),
('R036', 'Tomato sauce', 120, 'ml'),
('R036', 'Carrot', 40, 'g'),
('R036', 'Onion', 40, 'g'),

/* R037 - Creamy Chicken Mushroom Pasta */
('R037', 'Chicken breast', 120, 'g'),
('R037', 'Pasta', 100, 'g'),
('R037', 'Mushrooms', 80, 'g'),
('R037', 'Cream', 50, 'ml'),
('R037', 'Garlic', 5, 'g'),

/* R038 - Classic Beef Burger */
('R038', 'Minced beef', 150, 'g'),
('R038', 'Burger bun', 1, 'piece'),
('R038', 'Cheddar cheese', 20, 'g'),
('R038', 'Lettuce', 20, 'g'),
('R038', 'Tomatoes', 30, 'g'),

/* R039 - Chicken Fajitas */
('R039', 'Chicken breast', 150, 'g'),
('R039', 'Flour tortillas', 2, 'piece'),
('R039', 'Bell pepper', 80, 'g'),
('R039', 'Onion', 40, 'g'),
('R039', 'Fajita seasoning', 10, 'g'),

/* R040 - Chicken Parmesan */
('R040', 'Chicken breast', 150, 'g'),
('R040', 'Flour', 20, 'g'),
('R040', 'Breadcrumbs', 30, 'g'),
('R040', 'Eggs', 1, 'piece'),
('R040', 'Tomato sauce', 80, 'ml'),
('R040', 'Mozzarella', 40, 'g'),

/* R041 - Classic Beef Lasagna */
('R041', 'Minced beef', 120, 'g'),
('R041', 'Lasagna sheets', 100, 'g'),
('R041', 'Tomato sauce', 120, 'ml'),
('R041', 'Mozzarella', 40, 'g'),
('R041', 'Onion', 40, 'g'),

/* R042 - Chicken Fried Rice */
('R042', 'Chicken breast', 120, 'g'),
('R042', 'Rice', 100, 'g'),
('R042', 'Carrot', 40, 'g'),
('R042', 'Eggs', 1, 'piece'),
('R042', 'Soy sauce', 15, 'ml');

/* Insert unique ingredient names into the ingredients table. */
INSERT INTO dbo.ingredients (name)
SELECT DISTINCT ri.ingredient_name
FROM @RecipeIngredients AS ri
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.ingredients AS i
    WHERE i.name = ri.ingredient_name
);

/* Link every recipe to its ingredients and quantities. */
INSERT INTO dbo.recipe_ingredients (recipe_id, ingredient_id, quantity, unit)
SELECT
    ri.recipe_id,
    i.id_ingredient,
    ri.quantity,
    ri.unit
FROM @RecipeIngredients AS ri
INNER JOIN dbo.ingredients AS i
    ON i.name = ri.ingredient_name;

/* Associate recipes with multiple dietary categories */

/* Vegan */
INSERT INTO dbo.recipe_categories (recipe_id, category_id)
SELECT id_recipe, 1
FROM dbo.recipes
WHERE id_recipe IN (
    'R001','R002','R003','R004','R005','R006',
    'R007','R019','R025'
);

/* Vegetarian */
INSERT INTO dbo.recipe_categories (recipe_id, category_id)
SELECT id_recipe, 2
FROM dbo.recipes
WHERE id_recipe IN (
    'R001','R002','R003','R004','R005','R006','R007',
    'R008','R009','R010','R011','R012','R013','R014',
    'R019','R025','R028'
);

/* Lactose-free */
INSERT INTO dbo.recipe_categories (recipe_id, category_id)
SELECT id_recipe, 3
FROM dbo.recipes
WHERE id_recipe IN (
    'R001','R002','R003','R004','R005','R006','R007',
    'R013','R015','R016','R017','R018','R019',
    'R020','R021','R022','R023','R024','R025',
    'R026','R027','R028','R029','R030','R031',
    'R032','R033','R034','R035','R036','R039','R042'
);

/* Gluten-free */
INSERT INTO dbo.recipe_categories (recipe_id, category_id)
SELECT id_recipe, 4
FROM dbo.recipes
WHERE id_recipe IN (
    'R001','R003','R004','R005','R007',
    'R009','R012','R013','R015','R016','R017',
    'R018','R019','R021','R022','R023','R024',
    'R025','R026','R027','R028','R029',
    'R032','R033','R035'
);

/* Pescatarian */
INSERT INTO dbo.recipe_categories (recipe_id, category_id)
SELECT id_recipe, 5
FROM dbo.recipes
WHERE id_recipe IN (
    'R001','R002','R003','R004','R005','R006','R007',
    'R008','R009','R010','R011','R012','R013','R014',
    'R016','R019','R021','R024','R025','R027',
    'R028','R029','R030','R031','R032','R033',
    'R034','R035'
);

/* Regular - No dietary restrictions */
INSERT INTO dbo.recipe_categories (recipe_id, category_id)
SELECT id_recipe, 6
FROM dbo.recipes;

/* Appliance associations.
   Stovetop is used for pan cooking, boiling or simmering.
   Oven is added for recipes whose instructions require baking or roasting. */
INSERT INTO dbo.recipe_appliances (recipe_id, appliance_id)
SELECT id_recipe, 3
FROM dbo.recipes;

INSERT INTO dbo.recipe_appliances (recipe_id, appliance_id)
VALUES
('R004', 1), ('R007', 1), ('R008', 1), ('R010', 1),
('R012', 1), ('R014', 1), ('R016', 1), ('R023', 1),
('R027', 1), ('R032', 1), ('R040', 1), ('R041', 1);

/* Derive allergy warnings from the ingredients listed for each recipe.
   Packaged products may contain additional allergens; verify their labels. */
INSERT INTO dbo.recipe_allergies (recipe_id, allergy_id)
SELECT DISTINCT
    ri.recipe_id,
    CASE
        WHEN i.name IN ('Walnuts') THEN 2              -- Tree nuts
        WHEN i.name IN ('Ricotta', 'Mozzarella', 'Parmesan', 'Cream',
                        'Grated cheese', 'Feta cheese', 'Lactose-free cream',
                        'Cheddar cheese') THEN 3       -- Milk
        WHEN i.name = 'Eggs' THEN 4                    -- Eggs
        WHEN i.name IN ('Tofu', 'Tamari sauce', 'Soy sauce') THEN 5 -- Soy
        WHEN i.name IN ('Salmon', 'Canned tuna', 'Cod') THEN 6 -- Fish
        WHEN i.name = 'Shrimp' THEN 7                  -- Shellfish
        WHEN i.name IN ('Spaghetti', 'Pita bread', 'Lasagna sheets',
                        'Shortcrust pastry', 'Pasta', 'Burger bun',
                        'Flour tortillas', 'Breadcrumbs', 'Flour') THEN 8 -- Wheat
        WHEN i.name = 'Tahini' THEN 9                  -- Sesame
    END
FROM dbo.recipe_ingredients AS ri
INNER JOIN dbo.ingredients AS i
    ON i.id_ingredient = ri.ingredient_id
WHERE i.name IN (
    'Walnuts', 'Ricotta', 'Mozzarella', 'Parmesan', 'Cream',
    'Grated cheese', 'Feta cheese', 'Lactose-free cream',
    'Cheddar cheese', 'Eggs', 'Tofu', 'Tamari sauce', 'Soy sauce',
    'Salmon', 'Canned tuna', 'Cod', 'Shrimp', 'Spaghetti',
    'Pita bread', 'Lasagna sheets', 'Shortcrust pastry', 'Pasta',
    'Burger bun', 'Flour tortillas', 'Breadcrumbs', 'Flour', 'Tahini'
);

/* Verification: expected totals are 42 recipes and 210 recipe-ingredient links. */

/* 
   16. VERIFICATION
*/

SELECT * FROM dbo.dietary_categories;
SELECT * FROM dbo.appliances;
SELECT * FROM dbo.allergies;

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

/* Count recipes */
SELECT COUNT(*) AS total_recipes
FROM dbo.recipes;

/* Count unique ingredients */
SELECT COUNT(*) AS total_ingredients
FROM dbo.ingredients;

/* Count recipe-ingredient relationships */
SELECT COUNT(*) AS total_recipe_ingredients
FROM dbo.recipe_ingredients;

/* Display all recipes */
SELECT *
FROM dbo.recipes
ORDER BY id_recipe;

/* Display ingredients for each recipe */
SELECT
    r.id_recipe,
    r.name AS recipe_name,
    i.name AS ingredient_name,
    ri.quantity,
    ri.unit
FROM dbo.recipe_ingredients ri
INNER JOIN dbo.recipes r
    ON r.id_recipe = ri.recipe_id
INNER JOIN dbo.ingredients i
    ON i.id_ingredient = ri.ingredient_id
ORDER BY r.id_recipe, i.name;

/* Check recipes without ingredients */
SELECT r.id_recipe, r.name
FROM dbo.recipes r
LEFT JOIN dbo.recipe_ingredients ri
    ON r.id_recipe = ri.recipe_id
WHERE ri.recipe_id IS NULL;
GO


SELECT COUNT(*) AS total_recipe_categories FROM dbo.recipe_categories;
SELECT COUNT(*) AS total_recipe_appliances FROM dbo.recipe_appliances;
SELECT COUNT(*) AS total_recipe_allergies FROM dbo.recipe_allergies;

SELECT r.id_recipe, r.name
FROM dbo.recipes AS r
LEFT JOIN dbo.recipe_categories AS rc ON rc.recipe_id = r.id_recipe
WHERE rc.recipe_id IS NULL;

SELECT r.id_recipe, r.name
FROM dbo.recipes AS r
LEFT JOIN dbo.recipe_appliances AS ra ON ra.recipe_id = r.id_recipe
WHERE ra.recipe_id IS NULL;
