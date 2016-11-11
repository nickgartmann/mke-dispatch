import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

function mapSocket() {

  // Initialize the map
  

  var map = window.map;
  window.featuresSource = new ol.source.Vector();

  fetch("/api/calls" + window.location.search).then(function(response) {
  response.json().then(function(calls) {

    var features = [];

    calls.forEach(function(call) {
      features.push(featureFromPoint(call.latitude, call.longitude, call))
    });

    window.featuresSource.addFeatures(features)

    var clusters = new ol.source.Cluster({
      distance: parseInt(30, 10),
      source: featuresSource
    })

    var layer = new ol.layer.Vector({
      source: clusters,
      style: function(feature) {
        var size = feature.get('features').length
        return new ol.style.Style({
          image: new ol.style.Circle({
            radius: 8 + (size * 0.10),
            stroke: new ol.style.Stroke({
              color: "#333"
            }),
            fill: new ol.style.Fill({
              color: "#0071bc"
            })
          }),
          text: new ol.style.Text({
            text: size.toString(),
            font: "8px Source Sans Pro",
            fill: new ol.style.Fill({
              color: "#fff"
            }),
            stroke: new ol.style.Stroke({
            })
          })
        })
      }
    })

  window.map = new ol.Map({
    target: 'map',
    layers: [
      new ol.layer.Tile({
        source: new ol.source.OSM()
      }),
      layer
    ],
    view: new ol.View({
      center: ol.proj.fromLonLat([-88.306474, 43.038902]),
      zoom: 10
    })
  });

  var popup = null;
  window.map.addEventListener("click", function(e) {
    if(popup) {
      window.map.removeOverlay(popup)
      popup = null;
      return;
    }
    window.map.forEachFeatureAtPixel(window.map.getEventPixel(e.originalEvent), function(feature, layer) {
      if(feature.get('features').length == 1) {

        var meta = feature.get('features')[0].get("meta");
        console.log(meta);

        if(popup == null) {

          popup = new ol.Overlay({
            position: ol.proj.transform([meta.longitude, meta.latitude], 'EPSG:4326', 'EPSG:3857'),
            element: generatePopup(meta) 
          });

          window.map.addOverlay(popup);
        }
      }
    })
  })

  })
});

  socket.connect()

  // Now that you are connected, you can join channels with a topic:
  let channel = socket.channel("calls:all", {})
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

  channel.on("new", resp => {
    var call = resp;
    featuresSource.addFeature(featureFromPoint(resp.latitude, resp.longitude))
  })

}

function featureFromPoint(latitude, longitude, meta) {
  var feature = new ol.Feature(new ol.geom.Point(ol.proj.transform([longitude, latitude], 'EPSG:4326', 'EPSG:3857')))
  feature.set('meta', meta)
  return feature;
}

function generatePopup(call) {
  return $(`
    <div class="popup"">
      <table>
        <tr>
          <td>Type</td>
          <td>${call.nature}</td>
        </tr>
        <tr>
          <td>Status</td>
          <td>${call.status}</td>
        </tr>
        <tr>
          <td>Location</td>
          <td>${call.location}</td>
        </tr>
        <tr>
          <td>Time</td>
          <td>${call.time}</td>
        </tr>
      </table>
    </div>
  `)[0];
}

export default mapSocket
