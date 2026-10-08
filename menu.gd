extends Control
var box := VBoxContainer.new()

func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("1b1030")
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	box.set_anchors_preset(PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 24)
	add_child(box)
	Net.ready_to_start.connect(func(n): launch(Games.games_for(n)[0], n))
	home()

func clear() -> void:
	for c in box.get_children():
		c.queue_free()

func lbl(t: String) -> void:
	var l := Label.new()
	l.text = t
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 48)
	box.add_child(l)

func b(t: String, cb: Callable) -> void:
	var x := Button.new()
	x.text = t
	x.custom_minimum_size = Vector2(0, 120)
	x.add_theme_font_size_override("font_size", 44)
	x.pressed.connect(func():
		Sound.click()
		cb.call())
	box.add_child(x)

func home() -> void:
	clear()
	lbl("🎮 ألعاب مصغرة")
	b("نفس الشاشة", local)
	b("جماعي", online)

func local() -> void:
	clear()
	lbl("كم لاعب؟")
	for n in [1, 2, 3, 4]:
		b(str(n), pick.bind(n))
	b("رجوع", home)

func pick(n: int) -> void:
	clear()
	for g in Games.games_for(n):
		b(g[0], launch.bind(g, n))
	b("رجوع", local)

func online() -> void:
	clear()
	b("افتح غرفة", host_menu)
	b("انضم لغرفة", join_menu)
	b("رجوع", home)

func host_menu() -> void:
	clear()
	lbl("عدد اللاعبين")
	for n in [2, 3, 4]:
		b(str(n), do_host.bind(n))
	b("رجوع", online)

func do_host(n: int) -> void:
	Net.host(n)
	clear()
	lbl("الغرفة جاهزة\nIP: " + Net.my_ip() + "\nننتظر اللاعبين...")

func join_menu() -> void:
	clear()
	var e := LineEdit.new()
	e.placeholder_text = "IP"
	e.custom_minimum_size = Vector2(0, 100)
	box.add_child(e)
	b("دخول", func():
		Net.join(e.text)
		clear()
		lbl("جاري الاتصال..."))

func launch(g: Array, n: int) -> void:
	clear()
	var s := Control.new()
	s.set_script(load(g[1]))
	s.set("players", n)
	s.set_anchors_preset(PRESET_FULL_RECT)
	add_child(s)
