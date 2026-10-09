extends Node
signal restart_req
var last = []
var PC = [Color("ff5d73"), Color("4da3ff"), Color("3ddc97"), Color("ffc93c")]
var PN = ["الأحمر", "الأزرق", "الأخضر", "الأصفر"]

# [إيموجي, اسم, مسار, أقل لاعبين, أكثر لاعبين, لون]
const ALL = [
	["♟️", "شطرنج", "res://g_chess.gd", 2, 4, "b57a4a"],
	["❌", "إكس أو", "res://g_xo.gd", 1, 2, "ff5d73"],
	["🔴", "أربعة في صف", "res://g_c4.gd", 2, 2, "4da3ff"],
	["⚡", "سباق النقر", "res://g_taprace.gd", 1, 4, "ffb03b"],
	["🧠", "الذاكرة", "res://g_memory.gd", 1, 4, "a55eea"],
	["🐍", "الثعبان", "res://g_snake.gd", 1, 1, "26de81"],
	["🔢", "2048", "res://g_2048.gd", 1, 1, "fd9644"],
	["🚦", "سرعة البديهة", "res://g_reaction.gd", 1, 4, "eb3b5a"],
	["🪢", "شد الحبل", "res://g_tug.gd", 2, 2, "2bcbba"],
	["✊", "حجر ورقة مقص", "res://g_rps.gd", 2, 2, "fa8231"],
	["🎯", "خمّن الرقم", "res://g_guess.gd", 1, 4, "45aaf2"],
	["🏓", "بينغ بونغ", "res://g_pong.gd", 1, 2, "4b7bec"],
	["🔨", "اضرب الخلد", "res://g_whack.gd", 1, 1, "a5774a"],
	["⚫", "خمسة في صف", "res://g_gomoku.gd", 2, 4, "778ca3"],
	["⚪", "ريفيرسي", "res://g_reversi.gd", 2, 2, "20bf6b"],
	["🎲", "سباق النرد", "res://g_dice.gd", 2, 4, "f7b731"],
	["➕", "تحدي الحساب", "res://g_math.gd", 1, 4, "0fb9b1"],
	["🎵", "سايمون", "res://g_simon.gd", 1, 1, "8854d0"],
	["🧩", "بازل الأرقام", "res://g_slide.gd", 1, 1, "fc5c65"],
	["💡", "أطفئ الأضواء", "res://g_lights.gd", 1, 1, "e1b12c"],
]

func games_for(n: int) -> Array:
	return ALL.filter(func(g): return n >= g[3] and n <= g[4])

func safe_top() -> int:
	var ws = DisplayServer.window_get_size()
	var sa = DisplayServer.get_display_safe_area()
	if ws.x <= 0:
		return 40
	var k = 720.0 / float(ws.x)
	return int(maxf(sa.position.y * k, 40.0))

func style(c: Color, r: int = 30) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = c
	s.set_corner_radius_all(r)
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 8
	s.shadow_offset = Vector2(0, 6)
	s.content_margin_left = 16
	s.content_margin_right = 16
	return s

func tint(b: Button, c: Color) -> void:
	for k in ["normal", "hover", "pressed"]:
		b.add_theme_stylebox_override(k, style(c))

func btn(text: String, color: Color = Color("6c5ce7"), h: int = 110, fs: int = 40) -> Button:
	var b = Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, h)
	b.add_theme_font_size_override("font_size", fs)
	b.add_theme_stylebox_override("normal", style(color))
	b.add_theme_stylebox_override("hover", style(color.lightened(0.12)))
	b.add_theme_stylebox_override("pressed", style(color.darkened(0.2)))
	b.add_theme_stylebox_override("disabled", style(color.darkened(0.45)))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(k, Color.WHITE)
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.6))
	b.button_down.connect(func():
		b.pivot_offset = b.size / 2
		get_tree().create_tween().tween_property(b, "scale", Vector2(0.94, 0.94), 0.06))
	b.button_up.connect(func():
		b.pivot_offset = b.size / 2
		get_tree().create_tween().tween_property(b, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))
	b.pressed.connect(Sound.click)
	return b

func pop(n: Control, d: float = 0.0) -> void:
	n.modulate.a = 0.0
	n.scale = Vector2(0.6, 0.6)
	n.pivot_offset = n.custom_minimum_size / 2
	n.resized.connect(func(): n.pivot_offset = n.size / 2)
	var t = get_tree().create_tween().set_parallel(true)
	t.tween_property(n, "modulate:a", 1.0, 0.3).set_delay(d)
	t.tween_property(n, "scale", Vector2.ONE, 0.5).set_delay(d).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func back(node: Control) -> void:
	var b = btn("✕", Color("e17055"), 80, 38)
	b.custom_minimum_size = Vector2(90, 80)
	b.position = Vector2(20, safe_top())
	b.size = Vector2(90, 80)
	b.pressed.connect(func():
		Net.close()
		get_tree().reload_current_scene())
	node.add_child(b)
