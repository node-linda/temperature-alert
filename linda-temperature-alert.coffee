path = require 'path'

config = require path.resolve 'config'
console.log config

LindaClient = require('linda').Client
socket = require('socket.io-client').connect(config.url)
linda = new LindaClient().connect(socket)

spaces = config.spaces.map (name) ->
  linda.tuplespace name

alert_tempe = (ts) ->
  cid = ts.read {type: "sensor", name: "temperature"}, (err, tuple) ->
    return if err
    console.log "#{ts.name} - #{JSON.stringify tuple.data}"
    tempe = Math.floor tuple.data.value

    msg = "現在の気温、 #{tempe}度。"
    if tempe < 20 or 27 < tempe
      msg += "お体に触りますよ"
    ts.write {type: "say", value: msg}
    cid = null

    if cid
      setTimeout ->
        ts.cancel cid
      , 2000

linda.io.on 'connect', ->
  console.log "socket.io connect"

setInterval ->
  for ts in spaces
    alert_tempe ts
, 1000 * config.interval

for ts in spaces
  alert_tempe ts
