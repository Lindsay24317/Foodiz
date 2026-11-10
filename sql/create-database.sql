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

/**/
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

INSERT INTO dbo.appliances (
    name
    )
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

INSERT INTO dbo.allergies (
    name
    )
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

INSERT INTO dbo.recipe (
    id_recipe,
    name,
    description,
    instructions,
    preparation_time,
    cooking_time,
    estimated_cost,
    serving,
    image
)
VALUES
-- VEGAN
('R001', 'Chickpea Coconut Curry',
 'A creamy vegan curry made with chickpeas, coconut milk and fragrant spices.',
 '1. Chop the onion and garlic. 2. Fry them in oil with curry powder. 3. Add chickpeas, coconut milk and chopped tomatoes. 4. Simmer for 20 minutes. 5. Serve with cooked rice.',
 10, 20, 5.50, 2, 'images/recipes/chickpea-coconut-curry.jpg'),

('R002', 'Lentil Bolognese',
 'A plant-based alternative to traditional Bolognese made with lentils and tomato sauce.',
 '1. Chop the onion, carrot and garlic. 2. Fry the vegetables in olive oil. 3. Add lentils, tomato sauce and vegetable stock. 4. Simmer until the lentils are tender. 5. Serve with cooked spaghetti.',
 15, 30, 4.80, 2, 'images/recipes/lentil-bolognese.jpg'),

('R003', 'Tofu Vegetable Stir-Fry',
 'A colourful stir-fry with crispy tofu and fresh vegetables.',
 '1. Cut the tofu into cubes. 2. Chop the vegetables. 3. Fry the tofu until golden. 4. Add the vegetables and garlic. 5. Add gluten-free tamari and cook for 5 minutes. 6. Serve with rice.',
 15, 15, 6.50, 2, 'images/recipes/tofu-vegetable-stir-fry.jpg'),

('R004', 'Sweet Potato and Black Bean Bowl',
 'A nourishing bowl with roasted sweet potatoes, black beans and fresh vegetables.',
 '1. Peel and cube the sweet potatoes. 2. Season with olive oil, paprika, salt and pepper. 3. Roast at 200 degrees Celsius for 25 minutes. 4. Warm the black beans. 5. Serve with lettuce, tomatoes and sweet potatoes.',
 10, 25, 5.20, 2, 'images/recipes/sweet-potato-black-bean-bowl.jpg'),

('R005', 'Red Lentil Soup',
 'A comforting soup made with red lentils, carrots and aromatic spices.',
 '1. Chop the onion, carrots and garlic. 2. Fry in olive oil. 3. Add red lentils, vegetable stock and cumin. 4. Simmer for 25 minutes. 5. Blend until smooth or leave slightly chunky.',
 10, 25, 3.80, 2, 'images/recipes/red-lentil-soup.jpg'),

('R006', 'Falafel Pita',
 'Homemade chickpea falafel served with fresh vegetables and tahini sauce.',
 '1. Blend chickpeas, onion, garlic, parsley and cumin. 2. Shape into small balls. 3. Fry until golden and cooked through. 4. Prepare the tahini sauce with lemon juice and water. 5. Fill pita bread with falafel, lettuce and tomatoes.',
 20, 15, 5.50, 2, 'images/recipes/falafel-pita.jpg'),

('R007', 'Stuffed Bell Peppers',
 'Bell peppers filled with rice, vegetables, tomatoes and herbs.',
 '1. Cook the rice. 2. Cut the tops off the peppers and remove the seeds. 3. Fry onion, garlic and chopped tomatoes. 4. Mix with rice and herbs. 5. Fill the peppers. 6. Bake at 180 degrees Celsius for 30 minutes.',
 15, 30, 5.00, 2, 'images/recipes/stuffed-bell-peppers.jpg'),

-- VEGETARIAN
('R008', 'Spinach and Ricotta Lasagna',
 'A delicious vegetarian lasagna layered with spinach, ricotta and tomato sauce.',
 '1. Cook the spinach and mix with ricotta. 2. Prepare the tomato sauce. 3. Layer lasagna sheets, spinach mixture and tomato sauce. 4. Add grated cheese. 5. Bake at 180 degrees Celsius for 35 minutes.',
 20, 35, 7.50, 2, 'images/recipes/spinach-ricotta-lasagna.jpg'),

