

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
                <p>You can select multiple options.</p>
                <label>
                    <input type="checkbox" name="diet" value="Regular" id="regular"> No specific restrictions (Regular)</label>
                <label><input type="checkbox" name="diet" value="Vegetarian"> Vegetarian</label>
                <label><input type="checkbox" name="diet" value="Vegan"> Vegan</label>
                <label><input type="checkbox" name="diet" value="Pescatarian"> Pescatarian</label>
                <label><input type="checkbox" name="diet" value="Lactose-free"> Lactose-free</label>
                <label><input type="checkbox" name="diet" value="Gluten-free"> Gluten-free</label>
            </fieldset>

            
            <!-- Question 4 -->
            <fieldset>
                <legend>4. What ingredients do you already have at home?</legend>

                <p>You can select multiple options.</p>
                <label><input type="checkbox" name="ingredients" value="All" id="allIngredients">
                    No specific ingredients - Show me all recipe options </label>

                <label><input type="checkbox" name="ingredients" value="Vegetables"> Vegetables</label>
                <label><input type="checkbox" name="ingredients" value="Rice"> Rice</label>
                <label><input type="checkbox" name="ingredients" value="Pasta"> Pasta</label>
                <label><input type="checkbox" name="ingredients" value="Potatoes"> Potatoes</label>
                <label><input type="checkbox" name="ingredients" value="Beans"> Beans</label>
                <label><input type="checkbox" name="ingredients" value="Meat"> Meat</label>
                <label><input type="checkbox" name="ingredients" value="Seafood"> Seafood</label>
                <label><input type="checkbox" name="ingredients" value="Other" id="otherOption">Other - Specify your ingredients </label>
                <label for="otherIngredients">Add other ingredients:</label>
                <input
                    type="text"
                    id="otherIngredients"
                    name="otherIngredients"
                    placeholder="Example: carrots, onions, cheese...">
            </fieldset>

            <!-- Question 5: Cooking time -->
            <fieldset>
                <legend>5. How much time do you have to cook?</legend>

                <label><input type="radio" name="cookingTime" value="Under 15 min"> Under 15 min</label>
                <label><input type="radio" name="cookingTime" value="15-30 min"> 15-30 min</label>
                <label><input type="radio" name="cookingTime" value="30-60 min"> 30-60 min</label>
                <label><input type="radio" name="cookingTime" value="Over 60 min"> Over 60 min</label>
            </fieldset>

            <!-- Question 6: Food allergies -->
            <fieldset>
                <legend>6. Do you have any food allergies?</legend>

                <label><input type="checkbox" name="allergies" value="Peanuts"> Peanuts</label>
                <label><input type="checkbox" name="allergies" value="Milk"> Milk</label>
                <label><input type="checkbox" name="allergies" value="Eggs"> Eggs</label>
                <label><input type="checkbox" name="allergies" value="Wheat"> Wheat</label>
                <label><input type="checkbox" name="allergies" value="Soy"> Soy</label>
                <label><input type="checkbox" name="allergies" value="Other"> Other</label>
                <label><input type="checkbox" name="allergies" value="None" id="noAllergies"> None</label>
            </fieldset>

            <!-- Question 7: Meal type -->
            <fieldset>
                <legend>7. What kind of meal are you looking for?</legend>

                <label><input type="checkbox" name="mealType" value="Breakfast"> Breakfast</label>
                <label><input type="checkbox" name="mealType" value="Lunch"> Lunch</label>
                <label><input type="checkbox" name="mealType" value="Dinner"> Dinner</label>
                <label><input type="checkbox" name="mealType" value="Snack"> Snack</label>
                <label><input type="checkbox" name="mealType" value="Dessert"> Dessert</label>
            </fieldset>

            <!-- Question 8: Cuisine -->
            <fieldset>
                <legend>8. What type of cuisine do you prefer?</legend>

                <label><input type="radio" name="cuisine" value="Italian"> Italian</label>
                <label><input type="radio" name="cuisine" value="Indian"> Indian</label>
                <label><input type="radio" name="cuisine" value="Asian"> Asian</label>
                <label><input type="radio" name="cuisine" value="Belgian"> Belgian</label>
                <label><input type="radio" name="cuisine" value="Mediterranean"> Mediterranean</label>
                <label><input type="radio" name="cuisine" value="Anything"> Anything</label>
            </fieldset>

            <!-- Question 9: Food goal -->
            <fieldset>
                <legend>9. What is your main food goal?</legend>

                <label><input type="radio" name="foodGoal" value="Save money"> Save money</label>
                <label><input type="radio" name="foodGoal" value="Eat balanced meals"> Eat balanced meals</label>
                <label><input type="radio" name="foodGoal" value="Reduce waste"> Reduce waste</label>
                <label><input type="radio" name="foodGoal" value="Cook quickly"> Cook quickly</label>
            </fieldset>

            <!-- Question 10: Disliked ingredients -->
            <fieldset>
                <legend>10. Which ingredients do you dislike or want to avoid?</legend>

                <textarea name="dislikedIngredients"
                        placeholder="Example: mushrooms, onions, garlic..."
                        rows="3"></textarea>
            </fieldset>

            <!-- Question 11: Cooking equipment -->
            <fieldset>
                <legend>11. What cooking equipment do you have?</legend>

                <label><input type="checkbox" name="equipment" value="Stove"> Stove</label>
                <label><input type="checkbox" name="equipment" value="Oven"> Oven</label>
                <label><input type="checkbox" name="equipment" value="Microwave"> Microwave</label>
                <label><input type="checkbox" name="equipment" value="Air fryer"> Air fryer</label>
                <label><input type="checkbox" name="equipment" value="Other"> Other</label>
            </fieldset>

            <button type="submit">Save my food profile</button>

        </form>

        <pre id="profileResult"></pre>

    </section>

    <script src="../js/main.js"></script>

</body>
</html>
