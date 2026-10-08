extends Control
var players := 2
var score := []
var btns := []
var over := false

func _ready() -> void:
	var v := VBoxContainer.new()
	v.set_anchors_preset(PRESET_FULL_RECT)
	add_child(v)
	var cols := [Color.TOMATO, Color.DODGER_BLUE, Color.LIME_GREEN, Color.GOLD]
	for i in players:
		score.append(0)
		var b := Button.new()
		b.size_flags_vertical = Control.SIZE_EXPAND_FILL
		b.text = "0"
		b.modulate = cols[i]
		b.add_theme_font_size_override("font_size", 90)
		b.pressed.connect(tap.bind(i))
		v.add_child(b)
		btns.append(b)
	Games.back(self)

func tap(i: int) -> void:
	if over:
		return
	score[i] += 1
	btns[i].text = str(score[i])
	Sound.tone(400 + score[i] * 15, 0.05)
	if score[i] >= 20:
		over = true
		btns[i].text = "🏆 فاز اللاعب %d" % (i + 1)
		Sound.win()
