
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


    // Save the selected answers

    foodProfileForm.addEventListener("submit", function (event) {

        event.preventDefault();

        const people = Number(
            foodProfileForm.querySelector(
                'input[name="people"]:checked'
            ).value
        );

        const budget = Number(
            foodProfileForm.querySelector(
                'input[name="budget"]:checked'
            ).value
        );

        const diets = Array.from(
            foodProfileForm.querySelectorAll(
                'input[name="diet"]:checked'
            )
        ).map(function (checkbox) {
            return checkbox.value;
        });

        const foodProfile = {
            people: people,
            budget: budget,
            diets: diets
        };

        console.log(foodProfile);

        document.getElementById("profileResult").textContent =
            JSON.stringify(foodProfile, null, 2);

    });

}
