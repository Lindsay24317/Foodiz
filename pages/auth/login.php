
<?php

// Tableau des erreurs
$errors = [];

// Valeur du formulaire
$values = ['email' => ''];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // Récupérer les données
    $values['email'] = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';

    // Vérifier l'email
    if ($values['email'] === '') {
        $errors['email'] = "The email address is required";
    }
    else if (!filter_var($values['email'], FILTER_VALIDATE_EMAIL)) {
        $errors['email'] = "The email format is incorrect";
    }

    // Vérifier le mot de passe
    if ($password === '') {
        $errors['password'] = "The password is required";
    }

    // Vérifier les identifiants dans la DB
    if (!$errors) {

        // Rechercher l'utilisateur
        $sql = "SELECT id_user, firstname, lastname, email, password,role
                FROM dbo.users
                WHERE email = ?";

        $statement = $pdo->prepare($sql);
        $statement->execute([$values['email']]);

        $user = $statement->fetch(PDO::FETCH_ASSOC);

        // Vérifier le mot de passe
        if (!$user || !password_verify($password, $user['password'])) {
            $errors['global'] = "Email or password is incorrect";
        }
        else {

            // Enregistrer la session
            $_SESSION['user'] = [
                'id' => $user['id_user'],
                'firstname' => $user['firstname'],
                'lastname' => $user['lastname'],
                'email' => $user['email'],
                'role' => $user['role']
            ];

            // Rediriger vers la carte
            header("Location: index.php?page=map");
            exit();
        }
    }
}

?>

<!-- Titre -->
<h1>Login</h1>

<!-- Formulaire de connexion -->
<form method="post">

    <!-- Erreur de connexion -->
    <?php if (isset($errors['global'])) : ?>
        <span class="error">
            <?= htmlspecialchars($errors['global']) ?>
        </span>
    <?php endif; ?>

    <!-- Email -->
    <div>
        <label for="email">Email:</label>
        <input
            type="email"
            name="email"
            id="email"
            value="<?= htmlspecialchars($values['email']) ?>"
        >

        <?php if (isset($errors['email'])) : ?>
            <span class="error">
                <?= htmlspecialchars($errors['email']) ?>
            </span>
        <?php endif; ?>
    </div>

    <!-- Mot de passe -->
    <div>
        <label for="password">Password:</label>
        <input
            type="password"
            name="password"
            id="password"
        >

        <?php if (isset($errors['password'])) : ?>
            <span class="error">
                <?= htmlspecialchars($errors['password']) ?>
            </span>
        <?php endif; ?>
    </div>

    <!-- Bouton de connexion -->
    <button type="submit">Login</button>

</form>

<!-- Lien vers l'inscription -->
<p>
    Don't have an account?
    <a href="index.php?page=register">Register!</a>
</p>
