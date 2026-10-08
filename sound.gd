extends Node

func tone(f: float, d: float = 0.1) -> void:
	var rate := 22050
	var n := int(rate * d)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var env := 1.0 - float(i) / n
		var v := sin(TAU * f * i / rate) * env * 0.5
		data.encode_s16(i * 2, int(v * 32767))
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = rate
	s.data = data
	var p := AudioStreamPlayer.new()
	add_child(p)
	p.stream = s
	p.play()
	p.finished.connect(p.queue_free)

func click() -> void:
	tone(660, 0.06)

func win() -> void:
	for f in [523, 659, 784, 1047]:
		tone(f, 0.15)
		await get_tree().create_timer(0.13).timeout
