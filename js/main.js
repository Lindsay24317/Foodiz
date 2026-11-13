
// FOOD PROFILE

const foodProfileForm = document.getElementById("foodProfileForm");

if (foodProfileForm) {
              
    // Get all seven questions
    const questions = foodProfileForm.querySelectorAll("fieldset");

    // Find the existing Save button
    const saveButton = foodProfileForm.querySelector('button[type="submit"]');

    // Put Save button inside the last question
    const lastQuestion = questions[questions.length - 1];
    lastQuestion.appendChild(saveButton);

    // Current question number (starts at 0)
    let currentQuestion = 0;

    // Show progress
    const progress = document.createElement("p");
    foodProfileForm.prepend(progress);

    // Show only the current question
    function showQuestion(index) {

        questions.forEach(function(question, i) {
            question.style.display = i === index ? "block" : "none";
        });

        currentQuestion = index;

        progress.textContent =
            "Question " + (index + 1) + " of " + questions.length;

        // Hide Save button except on final question
        saveButton.style.display =
            index === questions.length - 1 ? "inline-block" : "none";
    }

    // Check required questions
    function validateQuestion(index) {

        const requiredNames = ["people", "budget", "budgetPeriod"];

        // Only first three questions are required
        if (index < 3) {

            const name = requiredNames[index];

            const selected = foodProfileForm.querySelector(
                'input[name="' + name + '"]:checked'
            );

            if (!selected) {
                alert("Please answer this question before continuing.");
                return false;
            }
        }

        return true;
    }

    // Create navigation buttons for each question
    questions.forEach(function(question, index) {

        const navigation = document.createElement("div");
        navigation.classList.add("quiz-navigation");

        // Previous button
        if (index > 0) {

            const previousButton = document.createElement("button");

            previousButton.type = "button";
            previousButton.textContent = "Previous";

            previousButton.addEventListener("click", function() {
                showQuestion(index - 1);
            });

            navigation.appendChild(previousButton);
        }

        // Next button (questions 1 to 6)
        if (index < questions.length - 1) {

            const nextButton = document.createElement("button");

            nextButton.type = "button";
            nextButton.textContent = "Next";

            nextButton.addEventListener("click", function() {

                if (validateQuestion(index)) {
                    showQuestion(index + 1);
                }

            });

            navigation.appendChild(nextButton);
        }

        // Skip button only for optional questions 4 to 7
        if (index >= 3) {

            const skipButton = document.createElement("button");

            skipButton.type = "button";

            skipButton.textContent =
                index === questions.length - 1
                    ? "Skip & Save"
                    : "Skip";

            skipButton.addEventListener("click", function() {

                if (index === questions.length - 1) {
                    foodProfileForm.requestSubmit();
                } else {
                    showQuestion(index + 1);
                }

            });

            navigation.appendChild(skipButton);
        }

        question.appendChild(navigation);
    });

    // Regular diet cannot be combined with other diets
    const dietCheckboxes =
        foodProfileForm.querySelectorAll('input[name="diet"]');

    const regularCheckbox = document.getElementById("regular");

    dietCheckboxes.forEach(function(checkbox) {

        checkbox.addEventListener("change", function() {

            if (checkbox === regularCheckbox && checkbox.checked) {

                dietCheckboxes.forEach(function(diet) {
                    if (diet !== regularCheckbox) {
                        diet.checked = false;
                    }
                });

            } else if (checkbox !== regularCheckbox && checkbox.checked) {

                regularCheckbox.checked = false;

            }

        });

    });

    // Save answers
    foodProfileForm.addEventListener("submit", function(event) {

        event.preventDefault();

        // Make sure the first three questions are answered
        for (let i = 0; i < 3; i++) {
            if (!validateQuestion(i)) {
                showQuestion(i);
                return;
            }
        }

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

        const budgetPeriod = foodProfileForm.querySelector(
            'input[name="budgetPeriod"]:checked'
        ).value;

        const diets = Array.from(
            foodProfileForm.querySelectorAll(
                'input[name="diet"]:checked'
            )
        ).map(function(input) {
            return input.value;
        });

        const cookingTimeInput = foodProfileForm.querySelector(
            'input[name="cookingTime"]:checked'
        );

        const cookingTime = cookingTimeInput
            ? Number(cookingTimeInput.value)
            : null;

        const allergies = Array.from(
            foodProfileForm.querySelectorAll(
                'input[name="allergies"]:checked'
            )
        ).map(function(input) {
            return input.value;
        });

        const equipment = Array.from(
            foodProfileForm.querySelectorAll(
                'input[name="equipment"]:checked'
            )
        ).map(function(input) {
            return input.value;
        });

        const foodProfile = {
            people: people,
            budget: budget,
            budgetPeriod: budgetPeriod,
            diets: diets,
            cookingTime: cookingTime,
            allergies: allergies,
            equipment: equipment
        };

        console.log(foodProfile);

        document.getElementById("profileResult").textContent =
            JSON.stringify(foodProfile, null, 2);

        alert("Your Food Profile answers have been collected!");
    });

    // Start with question 1
    showQuestion(0);
}
 