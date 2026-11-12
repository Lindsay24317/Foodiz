
<?php

// Réponse au format JSON
header('Content-Type: application/json; charset=utf-8');

try {

    // Connexion à la base Foodiz
    require_once __DIR__ . '/../config/database.php';

    // Récupérer les lieux avec des coordonnées
    $sql = "SELECT name, category, address, postal_code,
                   city, latitude, longitude, opening_hours, phone
            FROM dbo.food_banks
            WHERE latitude IS NOT NULL
            AND longitude IS NOT NULL";

    // Exécuter la requête
    $statement = $pdo->query($sql);

    // Récupérer les résultats
    $lieux = $statement->fetchAll(PDO::FETCH_ASSOC);

    // Envoyer les lieux en JSON
    echo json_encode($lieux);

} catch (Throwable $e) {

    // Erreur du serveur
    http_response_code(500);

    echo json_encode([
        'error' => 'Impossible de charger les lieux'
    ]);
}
