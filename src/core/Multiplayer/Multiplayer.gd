extends Node

const SERVER_PORT = 12520

# TODO: peer should be a MultiplayerPeer to support steam
# multiplayer peer in the future
var peer: ENetMultiplayerPeer
var peer_name: String

const HOSTING_PLAYER_NAME = "Artnight"
const JOINING_PLAYER_NAME = "leszmak"

var players: Dictionary

func _print(a1, a2="", a3="") -> void:
	print("[" + peer_name + "]: ", a1, a2, a3)

func _ready() -> void:
	multiplayer.peer_connected.connect(
		func(id : int):
			_print("peer_connected, id: " + str(id))
	)
	multiplayer.peer_disconnected.connect(
		func(id : int):
			_print("peer_disconnected, id: ", id)
	)
	multiplayer.connected_to_server.connect(
		func():
			_print("connected_to_server")
	)
	multiplayer.connection_failed.connect(
		func():
			multiplayer.multiplayer_peer = null
			_print("connection_failed")
	)
	multiplayer.server_disconnected.connect(
		func():
			_print("server_disconnected")
	)

@rpc("call_local", "any_peer")
func player_joined(player_name: String):
	var id = multiplayer.get_remote_sender_id()
	# TODO: ensure player name is unique
	players[id] = player_name
	
	print("[" + peer_name + "] " + player_name + " has joined!")

func create_enet_host():
	peer = ENetMultiplayerPeer.new()
	peer.create_server(SERVER_PORT)
	peer_name = HOSTING_PLAYER_NAME
	players[1] = peer_name
	multiplayer.set_multiplayer_peer(peer)


func create_enet_client():
	peer = ENetMultiplayerPeer.new()
	peer.create_client("127.0.0.1", SERVER_PORT)
	peer_name = JOINING_PLAYER_NAME
	multiplayer.set_multiplayer_peer(peer)
	await multiplayer.connected_to_server
	player_joined.rpc(JOINING_PLAYER_NAME)
	players[multiplayer.get_unique_id()] = peer_name

@rpc("call_local")
func load_world():
	_print("Loading world")
	
	# TODO: fix this dirty hack
	var root = get_tree().root
	for child in root.get_children():
		if child.name == "SignalBus":
			continue
		if child.name == "Bits":
			continue
		if child.name == "Layer":
			continue
		if child.name == "Group":
			continue
		if child.name == "Multiplayer":
			continue
		child.queue_free()
	
	var world = load("res://src/core/demo/MultiplayerBasis.tscn").instantiate()
	root.add_child(world)

	#var pause_menu = get_tree().root.get_node("PauseMenu")
	#pause_menu.queue_free()
	
# TODO: ensure this makes sense to have an rpc to spawn players
@rpc("call_local")
func spawn_player(player_id: int, spawn_index: int):
	var world: Node3D = get_tree().root.get_node("MultiplayerBasis")
	var player_scene := load("res://src/Player/Player.tscn")
	var player: Player = player_scene.instantiate()
	
	## TODO: players need names
	#player.set_player_name(players[peer_id])
	world.add_child(player, true)
	
	# Set the player authorization for all peers
	player.set_authority.rpc(player_id)
	
	# Tell authorizer to move the player
	player.teleport.rpc_id(player_id, Vector3(spawn_index * 10, 0, 0))

func start_game():
	#Ensure that this is only running on the server; if it isn't, we need
	#to check our code.
	assert(multiplayer.is_server())
	
	#call load_world on all clients
	load_world.rpc()
	
	#Iterate over our connected peer ids
	var spawn_index = 0
	
	for peer_id in players:
		print("instantiating player with PEER ID: ", peer_id)
		spawn_player.rpc(peer_id, spawn_index)
		spawn_index += 1
