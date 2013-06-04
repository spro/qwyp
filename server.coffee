crypto = require 'crypto'
argv = require('optimist').argv._
es = require 'event-stream'
net = require 'net'

password = argv[0]
peer_listen_port = Number argv[1]
peer_send_port = Number argv[2]
client_port = Number argv[3]

encrypter = es.mapSync (plaintext) ->
    cipher = crypto.createCipher 'aes-256-cbc', password
    cipher.setAutoPadding(auto_padding=true)
    encrypted = cipher.update plaintext, "binary", "hex"
    encrypted += cipher.final "hex"
    encrypted

decrypter = es.mapSync (encrypted) ->
    decipher = crypto.createDecipher 'aes-256-cbc', password
    decipher.setAutoPadding(auto_padding=true)
    decrypted = decipher.update encrypted, "hex", "binary"
    decrypted += decipher.final "binary"
    decrypted

# Client connection (to browser)

shoe = require 'shoe'
http = require 'http'
ecstatic = require('ecstatic')(__dirname + '/static')
clientServer = http.createServer(ecstatic)
clientServer.listen client_port

clientSock = shoe (stream) ->
    console.log 'Connected to client.'
    stream.pipe(encrypter)
    decrypter.pipe(stream)
    stream.write JSON.stringify
        body: "Welcome."
        from: "server"
clientSock.install clientServer, '/sock'

# Peer connections - encrypt and decrypt over this channel

setupPeerOutgoing = =>
    peerOutgoing = net.connect peer_send_port, ->
        console.log 'Connected to peer.'
        encrypter.pipe peerOutgoing
    peerOutgoing.on 'error', ->
        console.log 'Connection error, retrying...'
        setTimeout(setupPeerOutgoing, 1000)
setTimeout(setupPeerOutgoing, 1000)

peerIncoming = net.createServer (stream) ->
    stream.pipe(decrypter)
peerIncoming.listen(peer_listen_port)

