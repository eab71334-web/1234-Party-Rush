extends Control
var players := 2
var cells := []
var bs := []
var turn := 0
var over := false
const L := [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]

func _ready() -> void:
	var g := GridContainer.new()
	g.columns = 3
	g.set_anchors_preset(PRESET_CENTER)
	g.grow_horizontal = GROW_DIRECTION_BOTH
	g.grow_vertical = GROW_DIRECTION_BOTH
	add_child(g)
	for i in 9:
		cells.append("")
		var b := Button.new()
		b.custom_minimum_size = Vector2(200, 200)
		b.add_theme_font_size_override("font_size", 110)
		b.pressed.connect(play.bind(i))
		g.add_child(b)
		bs.append(b)
	Games.back(self)

func play(i: int) -> void:
	if over or cells[i] != "":
		return
	cells[i] = "X" if turn == 0 else "O"
	bs[i].text = cells[i]
	Sound.tone(500 + turn * 150, 0.1)
	turn = 1 - turn
	for l in L:
		if cells[l[0]] != "" and cells[l[0]] == cells[l[1]] and cells[l[1]] == cells[l[2]]:
			over = true
			for k in l:
				bs[k].modulate = Color.GOLD
			Sound.win()
			return