('R009', 'Creamy Mushroom Risotto',
 'A creamy Italian rice dish with mushrooms, vegetable stock and Parmesan.',
 '1. Chop the onion and mushrooms. 2. Fry in butter. 3. Add Arborio rice and stir. 4. Gradually add warm vegetable stock while stirring. 5. Cook until the rice is tender. 6. Finish with Parmesan.',
 10, 25, 6.00, 2, 'images/recipes/mushroom-risotto.jpg'),

('R010', 'Vegetable Quiche',
 'A savoury tart filled with eggs, cream and seasonal vegetables.',
 '1. Place the pastry in a tart dish. 2. Chop and lightly cook the vegetables. 3. Beat eggs with cream, salt and pepper. 4. Add the vegetables and grated cheese. 5. Pour into the pastry. 6. Bake at 180 degrees Celsius for 35 minutes.',
 15, 35, 6.50, 2, 'images/recipes/vegetable-quiche.jpg'),

('R011', 'Pesto Mozzarella Pasta',
 'A quick pasta dish with basil pesto, mozzarella and cherry tomatoes.',
 '1. Cook the pasta in salted water. 2. Halve the cherry tomatoes. 3. Drain the pasta and mix with pesto. 4. Add mozzarella and tomatoes. 5. Season and serve.',
 10, 15, 5.80, 2, 'images/recipes/pesto-mozzarella-pasta.jpg'),

('R012', 'Sweet Potato and Feta Salad',
 'A fresh salad combining roasted sweet potatoes, feta cheese and leafy greens.',
 '1. Peel and cube the sweet potatoes. 2. Season with olive oil and roast at 200 degrees Celsius for 25 minutes. 3. Wash the salad leaves. 4. Add the sweet potatoes, crumbled feta and walnuts. 5. Dress with olive oil and lemon juice.',
 10, 25, 5.80, 2, 'images/recipes/sweet-potato-feta-salad.jpg'),

('R013', 'Classic Shakshuka',
 'Eggs cooked in a rich tomato and pepper sauce with aromatic spices.',
 '1. Chop the onion, garlic and pepper. 2. Fry in olive oil. 3. Add chopped tomatoes, paprika and cumin. 4. Simmer for 10 minutes. 5. Make small wells and add the eggs. 6. Cover until the eggs are cooked.',
 10, 20, 4.50, 2, 'images/recipes/classic-shakshuka.jpg'),

('R014', 'Spinach and Cheese Stuffed Shells',
 'Pasta shells filled with spinach and ricotta, baked in tomato sauce.',
 '1. Cook the pasta shells until slightly firm. 2. Mix spinach, ricotta and Parmesan. 3. Fill each shell with the mixture. 4. Place in a baking dish with tomato sauce. 5. Bake at 180 degrees Celsius for 25 minutes.',
 20, 25, 7.00, 2, 'images/recipes/spinach-cheese-stuffed-shells.jpg'),

-- LACTOSE-FREE
('R015', 'Lemon Garlic Chicken and Rice',
 'Tender chicken cooked with garlic and lemon, served with fluffy rice.',
 '1. Season the chicken with lemon juice, garlic, salt and pepper. 2. Heat olive oil in a pan. 3. Cook the chicken until golden and fully cooked. 4. Cook the rice separately. 5. Serve together with fresh parsley.',
 10, 25, 6.50, 2, 'images/recipes/lemon-garlic-chicken-rice.jpg'),

('R016', 'Baked Salmon and Potatoes',
 'Oven-baked salmon served with seasoned potatoes and lemon.',
 '1. Cut the potatoes into wedges. 2. Season with olive oil, salt and pepper. 3. Bake at 200 degrees Celsius for 20 minutes. 4. Add the salmon with lemon and herbs. 5. Bake for another 12 to 15 minutes until cooked.',
 10, 35, 9.50, 2, 'images/recipes/baked-salmon-potatoes.jpg'),

