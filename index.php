<?php

session_start();

// Gestion des routes
$routes = [

  '' => [
    'file' => 'pages/home.php',
    'title' => 'Homepage'
  ],


  //Gestion des recettes

  'recipes' => [
    'file' => 'pages/recipes/recipes.php',
    'title' => 'List of recipes',
  ],

  'recipes-details' => [
    'file' => 'pages/recipes/details.php',
    'title' => 'Recipe Details',
  ],

  //added by Farah for - route for favourites
  'favourite' => [
    'file' => 'pages/recipes/favourite.php',
    'title' => 'Favourites',
    'roles' => ['user', 'admin'],
  ],
  // Delete favourite route
  'remove-favourite' => [
    'file' => 'pages/recipes/remove-favourite.php',
    'title' => 'Remove favourite',
    'role' => ['user'],
  ],

  //Gestion de la map

  'map' => [
    'file' => 'pages/map.php',
    'title' => 'Foodiz - Map',
  ],


  //Gestion du quiz

  'quiz' => [
    'file' => 'pages/quiz.php',
    'title' => 'Foodiz - Quiz',
  ],


  //gestion du sujet

  'about' => [
    'file' => 'pages/about.php',
    'title' => 'About Us',
  ],


  //Gestion de contact


  'contact' => [
    'file' => 'pages/contact.php',
    'title' => 'Contact',
  ],


  //Gestion de profile utilisateur


  'userPage' => [
    'file' => 'pages/userPage.php',
    'title' => 'My Account',
    'roles' => ['user', 'admin'],
  ],


  // Gestion de l'authentification


  'register' => [
    'file' => 'pages/auth/register.php',
    'title' => 'Register',
  ],

  'login' => [
    'file' => 'pages/auth/login.php',
    'title' => 'Login',
  ],

  'logout' => [
    'file' => 'pages/auth/logout.php',
    'title' => 'Logout',
  ],

];

$page = $_GET['page'] ?? '';
$route = $routes[$page] ?? null;

if ($route === null) {
  $route = [
    'file' => 'pages/errors/not-found.php',
    'title' => "404 not found"
  ];
}

$requiredRoles = $route['roles'] ?? null;
if ($requiredRoles !== null) {

  if (!isset($_SESSION['user'])) {
    header("Location: index.php?page=login");
    exit;
  }

  if (!in_array($_SESSION['user']['role'], $requiredRoles)) {
    $route = [
      'file' => 'pages/errors/forbidden.php',
      'title' => "403 forbidden"
    ];
  }
}

$file = $route["file"];
$title = $route["title"];

require_once 'config/database.php';

// Assembler les pages

ob_start();
require_once $file;
$content = ob_get_clean();


require_once 'partials/header.php';
echo $content;
require_once 'partials/footer.php';
