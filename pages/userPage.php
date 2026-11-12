<?php

if (!isset($_SESSION['user'])) {
    header('Location: index.php?page=login');
    exit;
}
// Récupération de l'id et de l'email de l'utilisateur
$idUser = $_SESSION['user']['id'];

$sql = "SELECT firstname, lastname, email
        FROM dbo.users
        WHERE id_user = ?";

$stmt = $pdo->prepare($sql);
$stmt->execute([$idUser]);

$user = $stmt->fetch(PDO::FETCH_ASSOC);

//Récupération des recettes de l'utilisateur
$sql = "SELECT r.id_recipe, 
               r.name, 
               r.description, 
               r.estimated_cost,
               r.preparation_time,
               r.cooking_time,
               r.image,
               sr.saved_at
        FROM dbo.saved_recipes sr
        INNER JOIN dbo.recipes r
              ON sr.recipe_id = r.id_recipe
        WHERE sr.user_id = ?";

$stmt = $pdo->prepare($sql);
$stmt->execute([$idUser]);

$recipes = $stmt->fetchAll(PDO::FETCH_ASSOC);

?>

<h1>Mon profil</h1>

<h2>Mes informations</h2>

<p>Prenom : <?= htmlspecialchars($user['firstname']) ?></p>
<p>Nom : <?= htmlspecialchars($user['lastname']) ?></p>
<p>Email : <?= htmlspecialchars($user['email']) ?></p>

<h2>My recipes</h2>

<!-- Vérification de si l'utilisateur possède des recettes -->
<?php if (empty($recipes)): ?>

    <p>You haven't saved any recipes yet.</p>

<?php else: ?>

    <?php foreach ($recipes as $recipe): ?>
    
        <div class="card-recipe">
    
            <h3><?= htmlspecialchars($recipe['name']) ?></h3>

            <?php if (!empty($recipe['image'])): ?>
            <img
                src="<?= htmlspecialchars($recipe['image']) ?>"
                alt="<?= htmlspecialchars($recipe['name']) ?>"
            >
            <?php endif; ?>
    
            <p><?= htmlspecialchars($recipe['description']) ?></p>
    
            <p>Estimated cost : <?= htmlspecialchars($recipe['estimated_cost']) ?>€</p>
    
            <p>Preparation time : <?= htmlspecialchars($recipe['preparation_time']) ?> minutes</p>
            
            <p>Cooking time :
                <?= htmlspecialchars($recipe['cooking_time']) ?> minutes
            </p>
        </div>
    
    <?php endforeach; ?>
<?php endif; ?>