extends Node
signal ready_to_start(count)
var max_players = 2
var peer = ENetMultiplayerPeer.new()

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer)

func host(n: int) -> void:
	max_players = n
	peer.create_server(7777, n - 1)
	multiplayer.multiplayer_peer = peer

func join(ip: String) -> void:
	peer.create_client(ip, 7777)
	multiplayer.multiplayer_peer = peer

func close() -> void:
	multiplayer.multiplayer_peer = null
	peer = ENetMultiplayerPeer.new()

func _on_peer(_id: int) -> void:
	if multiplayer.is_server() and multiplayer.get_peers().size() + 1 >= max_players:
		start.rpc(max_players)

@rpc("authority", "call_local", "reliable")
func start(n: int) -> void:
	ready_to_start.emit(n)

func my_ip() -> String:
	for a in IP.get_local_addresses():
		if a.begins_with("192.168.") or a.begins_with("10."):
			return a
	return "?"