('R017', 'Chicken Coconut Curry',
 'A mild chicken curry prepared with coconut milk, tomatoes and spices.',
 '1. Cut the chicken into pieces. 2. Fry onion and garlic in oil. 3. Add curry powder and chicken. 4. Add coconut milk and chopped tomatoes. 5. Simmer until the chicken is fully cooked. 6. Serve with rice.',
 10, 25, 7.00, 2, 'images/recipes/chicken-coconut-curry.jpg'),

('R018', 'Beef and Vegetable Tacos',
 'Soft tacos filled with seasoned beef, peppers and fresh vegetables.',
 '1. Chop the onion and peppers. 2. Fry the beef with taco seasoning. 3. Add the vegetables and cook until tender. 4. Warm the corn tortillas. 5. Fill with beef, lettuce and tomatoes.',
 15, 15, 7.50, 2, 'images/recipes/beef-vegetable-tacos.jpg'),

('R019', 'Roasted Vegetable Quinoa Bowl',
 'A colourful bowl of quinoa topped with roasted vegetables and lemon dressing.',
 '1. Rinse and cook the quinoa. 2. Chop the vegetables. 3. Season with olive oil, salt and pepper. 4. Roast at 200 degrees Celsius for 20 to 25 minutes. 5. Serve over quinoa with lemon dressing.',
 15, 25, 5.80, 2, 'images/recipes/roasted-vegetable-quinoa-bowl.jpg'),

('R020', 'Tomato Basil Chicken Pasta',
 'Pasta with chicken, fresh tomatoes, basil and a light olive oil sauce.',
 '1. Cook the pasta. 2. Cut the chicken into small pieces. 3. Fry the chicken with garlic until fully cooked. 4. Add chopped tomatoes and basil. 5. Simmer for 5 minutes. 6. Mix with the pasta.',
 10, 20, 6.80, 2, 'images/recipes/tomato-basil-chicken-pasta.jpg'),

('R021', 'Garlic Shrimp Rice Bowl',
 'Juicy garlic shrimp served over rice with fresh vegetables.',
 '1. Cook the rice. 2. Chop the garlic and vegetables. 3. Fry the shrimp in olive oil with garlic until fully cooked. 4. Add lemon juice and seasoning. 5. Serve over rice with vegetables.',
 10, 15, 8.00, 2, 'images/recipes/garlic-shrimp-rice-bowl.jpg'),

-- GLUTEN-FREE
('R022', 'Chicken and Vegetable Rice Bowl',
 'A balanced rice bowl with chicken and colourful vegetables.',
 '1. Cook the rice. 2. Cut the chicken and vegetables into pieces. 3. Fry the chicken until fully cooked. 4. Add the vegetables and cook until tender. 5. Season with gluten-free tamari and serve over rice.',
 15, 20, 6.50, 2, 'images/recipes/chicken-vegetable-rice-bowl.jpg'),

('R023', 'Stuffed Zucchini Boats',
 'Baked zucchini halves filled with minced meat, tomatoes and herbs.',
 '1. Halve the zucchini lengthwise and scoop out the centre. 2. Fry the minced meat with onion and garlic. 3. Add chopped tomatoes and herbs. 4. Fill the zucchini halves. 5. Bake at 190 degrees Celsius for 25 minutes.',
 15, 25, 6.50, 2, 'images/recipes/stuffed-zucchini-boats.jpg'),

('R024', 'Shrimp Rice Noodle Stir-Fry',
 'Rice noodles tossed with shrimp, vegetables and a light gluten-free sauce.',
 '1. Prepare the rice noodles according to the package. 2. Chop the vegetables. 3. Fry the shrimp until fully cooked. 4. Add the vegetables and garlic. 5. Add noodles and gluten-free tamari. 6. Toss and serve.',
 15, 15, 8.00, 2, 'images/recipes/shrimp-rice-noodle-stir-fry.jpg'),

('R025', 'Sweet Potato and Bean Chili',
 'A hearty chili made with sweet potatoes, beans, tomatoes and spices.',
 '1. Peel and cube the sweet potato. 2. Fry onion and garlic. 3. Add sweet potato, beans, tomatoes and chili powder. 4. Add vegetable stock. 5. Simmer until the sweet potato is tender.',
 10, 30, 4.80, 2, 'images/recipes/sweet-potato-bean-chili.jpg'),

