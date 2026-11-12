// Création de la carte centrée sur la Belgique
const map = L.map('map', {
    scrollWheelZoom: false // Désactiver le zoom avec la molette
}).setView([50.5, 4.5], 8);

// recuperation des images pour le fond de carte
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; OpenStreetMap contributors'
}).addTo(map);


 // Récupérer les lieux depuis notre base de données
fetch("api/food_locations.php")
    .then(response => response.json())
    .then(lieux => {

        // Parcourir les lieux
        lieux.forEach(lieu => {

            // Créer la fenêtre d'information
            const popup = document.createElement("div");

            // Nom du lieu
            const nom = document.createElement("h3");
            nom.textContent = lieu.name;
            popup.appendChild(nom);

            // Adresse
            if (lieu.address) {
                const adresse = document.createElement("p");
                adresse.textContent = "📍 " + lieu.address;
                popup.appendChild(adresse);
            }

            // Ville
            if (lieu.city && lieu.city !== "Unknown") {
                const ville = document.createElement("p");
                ville.textContent = "🏙️ " + lieu.city;
                popup.appendChild(ville);
            }

            // Horaires
            if (lieu.opening_hours) {
                const horaires = document.createElement("p");
                horaires.textContent = "🕒 " + lieu.opening_hours;
                popup.appendChild(horaires);
            }

            // Téléphone
            if (lieu.phone) {
                const telephone = document.createElement("p");
                telephone.textContent = "📞 " + lieu.phone;
                popup.appendChild(telephone);
            }

            // Ajouter le marqueur
            L.marker([lieu.latitude, lieu.longitude])
                .addTo(map)
                .bindPopup(popup);
        });
    })
    .catch(error => {
        // Afficher les erreurs
        console.error("Erreur de chargement :", error);
    });
