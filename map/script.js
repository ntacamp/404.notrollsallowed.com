const MAP_CONFIG = {
  center: [54.661103, 24.986192],
  zoom: 18,
  maxZoom: 18,
  minZoom: 16,
};

const ICON_CONFIG = {
  iconOnly: {
    size: [25, 25],
    anchor: [12, 12],
    fontSize: 16,
  },
};

const map = L.map("map", MAP_CONFIG);

const createIcon = (properties) => {
  const { name, icons } = properties;

  // For trashbins, display icon only
  if ((name && name.toLowerCase().includes("trash")) || name.toLowerCase().includes("restroom")) {
    const iconString = icons && icons.length > 0 ? icons[0] : "🗑️";
    return L.divIcon({
      html: `<div style="font-size: ${ICON_CONFIG.iconOnly.fontSize}px; text-align: center;">${iconString}</div>`,
      iconSize: ICON_CONFIG.iconOnly.size,
      iconAnchor: ICON_CONFIG.iconOnly.anchor,
      className: "icon-only-marker",
    });
  }

  // Shorten long names (Base Camp fits, but longer names get truncated)
  const iconString = icons && icons.length > 0 ? icons.join("") : "";
  const displayText = iconString ? `${name}\n${iconString}` : name;

  return L.divIcon({
    className: "custom-div-icon",
    html: `<div class="custom-marker">${displayText}</div>`,
    iconSize: [null, null],
    iconAnchor: [0, 0],
  });
};

const createPopupContent = (properties) => {
  if (!properties?.name) {
    return null;
  }

  const { name, icons, activities } = properties;
  let content = `<h3>${name}</h3>`;

  // Add icons section if available
  if (icons && icons.length > 0) {
    const iconsHtml = icons.map((icon) => `<span class="popup-icon">${icon}</span>`).join("");
    content += `<div class="popup-icons">${iconsHtml}</div>`;
  }

  // Add activities if available
  if (activities && activities.length > 0) {
    const activitiesHtml = activities.map((activity) => `${activity}<br>`).join("");
    content += `<div class="popup-activities">${activitiesHtml}</div>`;
  }

  return content;
};

const onEachFeature = (feature, layer) => {
  const popupContent = createPopupContent(feature.properties);
  if (popupContent) {
    layer.bindPopup(popupContent);
  }
};

const pointToLayer = (feature, latlng) => {
  const icon = createIcon(feature.properties);
  return L.marker(latlng, { icon });
};

document.addEventListener("DOMContentLoaded", () => {
  L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
    attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
  }).addTo(map);

  const markers = L.markerClusterGroup({
    maxClusterRadius: 50,
    disableClusteringAtZoom: 18,
  });

  fetch("locations.geojson")
    .then((response) => response.json())
    .then((data) => {
      const geoJsonLayer = L.geoJSON(data, {
        onEachFeature: onEachFeature,
        pointToLayer: pointToLayer,
      });

      markers.addLayer(geoJsonLayer);
      map.addLayer(markers);
    })
    .catch((error) => {
      console.error("Error loading location data:", error);
      alert(
        "Could not load location data. Please serve this page from a web server (e.g., python3 -m http.server 8000)"
      );
    });

  L.control.scale().addTo(map);
});
