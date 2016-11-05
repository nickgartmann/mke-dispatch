import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

function mapSocket() {

socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("calls:all", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on("new", resp => {
  window.map.addOverlay(new ol.Overlay({
      position: ol.proj.transform(
                        [resp.longitude, resp.latitude],
                        'EPSG:4326',
                        'EPSG:3857'
                      ),
    element: $("<div style='height: 5px; width: 5px; background-color: blue'></div>")[0]
  }));
})
}

export default mapSocket
