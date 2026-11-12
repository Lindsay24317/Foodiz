<?php

if (!isset($_SESSION['user'])) {
    header('Location: index.php?page=login');
    exit;
}
// Récupération de l'id et de l'email de l'utilisateur
$idUser = $_SESSION['user']['id'] ?? 0;

$sql = "SELECT firstname, lastname, email
        FROM dbo.users
        WHERE id_user = ?";

$stmt = $pdo->prepare($sql);
$stmt->execute([$idUser]);

$user = $stmt->fetch(PDO::FETCH_ASSOC);
$idUser = $_SESSION['user']['id'];


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

<div class="recipes-grid">

    <?php foreach ($recipes as $recipe): ?>

        <article class="recipe-card">

            <div class="recipe-image-container">

                <a href="index.php?page=recipes-details&id=<?= urlencode($recipe['id_recipe']) ?>">

                    <?php if (!empty($recipe['image'])): ?>

                        <img
                            src="<?= htmlspecialchars($recipe['image']) ?>"
                            alt="<?= htmlspecialchars($recipe['name']) ?>"
                            class="recipe-image"
                        >

                    <?php endif; ?>

                </a>

            </div>

            <a
                href="index.php?page=recipes-details&id=<?= urlencode($recipe['id_recipe']) ?>"
                class="recipe-card-link"
            >

                <div class="recipe-info">

                    <h2><?= htmlspecialchars($recipe['name']) ?></h2>

                    <p>
                        <?= htmlspecialchars($recipe['description'] ?? '') ?>
                    </p>

                    <div class="recipe-meta">

                        <span>
                            ⏱ <?= (int)$recipe['preparation_time'] + (int)$recipe['cooking_time'] ?> min
                        </span>

                        <span>
                            <?= number_format((float)$recipe['estimated_cost'], 2, ',', ' ') ?> €
                        </span>

                    </div>

                </div>

            </a>

        </article>

    <?php endforeach; ?>

</div>

<?php endif; ?>