('R026', 'Chicken and Quinoa Skillet',
 'A one-pan meal with chicken, quinoa and vegetables.',
 '1. Cut the chicken into pieces. 2. Fry onion and chicken in olive oil. 3. Add rinsed quinoa, vegetables and gluten-free stock. 4. Cover and simmer until the quinoa is cooked and the chicken is fully cooked. 5. Season and serve.',
 10, 25, 7.00, 2, 'images/recipes/chicken-quinoa-skillet.jpg'),

('R027', 'Tuna Stuffed Baked Potatoes',
 'Baked potatoes filled with tuna, sweetcorn and a fresh lemon dressing.',
 '1. Wash and pierce the potatoes. 2. Bake at 200 degrees Celsius for 40 to 50 minutes until tender. 3. Mix drained tuna with sweetcorn, olive oil and lemon juice. 4. Cut open the potatoes and add the tuna mixture.',
 10, 45, 5.50, 2, 'images/recipes/tuna-stuffed-baked-potatoes.jpg'),

('R028', 'Garden Vegetable Omelette',
 'A simple omelette filled with fresh vegetables and herbs.',
 '1. Chop the vegetables. 2. Fry them lightly in olive oil. 3. Beat the eggs with salt and pepper. 4. Pour the eggs over the vegetables. 5. Cook gently until set and fold the omelette.',
 10, 10, 4.00, 2, 'images/recipes/garden-vegetable-omelette.jpg'),

-- PESCATARIAN
('R029', 'Salmon Teriyaki Bowl',
 'A salmon bowl with rice, vegetables and a sweet teriyaki-style sauce.',
 '1. Cook the rice. 2. Mix gluten-free tamari, honey and ginger. 3. Cook the salmon in a pan until fully cooked. 4. Add the sauce and let it thicken. 5. Serve with rice and vegetables.',
 10, 20, 9.50, 2, 'images/recipes/salmon-teriyaki-bowl.jpg'),

('R030', 'Mediterranean Tuna Pasta',
 'Pasta with tuna, tomatoes, olives and Mediterranean herbs.',
 '1. Cook the pasta. 2. Chop the tomatoes and olives. 3. Fry garlic in olive oil. 4. Add tomatoes, tuna and olives. 5. Simmer for 5 minutes. 6. Mix with the pasta and parsley.',
 10, 15, 6.50, 2, 'images/recipes/mediterranean-tuna-pasta.jpg'),

('R031', 'Garlic Shrimp Spaghetti',
 'Spaghetti tossed with garlic shrimp, olive oil and fresh parsley.',
 '1. Cook the spaghetti. 2. Fry garlic in olive oil. 3. Add shrimp and cook until fully cooked. 4. Add lemon juice and parsley. 5. Toss with the drained spaghetti and serve.',
 10, 15, 8.00, 2, 'images/recipes/garlic-shrimp-spaghetti.jpg'),

('R032', 'Baked Cod and Vegetables',
 'Oven-baked cod served with seasonal vegetables and lemon.',
 '1. Chop the vegetables. 2. Place them in a baking dish with olive oil and herbs. 3. Bake at 190 degrees Celsius for 15 minutes. 4. Add the cod and lemon. 5. Bake for another 12 to 15 minutes until the fish is cooked.',
 15, 30, 8.50, 2, 'images/recipes/baked-cod-vegetables.jpg'),

('R033', 'Salmon and Avocado Sushi Bowl',
 'A sushi-inspired bowl with rice, salmon, avocado and cucumber.',
 '1. Cook the sushi rice and season it with rice vinegar. 2. Cook the salmon thoroughly and let it cool slightly. 3. Slice the avocado and cucumber. 4. Arrange everything in bowls. 5. Add gluten-free tamari and sesame seeds.',
 15, 20, 10.00, 2, 'images/recipes/salmon-avocado-sushi-bowl.jpg'),

