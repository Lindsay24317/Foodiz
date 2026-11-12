
// FOOD PROFILE

const foodProfileForm = document.getElementById("foodProfileForm");

if (foodProfileForm) {

    // Question 3: Regular cannot be combined with other diets

    const dietCheckboxes = document.querySelectorAll(
        'input[name="diet"]'
    );

    const regularCheckbox = document.getElementById("regular");

    dietCheckboxes.forEach(function (checkbox) {

        checkbox.addEventListener("change", function () {

            if (checkbox === regularCheckbox && checkbox.checked) {

                // If Regular is selected, uncheck all other diets
                dietCheckboxes.forEach(function (diet) {
                    if (diet !== regularCheckbox) {
                        diet.checked = false;
                    }
                });

            } else if (checkbox !== regularCheckbox && checkbox.checked) {

                // If another diet is selected, uncheck Regular
                regularCheckbox.checked = false;

            }
        }); 
    });
     // Question 4: Ingredients selection

    const ingredientCheckboxes = foodProfileForm.querySelectorAll(
        'input[name="ingredients"]'
    );

    const allIngredientsCheckbox = document.getElementById("allIngredients");

    ingredientCheckboxes.forEach(function (checkbox) {

        checkbox.addEventListener("change", function () {

            if (checkbox === allIngredientsCheckbox && checkbox.checked) {

                // If All is selected, uncheck other ingredients
                ingredientCheckboxes.forEach(function (ingredient) {
                    if (ingredient !== allIngredientsCheckbox) {
                        ingredient.checked = false;
                    }
                });

            } else if (checkbox !== allIngredientsCheckbox && checkbox.checked) {

                // If another ingredient is selected, uncheck All
                allIngredientsCheckbox.checked = false;
            }
        });
    });

    // Question 6: None cannot be combined with other allergies

    const allergyCheckboxes = document.querySelectorAll(
        'input[name="allergies"]'
    );

    const noAllergies = document.getElementById("noAllergies");

    allergyCheckboxes.forEach(function (checkbox) {
        checkbox.addEventListener("change", function () {

            if (checkbox === noAllergies && checkbox.checked) {
                allergyCheckboxes.forEach(function (item) {
                    if (item !== noAllergies) {
                        item.checked = false;
                    }
                });
            } else if (checkbox !== noAllergies && checkbox.checked) {
                noAllergies.checked = false;
            }

        });
    });


    // Save the selected answers

    foodProfileForm.addEventListener("submit", function (event) {

        event.preventDefault();
        
         // Question 1: People
        const peopleInput = foodProfileForm.querySelector(
            'input[name="people"]:checked'
        );

        // Question 2: Budget
        const budgetInput = foodProfileForm.querySelector(
            'input[name="budget"]:checked'
        );

        // Check required questions
        if (!peopleInput || !budgetInput) {
            alert("Please answer questions 1 and 2.");
            return;
        }

        const people = Number(peopleInput.value);
        const budget = Number(budgetInput.value);

        // Question 3: Selected diets
        const diets = Array.from(
            foodProfileForm.querySelectorAll(
                'input[name="diet"]:checked'
            )
        ).map(function (checkbox) {
            return checkbox.value;
        });

        // Question 4: Selected ingredients
        const ingredients = Array.from(
            foodProfileForm.querySelectorAll(
                'input[name="ingredients"]:checked'
            )
        ).map(function (checkbox) {
            return checkbox.value;
        });

        // Custom ingredients entered by the user
        const otherIngredients = foodProfileForm.querySelector(
            "#otherIngredients"
        ).value.trim();

        // Store all answers
        const foodProfile = {
            people: people,
            budget: budget,
            diets: diets,
            ingredients: ingredients,
            otherIngredients: otherIngredients,
            cookingTime: cookingTime,
            allergies: allergies,
            mealType: mealType,
            cuisine: cuisine,
            foodGoal: foodGoal,
            dislikedIngredients: dislikedIngredients,
            equipment: equipment
        };

        console.log(foodProfile);

        document.getElementById("profileResult").textContent =
            JSON.stringify(foodProfile, null, 2);
    });

}
 