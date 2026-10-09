extends Node
signal restart_req
var last = []
var lang = "ar"
var sfx_on = true
var music_on = true
var show_fps = false
var max_fps = 60
var fps_label: Label
var rx = RegEx.new()
var rx_win = RegEx.new()
var rx_turn = RegEx.new()
var PC = [Color("ff5d73"), Color("4da3ff"), Color("3ddc97"), Color("ffc93c")]
const PN_AR = ["الأحمر", "الأزرق", "الأخضر", "الأصفر"]
const PN_EN = ["Red", "Blue", "Green", "Yellow"]
var PN = ["الأحمر", "الأزرق", "الأخضر", "الأصفر"]
var PIECES = {}

# [id, اسم, مسار, أقل, أكثر, لون1, لون2, name]
const ALL = [
	["chess", "شطرنج", "res://g_chess.gd", 2, 4, "c9822b", "6b3d12", "Chess"],
	["xo", "إكس أو", "res://g_xo.gd", 1, 2, "ff5d73", "a82a45", "Tic Tac Toe"],
	["c4", "أربعة في صف", "res://g_c4.gd", 2, 2, "4da3ff", "1f4fb3", "Connect 4"],
	["tap", "سباق النقر", "res://g_taprace.gd", 1, 4, "ffb03b", "c26a00", "Tap Race"],
	["memory", "الذاكرة", "res://g_memory.gd", 1, 4, "a55eea", "5b2a9c", "Memory"],
	["snake", "الثعبان", "res://g_snake.gd", 1, 1, "26de81", "0b8a4d", "Snake"],
	["2048", "2048", "res://g_2048.gd", 1, 1, "fd9644", "c0561a", "2048"],
	["react", "سرعة البديهة", "res://g_reaction.gd", 1, 4, "eb3b5a", "8c1230", "Reflex"],
	["tug", "شد الحبل", "res://g_tug.gd", 2, 2, "2bcbba", "11766b", "Tug of War"],
	["rps", "حجر ورقة مقص", "res://g_rps.gd", 2, 2, "fa8231", "b34d0a", "Rock Paper Scissors"],
	["guess", "خمّن الرقم", "res://g_guess.gd", 1, 4, "45aaf2", "1b5f99", "Guess the Number"],
	["pong", "بينغ بونغ", "res://g_pong.gd", 1, 2, "4b7bec", "1f3fa8", "Pong"],
	["whack", "اضرب الخلد", "res://g_whack.gd", 1, 1, "a5774a", "5c3a1c", "Whack-a-Mole"],
	["gomoku", "خمسة في صف", "res://g_gomoku.gd", 2, 4, "778ca3", "3d4b5e", "Gomoku"],
	["reversi", "ريفيرسي", "res://g_reversi.gd", 2, 2, "20bf6b", "0b6b36", "Reversi"],
	["dice", "سباق النرد", "res://g_dice.gd", 2, 4, "f7b731", "b07a00", "Dice Race"],
	["math", "تحدي الحساب", "res://g_math.gd", 1, 4, "0fb9b1", "066b66", "Math Duel"],
	["simon", "سايمون", "res://g_simon.gd", 1, 1, "8854d0", "461f85", "Simon"],
	["slide", "بازل الأرقام", "res://g_slide.gd", 1, 1, "fc5c65", "9a1f2a", "Sliding Puzzle"],
	["lights", "أطفئ الأضواء", "res://g_lights.gd", 1, 1, "e1b12c", "8a6a00", "Lights Out"],
]

const EXACT = {"تم": "OK", "حذف": "Del", "؟": "?"}
const DICT = [
	["الخصم ما عنده حركة — دورك مرة ثانية", "Opponent can't move - your turn again"],
	["خمّن رقم من 1 إلى 100", "Guess a number from 1 to 100"],
	["انتظر اللون الأخضر...", "Wait for green..."],
	["اضغط بسرعة! الهدف", "Tap fast! Goal"],
	["اسحب لتغيير الاتجاه", "Swipe to steer"],
	["اسحب لدمج الأرقام", "Swipe to merge"],
	["أطفئ كل الأضواء", "Turn off all lights"],
	["شاهد... المستوى", "Watch... Level"],
	["وصلت للمستوى", "You reached level"],
	["أطفأتها في", "Solved in"],
	["حليتها في", "Solved in"],
	["حرّك بإصبعك", "Drag your finger"],
	["استعجل! -1", "too early! -1"],
	["اضغط الآن!!", "TAP NOW!!"],
	["اضغط بسرعة!", "Tap fast!"],
	["خمّن الرقم", "guessed the number"],
	["مرة ثانية", "Play again"],
	["شد الحبل!", "Tug of war!"],
	["خلصت في", "Finished in"],
	["نتيجتك", "Your score"],
	["نقاطك", "Your points"],
	["النتيجة", "Score"],
	["السؤال", "Question"],
	["الحركات", "Moves"],
	["انتهت", "Game over"],
	["تعادل", "Draw"],
	["دورك", "Your turn"],
	["ثانية", "sec"],
	["حركة", "moves"],
	["الرقم", "Number"],
	["أكبر", "higher"],
	["أصغر", "lower"],
	[" من ", " of "],
]