('R034', 'Creamy Salmon Spinach Pasta',
 'Pasta with salmon, spinach and a creamy lactose-free sauce.',
 '1. Cook the pasta. 2. Cut the salmon into pieces and cook in a pan. 3. Add spinach and lactose-free cream. 4. Simmer until the spinach softens and the salmon is cooked. 5. Mix with the pasta and season.',
 10, 20, 9.00, 2, 'images/recipes/creamy-salmon-spinach-pasta.jpg'),

('R035', 'Tuna and Chickpea Salad',
 'A fresh protein-rich salad with tuna, chickpeas, tomatoes and lemon dressing.',
 '1. Drain the tuna and chickpeas. 2. Chop the tomatoes, cucumber and red onion. 3. Mix everything in a bowl. 4. Add olive oil, lemon juice, salt and pepper. 5. Toss and serve.',
 15, 0, 5.80, 2, 'images/recipes/tuna-chickpea-salad.jpg'),

-- REGULAR
('R036', 'Spaghetti Bolognese',
 'A classic Italian-inspired pasta dish with minced beef and tomato sauce.',
 '1. Cook the spaghetti. 2. Chop the onion and garlic. 3. Brown the minced beef in a pan. 4. Add onion, garlic and tomato sauce. 5. Simmer for 20 minutes. 6. Serve with spaghetti.',
 10, 25, 7.00, 2, 'images/recipes/spaghetti-bolognese.jpg'),

('R037', 'Creamy Chicken Mushroom Pasta',
 'Pasta with chicken, mushrooms and a rich creamy sauce.',
 '1. Cook the pasta. 2. Cut the chicken into pieces. 3. Fry the chicken until fully cooked. 4. Add mushrooms and garlic. 5. Pour in cream and simmer. 6. Mix with the pasta.',
 10, 20, 7.50, 2, 'images/recipes/creamy-chicken-mushroom-pasta.jpg'),

('R038', 'Classic Beef Burger',
 'A homemade beef burger served in a bun with lettuce, tomato and sauce.',
 '1. Season the minced beef and shape into two patties. 2. Cook in a hot pan until fully cooked. 3. Toast the burger buns. 4. Add lettuce, tomato, cheese and sauce. 5. Assemble and serve.',
 15, 15, 8.00, 2, 'images/recipes/classic-beef-burger.jpg'),

('R039', 'Chicken Fajitas',
 'Chicken strips cooked with peppers and onions, served in warm tortillas.',
 '1. Slice the chicken, peppers and onion. 2. Season the chicken with fajita spices. 3. Fry the chicken until fully cooked. 4. Add peppers and onion. 5. Warm the tortillas and fill them with the mixture.',
 15, 15, 7.00, 2, 'images/recipes/chicken-fajitas.jpg'),

('R040', 'Chicken Parmesan',
 'Breaded chicken topped with tomato sauce and melted cheese.',
 '1. Flatten the chicken breasts. 2. Coat them in flour, beaten egg and breadcrumbs. 3. Fry until golden and fully cooked. 4. Add tomato sauce and mozzarella. 5. Bake until the cheese melts. 6. Serve with pasta or salad.',
 15, 25, 8.50, 2, 'images/recipes/chicken-parmesan.jpg'),

('R041', 'Classic Beef Lasagna',
 'Layers of pasta, minced beef, tomato sauce and creamy béchamel.',
 '1. Brown the minced beef with onion and garlic. 2. Add tomato sauce and simmer. 3. Prepare the béchamel sauce. 4. Layer pasta sheets, meat sauce and béchamel in a baking dish. 5. Add cheese. 6. Bake at 180 degrees Celsius for 40 minutes.',
 20, 40, 9.00, 2, 'images/recipes/classic-beef-lasagna.jpg'),

('R042', 'Chicken Fried Rice',
 'A quick rice dish with chicken, vegetables, eggs and soy sauce.',
 '1. Cook the rice and let it cool. 2. Cut the chicken into small pieces. 3. Fry the chicken until fully cooked. 4. Add vegetables and cook until tender. 5. Add the rice and beaten eggs. 6. Stir-fry with soy sauce until heated through.',
 15, 15, 6.50, 2, 'images/recipes/chicken-fried-rice.jpg');

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

