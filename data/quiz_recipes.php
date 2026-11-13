
<?php

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../config/database.php';

// Récupérer les réponses du quiz
$profile = json_decode(file_get_contents('php://input'), true);

if (!is_array($profile)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid quiz data']);
    exit;
}

$people = max(1, (int)($profile['people'] ?? 1));
$budget = (float)($profile['budget'] ?? 0);
$period = strtolower($profile['budgetPeriod'] ?? 'weekly');
$cookingTime = $profile['cookingTime'] ?? null;
$diets = $profile['diets'] ?? [];
$allergies = $profile['allergies'] ?? [];

if (!is_array($diets) || !is_array($allergies)
    || $budget <= 0 || !in_array($period, ['weekly', 'monthly'], true)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid food profile']);
    exit;
}

// Budget estimé par personne et par repas
$days = $period === 'monthly' ? 30 : 7;
$mealBudget = $budget / $days / $people;

// Retirer Regular des restrictions
$diets = array_values(array_diff($diets, ['Regular']));

// Filtrer les recettes
$sql = "
    SELECT
        r.id_recipe,
        r.name,
        r.description,
        r.image,
        r.estimated_cost,
        r.preparation_time,
        r.cooking_time
    FROM dbo.recipes r
    WHERE r.estimated_cost <= ?
";

$params = [$mealBudget];

// Temps total de préparation
if ($cookingTime !== null && $cookingTime !== '') {
    $sql .= "
        AND (
            COALESCE(r.preparation_time, 0)
            + COALESCE(r.cooking_time, 0)
        ) <= ?
    ";
    $params[] = (int)$cookingTime;
}

// Régimes alimentaires
foreach ($diets as $diet) {
    $sql .= "
        AND EXISTS (
            SELECT 1
            FROM dbo.recipe_categories rc
            INNER JOIN dbo.dietary_categories dc
                ON dc.id_category = rc.category_id
            WHERE rc.recipe_id = r.id_recipe
              AND dc.name = ?
        )
    ";
    $params[] = $diet;
}

// Exclure les allergènes déclarés
foreach ($allergies as $allergy) {
    $sql .= "
        AND NOT EXISTS (
            SELECT 1
            FROM dbo.recipe_allergies ra
            INNER JOIN dbo.allergies a
                ON a.id_allergy = ra.allergy_id
            WHERE ra.recipe_id = r.id_recipe
              AND a.name = ?
        )
    ";
    $params[] = $allergy;
}

$sql .= " ORDER BY r.estimated_cost ASC, r.name ASC";

try {
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);

    echo json_encode(
        $stmt->fetchAll(PDO::FETCH_ASSOC),
        JSON_UNESCAPED_UNICODE
    );
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Unable to load recipes']);
}
