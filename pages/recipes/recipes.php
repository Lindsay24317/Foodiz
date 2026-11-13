<?php


// 1. GET THE FILTERS


$search = $_GET['search'] ?? '';
$category = $_GET['category'] ?? '';
$appliance = $_GET['appliance'] ?? '';
$allergy = $_GET['allergy'] ?? '';
$budget = $_GET['budget'] ?? '';
$time = $_GET['time'] ?? '';
$favourites = $_GET['favourites'] ?? '';

// Get the logged-in user's ID
$userId = $_SESSION['user']['id'] ?? 0;



// 2. GET THE FILTER OPTIONS


// Dietary categories
$sql = "SELECT * FROM dbo.dietary_categories ORDER BY name";
$stmt = $pdo->prepare($sql);
$stmt->execute();
$categories = $stmt->fetchAll(PDO::FETCH_ASSOC);


// Appliances
$sql = "SELECT * FROM dbo.appliances ORDER BY name";
$stmt = $pdo->prepare($sql);
$stmt->execute();
$appliances = $stmt->fetchAll(PDO::FETCH_ASSOC);


// Allergies
$sql = "SELECT * FROM dbo.allergies ORDER BY name";
$stmt = $pdo->prepare($sql);
$stmt->execute();
$allergies = $stmt->fetchAll(PDO::FETCH_ASSOC);



// 3. GET THE RECIPES


$sql = "SELECT * 
        FROM dbo.recipes 
        WHERE 1=1";

$params = [];


// Search by name
if ($search != '') {

    $sql .= " AND name LIKE :search";

    $params['search'] = '%' . $search . '%';
}


// Dietary category
if ($category != '' && ctype_digit((string)$category)) {

    $sql .= " AND id_recipe IN (
        SELECT recipe_id
        FROM dbo.recipe_categories
        WHERE category_id = :category
    )";

    $params['category'] = $category;
}


// Appliance
if ($appliance != '' && ctype_digit((string)$appliance)) {

    $sql .= " AND id_recipe IN (
        SELECT recipe_id
        FROM dbo.recipe_appliances
        WHERE appliance_id = :appliance
    )";

    $params['appliance'] = $appliance;
}


// Exclude an allergen
if ($allergy != '' && ctype_digit((string)$allergy)) {

    $sql .= " AND id_recipe NOT IN (
        SELECT recipe_id
        FROM dbo.recipe_allergies
        WHERE allergy_id = :allergy
    )";

    $params['allergy'] = $allergy;
}


// Maximum budget
if ($budget != '' && is_numeric($budget) && $budget >= 0) {

    $sql .= " AND estimated_cost <= :budget";

    $params['budget'] = $budget;
}


// Maximum total time
if ($time != '' && ctype_digit((string)$time)) {

    $sql .= " AND (
        COALESCE(preparation_time, 0)
        + COALESCE(cooking_time, 0)
    ) <= :time";

    $params['time'] = $time;
}


// Show only favourite recipes
if ($favourites == '1') {

    $sql .= " AND id_recipe IN (
        SELECT recipe_id
        FROM dbo.saved_recipes
        WHERE user_id = :user_id
    )";

    $params['user_id'] = $userId;
}


// Sort alphabetically
$sql .= " ORDER BY name";


// Execute the query
$stmt = $pdo->prepare($sql);
$stmt->execute($params);

$recipes = $stmt->fetchAll(PDO::FETCH_ASSOC);



// 4. GET SAVED RECIPES


$sql = "SELECT recipe_id
        FROM dbo.saved_recipes
        WHERE user_id = ?";

$stmt = $pdo->prepare($sql);
$stmt->execute([$userId]);

$savedRecipes = $stmt->fetchAll(PDO::FETCH_COLUMN);



// 5. GET RECIPE DIETARY CATEGORIES


$sql = "SELECT rc.recipe_id, dc.name
        FROM dbo.recipe_categories rc
        JOIN dbo.dietary_categories dc
        ON rc.category_id = dc.id_category";

$stmt = $pdo->prepare($sql);
$stmt->execute();

$recipeCategories = $stmt->fetchAll(PDO::FETCH_ASSOC);

?>