func _ready() -> void:
	rx_win.compile("فاز (\\S+)")
	rx_turn.compile("دور (\\S+)")
	load_cfg()
	var cl = CanvasLayer.new()
	cl.layer = 100
	add_child(cl)
	fps_label = Label.new()
	fps_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	fps_label.offset_left = 16
	fps_label.offset_top = -60
	fps_label.offset_right = 300
	fps_label.offset_bottom = -16
	fps_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fps_label.add_theme_font_size_override("font_size", 26)
	fps_label.add_theme_color_override("font_color", Color.LIME)
	fps_label.add_theme_color_override("font_outline_color", Color.BLACK)
	fps_label.add_theme_constant_override("outline_size", 6)
	cl.add_child(fps_label)
	apply()

func _process(_d: float) -> void:
	if show_fps:
		fps_label.text = "FPS %d" % Engine.get_frames_per_second()

func load_cfg() -> void:
	var c = ConfigFile.new()
	if c.load("user://settings.cfg") == OK:
		lang = c.get_value("s", "lang", "ar")
		sfx_on = c.get_value("s", "sfx", true)
		music_on = c.get_value("s", "music", true)
		show_fps = c.get_value("s", "showfps", false)
		max_fps = c.get_value("s", "maxfps", 60)

func save_cfg() -> void:
	var c = ConfigFile.new()
	c.set_value("s", "lang", lang)
	c.set_value("s", "sfx", sfx_on)
	c.set_value("s", "music", music_on)
	c.set_value("s", "showfps", show_fps)
	c.set_value("s", "maxfps", max_fps)
	c.save("user://settings.cfg")

func apply() -> void:
	Engine.max_fps = max_fps
	Sound.sfx_on = sfx_on
	Sound.music_on = music_on
	PN = PN_EN.duplicate() if lang == "en" else PN_AR.duplicate()
	if fps_label:
		fps_label.visible = show_fps

func L(ar: String, en: String) -> String:
	return en if lang == "en" else ar

func strip(s: String) -> String:
	var out = ""
	for i in s.length():
		var c = s.unicode_at(i)
		if c >= 0x1F000 or (c >= 0x2190 and c <= 0x21FF) or (c >= 0x2300 and c <= 0x2BFF) or c == 0xFE0F or c == 0x200D:
			continue
		out += s.substr(i, 1)
	return out.strip_edges()

func tx(s: String) -> String:
	s = strip(s)
	if lang != "en":
		return s
	if EXACT.has(s):
		return EXACT[s]
	s = rx_win.sub(s, "$1 wins", true)
	s = rx_turn.sub(s, "$1's turn", true)
	for p in DICT:
		s = s.replace(p[0], p[1])
	return s

func games_for(n: int) -> Array:
	return ALL.filter(func(g): return n >= g[3] and n <= g[4])

func safe_top() -> int:
	var ws = DisplayServer.window_get_size()
	var sa = DisplayServer.get_display_safe_area()
	if ws.x <= 0:
		return 40
	var k = 720.0 / float(ws.x)
	return int(maxf(sa.position.y * k, 40.0))

func flat(c: Color, r: int = 12) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = c
	s.set_corner_radius_all(r)
	return s

func style(c: Color, r: int = 28, depth: int = 10) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = c
	s.set_corner_radius_all(r)
	s.border_width_bottom = depth
	s.border_color = c.darkened(0.38)
	s.shadow_color = Color(0, 0, 0, 0.3)
	s.shadow_size = 10
	s.shadow_offset = Vector2(0, 8)
	s.content_margin_left = 16
	s.content_margin_right = 16
	return s

func tint(b: Button, c: Color) -> void:
	b.add_theme_stylebox_override("normal", style(c))
	b.add_theme_stylebox_override("hover", style(c.lightened(0.1)))
	b.add_theme_stylebox_override("pressed", style(c.darkened(0.12), 28, 3))

func btn(text: String, color: Color = Color("6c5ce7"), h: int = 110, fs: int = 40) -> Button:
	var b = Button.new()
	b.text = tx(text)
	b.custom_minimum_size = Vector2(0, h)
	b.add_theme_font_size_override("font_size", fs)
	tint(b, color)
	b.add_theme_stylebox_override("disabled", style(color.darkened(0.45)))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(k, Color.WHITE)
	b.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.35))
	b.add_theme_constant_override("outline_size", 6)
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.6))
	b.button_down.connect(func():
		b.pivot_offset = b.size / 2
		get_tree().create_tween().tween_property(b, "scale", Vector2(0.94, 0.94), 0.06))
	b.button_up.connect(func():
		b.pivot_offset = b.size / 2
		get_tree().create_tween().tween_property(b, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))
	b.pressed.connect(Sound.click)
	return b

