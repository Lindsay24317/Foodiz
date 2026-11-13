<?php
if (!isset($_SESSION['user'])){
    header('Location: index.php?page=login');
    exit;
}

$idUser = $_SESSION['user']['id'];
$idRecipe = $_POST['recipe_id'] ?? null;

if ($idRecipe) {


$sql = "DELETE FROM dbo.saved_recipes
        WHERE user_id = ?
        AND recipe_id = ?";

$stmt = $pdo->prepare($sql);
$stmt->execute([$idUser, $idRecipe]);
}


header('Location: index.php?page=userPage');
exit;
?>