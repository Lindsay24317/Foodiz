<?php

// unset($_SESSION);
$_SESSION = [];

session_destroy();

header('Location: index.php?page=login');
exit;