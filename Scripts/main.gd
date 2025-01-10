extends Control
class_name Main


var hwin: HandleWindow = HandleWindow.new()
var ctime: float = 0.0
var img: Image

@onready var display: TextureRect = %Display
@onready var label_notification: Label = %Label_notification
@onready var setting: Setting = %Window_Setting

func _ready():
	setting.display = self
	setting.hide()
	setting.set_hwin_hwnd(setting.hwnd_value)
	setting.update_display()
	hwin.crop = setting.crop

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.is_pressed():
		if not setting.visible:
			setting.open()
		else:
			setting.close()


func _process(delta: float) -> void:
	ctime += delta
	if ctime > 1.0 / setting.fps:
		ctime = 0
		if hwin.HWND_valid():
			label_notification.hide()
			img = hwin.screenshot()
			if img.is_empty():
				label_notification.text = "No signal"
				label_notification.show()
				display.texture = null;
			else:
				display.texture = ImageTexture.create_from_image(img)
		else:
			display.texture = null
			label_notification.text = "Window's application not exist"
			label_notification.show()
