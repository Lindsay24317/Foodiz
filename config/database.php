 <?php

// Information de connexion à la base de données

$source = "sqlsrv";
$host = "localhost"; // Server name sur SSMS
$dbname = "foodiz";

$dsn = "$source:Server=$host;Database=$dbname;TrustServerCertificate=true";
$user = "demo_user";
$pass = "Test1234=";
$options = [
  PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
  PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
];

// Tentative de connexion
try {
  $pdo = new PDO($dsn, $user, $pass, $options);
} catch (PDOException $e) {
  die("Erreur de connexion : " . $e->getMessage());
}

