extends Node
# [الاسم, المسار, أقل لاعبين, أكثر لاعبين]
const ALL := [
	["❌⭕ إكس أو", "res://xo.gd", 2, 2],
	["⚡ سباق النقر", "res://taprace.gd", 1, 4],
]

func games_for(n: int) -> Array:
	return ALL.filter(func(g): return n >= g[2] and n <= g[3])

func back(node: Control) -> void:
	var b := Button.new()
	b.text = "←"
	b.position = Vector2(10, 10)
	b.size = Vector2(90, 70)
	b.pressed.connect(func():
		Net.close()
		get_tree().reload_current_scene())
	node.add_child(b)
