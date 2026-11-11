<?php

$errors = [];

$values = [ 'email' => '' ];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

  $values['email'] = trim($_POST['email']) ?? '';
  $password = trim($_POST["password"]);

  // Validation
  if ($values['email'] === '') {
    $errors['email'] =  "The email adress is required";
  }
  else if (!filter_var($values['email'], FILTER_VALIDATE_EMAIL)) {
    $errors['email'] = "The email format is incorrect";
  }

  if ($password === '') {
    $errors['password'] = "the password is required";
  }

  // Vérifier si les identifiants sont corrects
  if (!$errors) {

    $sql = "SELECT id, email, password, 
            role FROM utilisateur 
            WHERE email = ?";

    $statement = $pdo->prepare($sql);
    $statement->execute([$values['email']]);

    $user = $statement->fetch();

    if (!$user || !password_verify($password, $user['password'])) {
      $errors['global'] = "email or/and password is incorrect";
    }
    else {
      $_SESSION['user'] = [
        'id' => $user['id'],
        'email' => $values['email'],
        'role' => $user['role']
      ];

      header("Location: index.php?page=profil");
    }

  }

}

?>



<h1>Login</h1>

<form method="post">

    <?php if(isset($errors['global'])) : ?>
      <span class="error"><?= $errors['global'] ?></span>
    <?php endif ?>

  <div>
    <label for="email">Email:</label>
    <input type="email" name="email" id="email" value="<?= $values['email'] ?>">
    <?php if(isset($errors['email'])) : ?>
      <span class="error"><?= $errors['email'] ?></span>
    <?php endif ?>
  </div>


  <div>
    <label for="password">Mot de passe:</label>
    <input type="password" name="password" id="password">
    <?php if(isset($errors['password'])) : ?>
      <span class="error"><?= $errors['password'] ?></span>
    <?php endif ?>
  </div>

  <button>Login</button>

</form>

<p>Pas encore inscrit ? <a href="index.php?page=register">Register !</a></p>