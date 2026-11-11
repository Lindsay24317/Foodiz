<?php

$errors = [];

$values = [ 'email' => '' ];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

  $values['firstname'] = trim($_POST['firstname']) ?? '';
  $values['lastname'] = trim($_POST['lastname']) ?? '';
  $values['email'] = trim($_POST['email']) ?? '';
  $password = trim($_POST["password"]);
  $confirmation = trim($_POST["confirmation"]);

  // Validation
  if ($values['firstname'] === '') {
    $errors['firstname'] =  "the firstname is required";
  }

  if ($values['lastname'] === '') {
    $errors['lastname'] =  "the lastname is required";
  }

  if ($values['email'] === '') {
    $errors['email'] =  "the email adress is required";
  }
  else if (!filter_var($values['email'], FILTER_VALIDATE_EMAIL)) {
    $errors['email'] = "The email format is incorrect";
  }
  else if (strlen($values['email']) > 180) {
    $errors['email'] = "The email cannot exceed 180 characters.";
  }

  if ($password === '') {
    $errors['password'] = "A password is required.";
  }
  else if (strlen($password) < 8) {
    $errors['password'] = "The password must be at least 8 characters long.";
  }

  if ($password !== $confirmation) {
    $errors['confirmation'] = "The two passwords do not match.";
  }


  // Enregistrer les données en DB
  if (!$errors) {

    try {
      
      $password_hash = password_hash($password, PASSWORD_DEFAULT);

      $sql = "INSERT INTO utilisateur (firstname, lastname, email, password)
              VALUES (?, ?, ?, ?)";

      $statement = $pdo->prepare($sql);
      $statement->execute([$values['email'], $password_hash]);

      $_SESSION['user'] = [
        'id' => $pdo->lastInsertId(),
        'email' => $values['email'],
        'role' => 'user'
      ] ;     

      header("Location: index.php");
      exit();

    } catch (PDOException $e) {
      $errors['email'] = "That email address is already taken.";
    }

  }

}

?>

<h1>Register</h1>

<form method="post">

    <div>
    <label for="firstname">Firstname:</label>
    <input type="firstname" name="firstname" id="firstname" value="<?= $values['firstname'] ?>">
    <?php if(isset($errors['firstname'])) : ?>
      <span class="error"><?= $errors['firstname'] ?></span>
    <?php endif ?>
  </div>

  <div>
    <label for="lastname">Lastname:</label>
    <input type="lastname" name="lastname" id="lastname" value="<?= $values['lastname'] ?>">
    <?php if(isset($errors['lastname'])) : ?>
      <span class="error"><?= $errors['lastname'] ?></span>
    <?php endif ?>
  </div>

  <div>
    <label for="email">Email:</label>
    <input type="email" name="email" id="email" value="<?= $values['email'] ?>">
    <?php if(isset($errors['email'])) : ?>
      <span class="error"><?= $errors['email'] ?></span>
    <?php endif ?>
  </div>

  <div>
    <label for="password">Password:</label>
    <input type="password" name="password" id="password">
    <?php if(isset($errors['password'])) : ?>
      <span class="error"><?= $errors['password'] ?></span>
    <?php endif ?>
  </div>


  <div>
    <label for="confirmation">Confirmation:</label>
    <input type="password" name="confirmation" id="confirmation">
    <?php if(isset($errors['confirmation'])) : ?>
      <span class="error"><?= $errors['confirmation'] ?></span>
    <?php endif ?>
  </div>

  <button>Register</button>

</form>

<p>Déjà inscrit ? <a href="index.php?page=login">Log in!</a></p>