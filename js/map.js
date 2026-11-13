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
                `All (${lieux.length})`;
        
            // Compter les banques alimentaires
            document.getElementById("filter-food-bank").textContent =
                `Food Banks (${lieux.filter(lieu => lieu.category === "food_bank").length})`;
        
            // Compter les frigos solidaires
            document.getElementById("filter-food-sharing").textContent =
                `Community Fridges (${lieux.filter(lieu => lieu.category === "food_sharing").length})`;
        
            // Compter les restaurants sociaux
            document.getElementById("filter-soup-kitchen").textContent =
                `Community Kitchens (${lieux.filter(lieu => lieu.category === "soup_kitchen").length})`;
        
            // Compter les lieux anti-gaspi
            document.getElementById("filter-anti-gaspi").textContent =
                `Food Waste Deals (${lieux.filter(lieu => lieu.category === "anti_gaspi").length})`;
                    

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

                // Couleur selon la catégorie
                const couleurs = {
                    food_bank: "#2563eb",
                    food_sharing: "#16a34a",
                    soup_kitchen: "#ea580c",
                    anti_gaspi: "#9333ea"
                };

                // Créer un marqueur coloré
                const icone = L.divIcon({
                    className: "",
                    html: `<div style="
                        background-color: ${couleurs[lieu.category] || "#2563eb"};
                        width: 18px;
                        height: 18px;
                        border: 3px solid white;
                        border-radius: 50%;
                        box-shadow: 0 0 5px #555;
                    "></div>`,
                    iconSize: [24, 24],
                    iconAnchor: [12, 12]
                });

                // Créer le marqueur avec sa popup
                const marqueur = L.marker([lieu.latitude, lieu.longitude], {
                    icon: icone
                })
                    .addTo(markers)
                    .bindPopup(popup);

                // Garder le marqueur et sa catégorie
                tousLesMarqueurs.push({
                    marqueur: marqueur,
                    categorie: lieu.category,
                    nom: lieu.name || "",
                    ville: lieu.city || "",
                    codePostal: String(lieu.postal_code || "")
                });
            });

            // Catégorie sélectionnée
            let categorieActive = "all";

            // Filtrer les marqueurs
            function filtrer(categorie = categorieActive) {
                categorieActive = categorie;
                markers.clearLayers();
                // Retirer la sélection des boutons
                document.querySelectorAll(".map-filters button").forEach(bouton => {
                    bouton.classList.remove("active");
                });

                // Sélectionner le bouton actif
                const boutons = {
                    all: "filter-all",
                    food_bank: "filter-food-bank",
                    food_sharing: "filter-food-sharing",
                    soup_kitchen: "filter-soup-kitchen",
                    anti_gaspi: "filter-anti-gaspi"
                };

                document.getElementById(boutons[categorie]).classList.add("active");

                // Texte recherché
                const recherche = document.getElementById("search-location").value.toLowerCase().trim();

                tousLesMarqueurs.forEach(lieu => {
                    const bonneCategorie = categorie === "all" || lieu.categorie === categorie;

                    const correspondRecherche =
                        lieu.nom.toLowerCase().includes(recherche) ||
                        lieu.ville.toLowerCase().includes(recherche) ||
                        lieu.codePostal.toLowerCase().includes(recherche);

                    if (bonneCategorie && correspondRecherche) {
                        lieu.marqueur.addTo(markers);
                    }
                });
}

                // Clic sur les boutons
                document.getElementById("filter-all").addEventListener("click", () => filtrer("all"));
                document.getElementById("filter-food-bank").addEventListener("click", () => filtrer("food_bank"));
                document.getElementById("filter-food-sharing").addEventListener("click", () => filtrer("food_sharing"));
                document.getElementById("filter-soup-kitchen").addEventListener("click", () => filtrer("soup_kitchen"));
                document.getElementById("filter-anti-gaspi").addEventListener("click", () => filtrer("anti_gaspi"));

                // Rechercher pendant la saisie
                document.getElementById("search-location").addEventListener("input", () => filtrer());
    })

    .catch(error => {
        // Afficher les erreurs
        console.error("Erreur de chargement :", error);
    });
