
<?php


// 1. GET THE RECIPE ID


$recipeId = $_GET['id'] ?? '';



// 2. GET THE RECIPE


$sql = "SELECT * FROM dbo.recipes
        WHERE id_recipe = ?";

$stmt = $pdo->prepare($sql);
$stmt->execute([$recipeId]);

$recipe = $stmt->fetch(PDO::FETCH_ASSOC);



// 3. GET THE RECIPE INFORMATION


$ingredients = [];
$appliances = [];
$categories = [];

if ($recipe) {

    // INGREDIENTS AND QUANTITIES

    $sql = "SELECT i.name, ri.quantity, ri.unit
            FROM dbo.recipe_ingredients ri
            JOIN dbo.ingredients i
            ON ri.ingredient_id = i.id_ingredient
            WHERE ri.recipe_id = ?
            ORDER BY i.name";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([$recipeId]);

    $ingredients = $stmt->fetchAll(PDO::FETCH_ASSOC);


    // APPLIANCES

    $sql = "SELECT a.name
            FROM dbo.recipe_appliances ra
            JOIN dbo.appliances a
            ON ra.appliance_id = a.id_appliance
            WHERE ra.recipe_id = ?
            ORDER BY a.name";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([$recipeId]);

    $appliances = $stmt->fetchAll(PDO::FETCH_ASSOC);


    // DIETARY CATEGORIES

    $sql = "SELECT dc.name
            FROM dbo.recipe_categories rc
            JOIN dbo.dietary_categories dc
            ON rc.category_id = dc.id_category
            WHERE rc.recipe_id = ?
            ORDER BY dc.name";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([$recipeId]);

    $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);

}

?>

<section class="recipe-details-page">

    <a href="index.php?page=recipes" class="back-link">
        ← Back to recipes
    </a>

    <?php if ($recipe): ?>

        <!-- RECIPE TITLE -->

        <h1>
            <?= htmlspecialchars($recipe['name']) ?>
        </h1>


        <!-- RECIPE IMAGE -->

        <img
            src="<?= htmlspecialchars($recipe['image'] ?? '') ?>"
            alt="<?= htmlspecialchars($recipe['name']) ?>"
            class="details-image"
        >


        <!-- DESCRIPTION -->

        <p class="details-description">
            <?= htmlspecialchars($recipe['description'] ?? '') ?>
        </p>


        <!-- DIETARY CATEGORIES -->

        <div class="details-diets">

            <?php foreach ($categories as $category): ?>

                <span class="diet-badge">
                    <?= htmlspecialchars($category['name']) ?>
                </span>

            <?php endforeach; ?>

        </div>


        <!-- TIME AND BUDGET -->

        <div class="details-info">

            <div>
                <strong>Preparation</strong>
                <p>
                    <?= (int)$recipe['preparation_time'] ?> min
                </p>
            </div>

            <div>
                <strong>Cooking</strong>
                <p>
                    <?= (int)$recipe['cooking_time'] ?> min
                </p>
            </div>

            <div>
                <strong>Total time</strong>
                <p>
                    <?= (int)$recipe['preparation_time']
                        + (int)$recipe['cooking_time'] ?> min
                </p>
            </div>

            <div>
                <strong>Estimated budget</strong>
                <p>
                    <?= number_format(
                        (float)$recipe['estimated_cost'],
                        2,
                        ',',
                        ' '
                    ) ?> €
                </p>
            </div>

        </div>


        <!-- INGREDIENTS -->

        <div class="details-columns">

        <div class="details-section">

            <h2>Ingredients</h2>

            <?php if (!empty($ingredients)): ?>

                <ul class="ingredients-list">

                    <?php foreach ($ingredients as $ingredient): ?>

                        <li>

                            <?php if ($ingredient['quantity'] !== null): ?>

                                <?= htmlspecialchars(
                                    (string)(float)$ingredient['quantity']
                                ) ?>

                            <?php endif; ?>

                            <?= htmlspecialchars($ingredient['unit'] ?? '') ?>

                            <?= htmlspecialchars($ingredient['name']) ?>

                        </li>

                    <?php endforeach; ?>

                </ul>

            <?php else: ?>

                <p>No ingredients available.</p>

            <?php endif; ?>

        </div>


        <!-- APPLIANCES -->

        <div class="details-section">

            <h2>Appliances needed</h2>

            <?php if (!empty($appliances)): ?>

                <ul class="appliances-list">

                    <?php foreach ($appliances as $appliance): ?>

                        <li>
                            <?= htmlspecialchars($appliance['name']) ?>
                        </li>

                    <?php endforeach; ?>

                </ul>

            <?php else: ?>

                <p>No appliances listed.</p>

            <?php endif; ?>

        </div>
        </div>


        <!-- COOKING INSTRUCTIONS -->

        <div class="details-section">

    <h2>Preparation steps</h2>

    <?php
    // Separate the instructions into steps
    $steps = explode('.', $recipe['instructions']);

    $number = 1;
    ?>

    <ol class="steps-list">

        <?php foreach ($steps as $step): ?>

            <?php if (trim($step) != ''): ?>

                <li>
                    <?= htmlspecialchars(trim($step)) ?>.
                </li>

                <?php $number++; ?>

            <?php endif; ?>

        <?php endforeach; ?>

    </ol>

</div>

    <?php else: ?>

        <h1>Recipe not found</h1>

        <p>
            This recipe does not exist.
        </p>

    <?php endif; ?>

</section>