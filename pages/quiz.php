

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

  <!--  <button id="startQuiz" type="button">Start Quiz</button>-->

    <section class="food-profile">

        <h2>Your Food Profile</h2>
        <p>Choose the answers that best match your needs.</p>

        <form id="foodProfileForm" novalidate>

            <!-- Question 1 Number of people-->
            <fieldset>
                <legend>1. How many people are you cooking for?</legend>
                <label><input type="radio" name="people" value="1" required> 1 person</label>
                <label><input type="radio" name="people" value="2"> 2 people</label>
                <label><input type="radio" name="people" value="3"> 3 people</label>
                <label><input type="radio" name="people" value="4"> 4 people</label>
                <label><input type="radio" name="people" value="5"> 5 people</label>
                <label><input type="radio" name="people" value="6"> 6 people</label>
            </fieldset>

            <!-- Question 2 Food budget-->
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

            <!-- Question 3: Budget period -->
            <fieldset>
                <legend>3. How often is this your food budget?</legend>

                <label><input type="radio" name="budgetPeriod" value="Weekly" required> Weekly</label>
                <label><input type="radio" name="budgetPeriod" value="Monthly"> Monthly</label>
            </fieldset>

            <!-- Question 4 Dietary preference-->
            <fieldset>
                <legend>4. Do you follow a specific diet?</legend>
                <p>You can select multiple options.</p>
                <label>
                    <input type="checkbox" name="diet" value="Regular" id="regular"> No specific restrictions (Regular)</label>
                <label><input type="checkbox" name="diet" value="Vegetarian"> Vegetarian</label>
                <label><input type="checkbox" name="diet" value="Vegan"> Vegan</label>
                <label><input type="checkbox" name="diet" value="Pescatarian"> Pescatarian</label>
                <label><input type="checkbox" name="diet" value="Lactose-free"> Lactose-free</label>
                <label><input type="checkbox" name="diet" value="Gluten-free"> Gluten-free</label>
            </fieldset>            
            
            <!-- Question 5: Cooking time -->
            <fieldset>
                <legend>5. what is your maximum cooking time?</legend>

                <label><input type="radio" name="cookingTime" value="15"> Up to 15 minutes</label>
                <label><input type="radio" name="cookingTime" value="30"> Up to 30 minutes</label>
                <label><input type="radio" name="cookingTime" value="60"> Up to 60 minutes</label>
                <label><input type="radio" name="cookingTime" value="120"> More than 60 minutes</label>
            </fieldset>

            <!-- Question 6: Food allergies -->
            <fieldset>
                <legend>6. Do you have any food allergies?</legend>

                <label><input type="checkbox" name="allergies" value="Peanuts"> Peanuts</label>
                <label><input type="checkbox" name="allergies" value="Tree nuts"> Tree nuts</label>
                <label><input type="checkbox" name="allergies" value="Milk"> Milk</label>
                <label><input type="checkbox" name="allergies" value="Eggs"> Eggs</label>
                <label><input type="checkbox" name="allergies" value="Soy"> Soy</label>
                <label><input type="checkbox" name="allergies" value="Fish"> Fish</label>
                <label><input type="checkbox" name="allergies" value="Shellfish"> Shellfish</label>
                <label><input type="checkbox" name="allergies" value="Wheat"> Wheat</label>
                <label><input type="checkbox" name="allergies" value="Sesame"> Sesame</label>
            </fieldset>
           
            <!-- Question 7: Cooking equipment -->
            <fieldset>
                <legend>7. What cooking equipment do you have?</legend>
                <p>You can select multiple options.</p>
                <label><input type="checkbox" name="equipment" value="Oven"> Oven</label>
                <label><input type="checkbox" name="equipment" value="Microwave"> Microwave</label>
                <label><input type="checkbox" name="equipment" value="Stovetop"> Stovetop</label>
                <label><input type="checkbox" name="equipment" value="Air fryer"> Air fryer</label>
                <label><input type="checkbox" name="equipment" value="Blender"> Blender</label>
                <label><input type="checkbox" name="equipment" value="Food processor"> Food processor</label>
                <label><input type="checkbox" name="equipment" value="Rice cooker"> Rice cooker</label>
            </fieldset>

            <button type="submit">Save my food profile</button>

        </form>

        <!-- Résultats du quiz -->
        <div id="profileResult"></div>

    </section>

    <script src="js/main.js"></script>

</body>
</html>
