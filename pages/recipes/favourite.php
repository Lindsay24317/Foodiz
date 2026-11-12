<?php

// Get the logged-in user
$userId = $_SESSION['user']['id_user'] ?? 0;

// Get the recipe ID
$recipeId = $_POST['recipe_id'] ?? '';


// Only allow logged-in users
if ($userId == 0) {
    header("Location: index.php?page=login");
    exit;
}


// Only accept the form submission
if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    header("Location: index.php?page=recipes");
    exit;
}


// Check if the recipe exists
$sql = "SELECT * FROM dbo.recipes
        WHERE id_recipe = :recipe_id";

$stmt = $pdo->prepare($sql);
$stmt->execute(['recipe_id' => $recipeId]);

$recipe = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$recipe) {
    exit("Recipe not found");
}


// Check if recipe is already saved
$sql = "SELECT * FROM dbo.saved_recipes
        WHERE user_id = :user_id
        AND recipe_id = :recipe_id";

$stmt = $pdo->prepare($sql);

$stmt->execute([
    'user_id' => $userId,
    'recipe_id' => $recipeId
]);

$saved = $stmt->fetch(PDO::FETCH_ASSOC);


// Remove or add favourite
if ($saved) {

    // Remove favourite
    $sql = "DELETE FROM dbo.saved_recipes
            WHERE user_id = :user_id
            AND recipe_id = :recipe_id";

} else {

    // Add favourite
    $sql = "INSERT INTO dbo.saved_recipes
            (user_id, recipe_id)
            VALUES (:user_id, :recipe_id)";

}

$stmt = $pdo->prepare($sql);

$stmt->execute([
    'user_id' => $userId,
    'recipe_id' => $recipeId
]);


// Return to the catalogue with filters
$filters = [
    'page' => 'recipes',
    'search' => $_POST['search'] ?? '',
    'category' => $_POST['category'] ?? '',
    'appliance' => $_POST['appliance'] ?? '',
    'allergy' => $_POST['allergy'] ?? '',
    'budget' => $_POST['budget'] ?? '',
    'time' => $_POST['time'] ?? '',
    'favourites' => $_POST['favourites'] ?? ''
];

header("Location: index.php?" . http_build_query($filters));
exit;