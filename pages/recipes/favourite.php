<?php
// Only allow logged-in users
if (!isset($_SESSION['user'])) {
    header("Location: index.php?page=login");
    exit;
}
// Get the logged-in user
$userId = $_SESSION['user']['id'];

// Get the recipe ID
$recipeId = $_POST['recipe_id'] ?? '';

if (!$recipeId) {
    exit("Recipe ID missing");
}

// Only accept the form submission
if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    header("Location: index.php?page=recipes");
    exit;
}


// Check if the recipe exists
$sql = "SELECT id_recipe
        FROM dbo.recipes
        WHERE id_recipe = ?";

$stmt = $pdo->prepare($sql);
$stmt->execute([$recipeId]);

$recipe = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$recipe) {
    exit("Recipe not found");
}


// Check if recipe is already saved
$sql = "SELECT COUNT(*) 
        FROM dbo.saved_recipes
        WHERE user_id = ?
        AND recipe_id = ?";

$stmt = $pdo->prepare($sql);
$stmt->execute([$userId, $recipeId]);

$saved = $stmt->fetchColumn();


// Remove or add favourite
if ($saved) {

    // Remove favourite
    $sql = "DELETE FROM dbo.saved_recipes
            WHERE user_id = ?
            AND recipe_id = ?";

} else {

    // Add favourite
    $sql = "INSERT INTO dbo.saved_recipes
            (user_id, recipe_id, saved_at)
            VALUES (?, ?, GETDATE())";

}

$stmt = $pdo->prepare($sql);
$stmt->execute([$userId, $recipeId]);


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

header("Location: index.php?page=userPage");
exit;