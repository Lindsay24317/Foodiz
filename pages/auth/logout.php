<?php

//  Vider la session
$_SESSION = [];
// Détruire la session
session_destroy();
// Rediriger vers le login
header('Location: index.php?page=login');
exit;