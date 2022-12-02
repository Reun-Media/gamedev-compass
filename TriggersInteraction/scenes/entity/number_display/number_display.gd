extends Spatial

onready var text := $Label3D

var value := 0

func refresh_display():
	value = int(clamp(value, -99, 999))
	text.text = "N: " + "%03d" % value

func add():
	value += 1
	refresh_display()

func subtract():
	value -= 1
	refresh_display()
