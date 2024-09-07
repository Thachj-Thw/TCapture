extends Control


var hwin: HandleWindow = HandleWindow.new()
var ctime: float = 0.0
var img: Image

@onready var setting: Window = %Window_Setting
@onready var display: TextureRect = %Display


func _ready() -> void:
	setting.parent = self
	setting.hide()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.is_pressed():
		if not setting.visible:
			setting.open()
		else:
			setting.close()


func _process(delta: float) -> void:
	ctime += delta
	if ctime > 1 / setting.fps:
		ctime = 0
		img = hwin.screenshot()
		if img.is_empty():
			return
		display.texture = ImageTexture.create_from_image(img)
