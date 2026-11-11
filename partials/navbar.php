<nav class="navbar">
     <a href="index.php" class="logo">Foodiz<span>.</span></a>
    <ul>
        <li><a href="index.php">Homepage</a></li>

        <li><a href="index.php?pages=recipes">Recipes</a></li>
        <li><a href="index.php?pages=quiz">Quiz</a></li>
        <li><a href="index.php?pages=about">About us</a></li>
        <li><a href="index.php?pages=map">Map</a></li>
        <li><a href="index.php?pages=contact">Contact us</a></li>
        <li><a href="index.php?pages=quiz">Quiz</a></li>

        <?php if (!isset($_SESSION['user'])) : ?>
          <li><a href="index.php?page=login">Login</a></li>
          <li><a href="index.php?page=register">Register</a></li>
        <?php else : ?>
          <li>Connecté en tant que : <?= $_SESSION['user']['prenom']?></li>
          <li><a href="index.php?page=User">User</a></li>
          <li><a href="index.php?page=logout">Logout</a></li>
        <?php endif ?>
        
    </ul>
</nav>