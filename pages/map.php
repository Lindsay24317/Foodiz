<h1 class="map-title">Find Food Near You</h1>

<div class="map-search">
    <input type="search" id="search-location" placeholder="Search by city, postal code or place...">
</div>

<div class="map-filters">
    <button id="filter-all">All (0)</button>
    <button id="filter-food-bank">Food Banks (0)</button>
    <button id="filter-food-sharing">Community Fridges (0)</button>
    <button id="filter-soup-kitchen">Community Kitchens (0)</button>
    <button id="filter-anti-gaspi">Food Waste Deals (0)</button>
</div>
<!--emplacement de la carte -->

<div id="map"></div>


<!-- chargement de leaflet et map.js-->

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="js/map.js"></script>