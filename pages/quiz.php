

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Foodiz - Food Profile</title>

    <link rel="stylesheet" href="../style.css">
</head>

<body>

    <h1>Foodiz Quiz</h1>

    <button id="startQuiz" type="button">Start Quiz</button>

    <section class="food-profile">

        <h2>Your Food Profile</h2>
        <p>Choose the answers that best match your needs.</p>

        <form id="foodProfileForm">

            <!-- Question 1 -->
            <fieldset>
                <legend>1. How many people are you cooking for?</legend>

                <label><input type="radio" name="people" value="1" required> 1 person</label>
                <label><input type="radio" name="people" value="2"> 2 people</label>
                <label><input type="radio" name="people" value="3"> 3 people</label>
                <label><input type="radio" name="people" value="4"> 4 people</label>
                <label><input type="radio" name="people" value="5"> 5 people</label>
                <label><input type="radio" name="people" value="6"> 6 people</label>
            </fieldset>

            <!-- Question 2 -->
            <fieldset>
                <legend>2. What is your food budget?</legend>

                <label><input type="radio" name="budget" value="20" required> €20</label>
                <label><input type="radio" name="budget" value="30"> €30</label>
                <label><input type="radio" name="budget" value="40"> €40</label>
                <label><input type="radio" name="budget" value="50"> €50</label>
                <label><input type="radio" name="budget" value="60"> €60</label>
                <label><input type="radio" name="budget" value="70"> €70</label>
                <label><input type="radio" name="budget" value="80"> €80</label>
                <label><input type="radio" name="budget" value="90"> €90</label>
                <label><input type="radio" name="budget" value="100"> €100</label>
            </fieldset>

            <!-- Question 3 -->
            <fieldset>
                <legend>3. Do you follow a specific diet?</legend>

                <p>You can select multiple answers.</p>

                <label>
                    <input type="checkbox" name="diet" value="Regular" id="regular">
                    No specific restrictions (Regular)
                </label>

                <label><input type="checkbox" name="diet" value="Vegetarian"> Vegetarian</label>
                <label><input type="checkbox" name="diet" value="Vegan"> Vegan</label>
                <label><input type="checkbox" name="diet" value="Pescatarian"> Pescatarian</label>
                <label><input type="checkbox" name="diet" value="Lactose-free"> Lactose-free</label>
                <label><input type="checkbox" name="diet" value="Gluten-free"> Gluten-free</label>

            </fieldset>

            <button type="submit">Save my food profile</button>

        </form>

        <pre id="profileResult"></pre>

    </section>

    <script src="../js/main.js"></script>

</body>
</html>
