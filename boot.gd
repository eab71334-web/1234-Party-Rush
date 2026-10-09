extends Control

const FILES = ["sound", "net", "games", "base", "bg", "menu", "g_chess", "g_xo", "g_c4", "g_taprace", "g_memory", "g_snake", "g_2048", "g_reaction", "g_tug", "g_rps", "g_guess", "g_pong", "g_whack", "g_gomoku", "g_reversi", "g_dice", "g_math", "g_simon", "g_slide", "g_lights"]

func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var bg = ColorRect.new()
	bg.color = Color("1b1030")
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	var txt = "فحص الملفات\n"
	var bad = 0
	for f in FILES:
		var s = load("res://%s.gd" % f)
		if s == null or not s.can_instantiate():
			txt += "❌ " + f + "\n"
			bad += 1
		else:
			txt += "✅ " + f + "\n"
	var l = Label.new()
	l.set_anchors_preset(PRESET_FULL_RECT)
	l.offset_top = 90
	l.offset_left = 30
	l.add_theme_font_size_override("font_size", 28)
	l.text = txt
	add_child(l)
	var b = Button.new()
	b.text = "تشغيل اللعبة (%d أخطاء)" % bad
	b.add_theme_font_size_override("font_size", 40)
	b.set_anchors_preset(PRESET_BOTTOM_WIDE)
	b.offset_top = -150
	b.offset_bottom = -40
	b.offset_left = 30
	b.offset_right = -30
	b.pressed.connect(start)
	add_child(b)

func start() -> void:
	var m = Control.new()
	m.set_script(load("res://menu.gd"))
	get_tree().root.add_child(m)
	queue_free()