<section class="recipes-page">

    <!-- PAGE TITLE -->

    <div class="recipes-heading">

        <h1>Discover our recipes</h1>

        <p>Find affordable meals that suit your needs.</p>

    </div>


    <!-- 
         FILTERS
    -->

    <form action="index.php" method="GET" class="recipes-filters">

        <input type="hidden" name="page" value="recipes">


        <!-- Search -->
        <input
            type="text"
            name="search"
            placeholder="Search recipes..."
            value="<?= htmlspecialchars($search) ?>"
        >


        <!-- Dietary category -->
        <select name="category">

            <option value="">All diets</option>

            <?php foreach ($categories as $item): ?>

                <option
                    value="<?= $item['id_category'] ?>"
                    <?= $category == $item['id_category'] ? 'selected' : '' ?>
                >
                    <?= htmlspecialchars($item['name']) ?>
                </option>

            <?php endforeach; ?>

        </select>


        <!-- Appliance -->
        <select name="appliance">

            <option value="">All appliances</option>

            <?php foreach ($appliances as $item): ?>

                <option
                    value="<?= $item['id_appliance'] ?>"
                    <?= $appliance == $item['id_appliance'] ? 'selected' : '' ?>
                >
                    <?= htmlspecialchars($item['name']) ?>
                </option>

            <?php endforeach; ?>

        </select>


        <!-- Allergy -->
        <select name="allergy">

            <option value="">Exclude an allergen</option>

            <?php foreach ($allergies as $item): ?>

                <option
                    value="<?= $item['id_allergy'] ?>"
                    <?= $allergy == $item['id_allergy'] ? 'selected' : '' ?>
                >
                    <?= htmlspecialchars($item['name']) ?>
                </option>

            <?php endforeach; ?>

        </select>


        <!-- Budget -->
        <input
            type="number"
            name="budget"
            min="0"
            step="0.01"
            placeholder="Max budget (€)"
            value="<?= htmlspecialchars($budget) ?>"
        >


        <!-- Cooking time -->
        <select name="time">

            <option value="">Any cooking time</option>

            <option value="15" <?= $time == '15' ? 'selected' : '' ?>>
                15 minutes
            </option>

            <option value="30" <?= $time == '30' ? 'selected' : '' ?>>
                30 minutes
            </option>

            <option value="45" <?= $time == '45' ? 'selected' : '' ?>>
                45 minutes
            </option>

            <option value="60" <?= $time == '60' ? 'selected' : '' ?>>
                60 minutes
            </option>

        </select>


        <!-- My Favourites -->
        <select name="favourites">

            <option value="">All recipes</option>

            <option
                value="1"
                <?= $favourites == '1' ? 'selected' : '' ?>
            >
                My Favourites
            </option>

        </select>


        <button type="submit">
            Apply filters
        </button>

        <a href="index.php?page=recipes" class="reset-filters">
            Reset
        </a>

    </form>


    <!-- NUMBER OF RECIPES -->

    <p class="recipes-count">
        <?= count($recipes) ?> recipes found
    </p>


    <!-- 
         RECIPE CARDS
     -->

    <div class="recipes-grid">

        <?php foreach ($recipes as $recipe): ?>

            <?php

            $recipeId = $recipe['id_recipe'];

            $totalTime =
                (int)$recipe['preparation_time']
                + (int)$recipe['cooking_time'];

            // Check if recipe is saved
            $isSaved = in_array($recipeId, $savedRecipes);

            // Find dietary categories
            $diet = '';

            foreach ($recipeCategories as $item) {

                if ($item['recipe_id'] == $recipeId) {

                    $diet .= $item['name'] . ' ';

                }

            }

            ?>

            <article class="recipe-card">

                <!-- IMAGE AND HEART -->

                <div class="recipe-image-container">

                    <a href="index.php?page=recipes-details&id=<?= urlencode($recipeId) ?>">

                        <img
                            src="<?= htmlspecialchars($recipe['image'] ?? '') ?>"
                            alt="<?= htmlspecialchars($recipe['name']) ?>"
                            class="recipe-image"
                            loading="lazy"
                        >

                    </a>


                    <!-- FAVOURITE HEART -->

                    <form
                        action="index.php?page=favourite"
                        method="POST"
                        class="favourite-form"
                    >

                        <input
                            type="hidden"
                            name="recipe_id"
                            value="<?= htmlspecialchars($recipeId) ?>"
                        >

                        <!-- Keep filters after clicking heart -->
                        <input type="hidden" name="search" value="<?= htmlspecialchars($search) ?>">
                        <input type="hidden" name="category" value="<?= htmlspecialchars($category) ?>">
                        <input type="hidden" name="appliance" value="<?= htmlspecialchars($appliance) ?>">
                        <input type="hidden" name="allergy" value="<?= htmlspecialchars($allergy) ?>">
                        <input type="hidden" name="budget" value="<?= htmlspecialchars($budget) ?>">
                        <input type="hidden" name="time" value="<?= htmlspecialchars($time) ?>">
                        <input type="hidden" name="favourites" value="<?= htmlspecialchars($favourites) ?>">

                        <button
                            type="submit"
                            class="favourite-btn <?= $isSaved ? 'saved' : '' ?>"
                            aria-label="<?= $isSaved ? 'Remove from favourites' : 'Add to favourites' ?>"
                        >
                            <?= $isSaved ? '♥' : '♡' ?>
                        </button>

                    </form>

                </div>


                <!-- RECIPE INFORMATION -->

                <a
                    href="index.php?page=recipes-details&id=<?= urlencode($recipeId) ?>"
                    class="recipe-card-link"
                >

                    <div class="recipe-info">

                        <h2>
                            <?= htmlspecialchars($recipe['name']) ?>
                        </h2>


                        <p class="recipe-category">
                            <?= htmlspecialchars(trim($diet)) ?>
                        </p>


                        <div class="recipe-meta">

                            <span>
                                ⏱ <?= $totalTime ?> min
                            </span>

                            <span>
                                <?= number_format(
                                    (float)$recipe['estimated_cost'],
                                    2,
                                    ',',
                                    ' '
                                ) ?> €
                            </span>

                        </div>

                    </div>

                </a>

            </article>

        <?php endforeach; ?>

    </div>


    <!-- NO RESULTS -->

    <?php if (empty($recipes)): ?>

        <p class="no-recipes">
            No recipes found. Try changing your filters.
        </p>

    <?php endif; ?>

</section>
