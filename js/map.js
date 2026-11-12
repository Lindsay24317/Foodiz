// Création de la carte centrée sur la Belgique
const map = L.map('map', {
    scrollWheelZoom: false // Désactiver le zoom avec la molette
}).setView([50.5, 4.5], 8);

// recuperation des images pour le fond de carte
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; OpenStreetMap contributors'
}).addTo(map);


// Groupe pour stocker les marqueurs
const markers = L.layerGroup().addTo(map);

 // Récupérer les lieux depuis notre base de données
fetch("api/food_locations.php")
    .then(response => response.json())
    .then(lieux => {

            // Compter tous les lieux
            document.getElementById("filter-all").textContent =
                `Tous (${lieux.length})`;
        
            // Compter les banques alimentaires
            document.getElementById("filter-food-bank").textContent =
                `Banques alimentaires (${lieux.filter(lieu => lieu.category === "food_bank").length})`;
        
            // Compter les frigos solidaires
            document.getElementById("filter-food-sharing").textContent =
                `Frigos solidaires (${lieux.filter(lieu => lieu.category === "food_sharing").length})`;
        
            // Compter les restaurants sociaux
            document.getElementById("filter-soup-kitchen").textContent =
                `Restaurants sociaux (${lieux.filter(lieu => lieu.category === "soup_kitchen").length})`;
        
        

            // Stocker les marqueurs et leurs catégories
            const tousLesMarqueurs = [];

                    
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

                // Créer le marqueur avec sa popup
                const marqueur = L.marker([lieu.latitude, lieu.longitude])
                .addTo(markers)
                .bindPopup(popup);

                // Garder le marqueur et sa catégorie
                tousLesMarqueurs.push({
                marqueur: marqueur,
                categorie: lieu.category
                });
            });

                // Filtrer les marqueurs
                function filtrer(categorie) {
                    markers.clearLayers();

                    tousLesMarqueurs.forEach(lieu => {
                        if (categorie === "all" || lieu.categorie === categorie) {
                            lieu.marqueur.addTo(markers);
                        }
                    });
                }
                // Clic sur les boutons
                document.getElementById("filter-all").addEventListener("click", () => filtrer("all"));
                document.getElementById("filter-food-bank").addEventListener("click", () => filtrer("food_bank"));
                document.getElementById("filter-food-sharing").addEventListener("click", () => filtrer("food_sharing"));
                document.getElementById("filter-soup-kitchen").addEventListener("click", () => filtrer("soup_kitchen"));
    })

    .catch(error => {
        // Afficher les erreurs
        console.error("Erreur de chargement :", error);
    });
