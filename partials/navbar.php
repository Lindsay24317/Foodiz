
<nav class="navbar">
    <ul>
        <li><a href="index.php">Home</a></li>
        <li><a href="index.php?page=quiz">Take the Quiz</a></li>
        <li><a href="index.php?page=recipes">Recipes</a></li>
        <li><a href="index.php?page=map">Find Food Nearby</a></li>
        <li><a href="index.php?page=about">About Us</a></li>
        <li><a href="index.php?page=contact">Contact</a></li>
    </ul>

    <ul>
        <?php if (!isset($_SESSION['user'])) : ?>
            <li><a href="index.php?page=login">Sign In</a></li>
            <li><a href="index.php?page=register">Sign Up</a></li>
        <?php else : ?>
            <li><a href="index.php?page=userPage">My Account</a></li>
            <li><a href="index.php?page=logout">Log Out</a></li>
        <?php endif ?>
    </ul>
</nav>