func icon_btn(kind: String, color: Color, sz: int = 100) -> Button:
	var b = btn("", color, sz, 20)
	b.custom_minimum_size = Vector2(sz, sz)
	var a = Control.new()
	a.set_script(load("res://art.gd"))
	a.set("kind", kind)
	a.set_anchors_preset(Control.PRESET_FULL_RECT)
	b.add_child(a)
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
	var b = icon_btn("close", Color("e17055"), 90)
	b.position = Vector2(20, safe_top())
	b.size = Vector2(90, 90)
	b.pressed.connect(func():
		Net.close()
		get_tree().reload_current_scene())
	node.add_child(b)

func ell(cx: float, cy: float, rx2: float, ry2: float, n: int = 18) -> PackedVector2Array:
	var a = PackedVector2Array()
	for i in n:
		var ang = TAU * i / n
		a.append(Vector2(cx + cos(ang) * rx2, cy + sin(ang) * ry2))
	return a

func pv(arr: Array) -> PackedVector2Array:
	var a = PackedVector2Array()
	for i in range(0, arr.size(), 2):
		a.append(Vector2(arr[i], arr[i + 1]))
	return a

func build_pieces() -> void:
	var plinth = pv([-0.30, 0.40, -0.30, 0.31, 0.30, 0.31, 0.30, 0.40])
	var qbody = pv([-0.20, 0.31, -0.11, -0.10, 0.11, -0.10, 0.20, 0.31])
	PIECES["P"] = [[pv([-0.09, -0.09, 0.09, -0.09, 0.17, 0.31, -0.17, 0.31]), 0], [ell(0, -0.2, 0.13, 0.13), 0], [plinth, 0]]
	PIECES["R"] = [[pv([-0.20, 0.31, -0.16, -0.15, 0.16, -0.15, 0.20, 0.31]), 0],
		[pv([-0.23, -0.15, -0.23, -0.38, -0.12, -0.38, -0.12, -0.30, -0.04, -0.30, -0.04, -0.38, 0.04, -0.38, 0.04, -0.30, 0.12, -0.30, 0.12, -0.38, 0.23, -0.38, 0.23, -0.15]), 0], [plinth, 0]]
	PIECES["B"] = [[pv([-0.16, 0.31, -0.08, 0.0, 0.08, 0.0, 0.16, 0.31]), 0], [ell(0, -0.17, 0.14, 0.21), 0], [ell(0, -0.42, 0.05, 0.05, 10), 0],
		[pv([-0.03, -0.25, 0.09, -0.34, 0.11, -0.31, -0.01, -0.22]), 1], [plinth, 0]]
	PIECES["N"] = [[pv([-0.22, 0.31, -0.20, 0.02, -0.31, 0.0, -0.35, -0.10, -0.15, -0.33, -0.11, -0.43, -0.03, -0.35, 0.10, -0.31, 0.24, -0.12, 0.24, 0.31]), 0],
		[ell(-0.08, -0.2, 0.03, 0.03, 8), 1], [plinth, 0]]
	PIECES["Q"] = [[qbody, 0],
		[pv([-0.21, -0.10, -0.25, -0.34, -0.12, -0.20, -0.06, -0.40, 0.0, -0.22, 0.06, -0.40, 0.12, -0.20, 0.25, -0.34, 0.21, -0.10]), 0],
		[ell(-0.25, -0.36, 0.04, 0.04, 8), 0], [ell(-0.06, -0.43, 0.04, 0.04, 8), 0], [ell(0.06, -0.43, 0.04, 0.04, 8), 0], [ell(0.25, -0.36, 0.04, 0.04, 8), 0], [plinth, 0]]
	PIECES["K"] = [[qbody, 0], [pv([-0.19, -0.10, -0.21, -0.27, 0.21, -0.27, 0.19, -0.10]), 0],
		[pv([-0.03, -0.49, 0.03, -0.49, 0.03, -0.43, 0.09, -0.43, 0.09, -0.37, 0.03, -0.37, 0.03, -0.27, -0.03, -0.27, -0.03, -0.37, -0.09, -0.37, -0.09, -0.43, -0.03, -0.43]), 0], [plinth, 0]]

func piece(ci: CanvasItem, t: String, ctr: Vector2, s: float, fill: Color) -> void:
	if PIECES.is_empty():
		build_pieces()
	ci.draw_set_transform(ctr + Vector2(0, s * 0.36), 0.0, Vector2(1.0, 0.35))
	ci.draw_circle(Vector2.ZERO, s * 0.3, Color(0, 0, 0, 0.28))
	ci.draw_set_transform(ctr, 0.0, Vector2(s, s))
	var ol = Color(0, 0, 0, 0.8)
	for part in PIECES[t]:
		var poly = part[0]
		if part[1] == 1:
			ci.draw_colored_polygon(poly, ol)
		else:
			ci.draw_colored_polygon(poly, fill)
			var pts = poly.duplicate()
			pts.append(poly[0])
			ci.draw_polyline(pts, ol, 0.035)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
