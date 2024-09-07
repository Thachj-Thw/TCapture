extends Window

var parent: Node
var window_title: String = ""
var crop: Rect2i = Rect2i(0, 0, 0, 0)
var fps: int = 45
var img: Image
var img_width: int = 0
var img_height: int = 0
var holding: bool = false
var scale_x: float = 0.0
var scale_y: float = 0.0
var display_rect: Rect2
var event_rect: Rect2
var fullscreen: bool = false
var alway_on_top: bool = false

@onready var display_setting: TextureRect = %DisplaySetting
@onready var line_edit_title: LineEdit = %LineEdit_title
@onready var display_crop: ReferenceRect = %DisplaySetting/Crop
@onready var button_capture: Button = %Button_capture
@onready var spin_box_fps: SpinBox = %SpinBox_fps
@onready var spin_box_x: SpinBox = %SpinBox_x
@onready var spin_box_y: SpinBox = %SpinBox_y
@onready var spin_box_w: SpinBox = %SpinBox_w
@onready var spin_box_h: SpinBox = %SpinBox_h
@onready var button_clear: Button = %Button_clear
@onready var button_save: Button = %Button_save
@onready var button_close: Button = %Button_close
@onready var button_quit: Button = %Button_quit
@onready var option_button: OptionButton = %OptionButton
@onready var check_box_fullscreen: CheckBox = %CheckBox_fullscreen
@onready var check_box_on_top: CheckBox = %CheckBox_on_top


func _ready() -> void:
	display_crop.size = Vector2.ZERO
	button_capture.pressed.connect(on_button_capture_clicked)
	button_clear.pressed.connect(on_button_clear_clicked)
	button_save.pressed.connect(on_button_save_clicked)
	button_close.pressed.connect(on_button_close_clicked)
	button_quit.pressed.connect(on_button_quit_clicked)
	option_button.item_selected.connect(on_option_button_item_slected)
	check_box_fullscreen.toggled.connect(func(is_on): fullscreen = is_on)
	check_box_on_top.toggled.connect(func(is_on): alway_on_top = is_on)
	# default value
	spin_box_fps.value = 45
	spin_box_x.value = 0
	spin_box_y.value = 0
	spin_box_w.value = 0
	spin_box_h.value = 0


func set_hwin_hwnd(text: String) -> void:
	if text:
		if option_button.selected == 0:
			parent.hwin.create_from_title(text)
			return
		if option_button.selected == 1 and text.is_valid_int():
			parent.hwin.create_from_pid(int(text))
			return
	parent.hwin.hwnd = 0


func on_button_capture_clicked() -> void:
	set_hwin_hwnd(line_edit_title.text)
	parent.hwin.crop.size = Vector2i(0, 0)
	img = parent.hwin.screenshot()
	img_width = img.get_width()
	img_height = img.get_height()
	spin_box_x.max_value = img_width - 1
	spin_box_y.max_value = img_height - 1
	spin_box_w.max_value = img_width - 1
	spin_box_h.max_value = img_height - 1
	display_setting.texture = ImageTexture.create_from_image(img)
	display_rect = display_setting.get_rect()
	display_rect.position = display_setting.global_position
	event_rect = display_setting.get_parent().get_rect()
	event_rect.position = display_setting.get_parent().global_position
	scale_x = img_width / display_rect.size.x
	scale_y = img_height / display_rect.size.y


func on_button_clear_clicked() -> void:
	display_crop.size = Vector2.ZERO
	spin_box_x.value = 0
	spin_box_y.value = 0
	spin_box_w.value = 0
	spin_box_h.value = 0


func on_button_save_clicked() -> void:
	window_title = line_edit_title.text
	crop.position.x = spin_box_x.value
	crop.position.y = spin_box_y.value
	crop.size.x = spin_box_w.value
	crop.size.y = spin_box_h.value
	fps = spin_box_fps.value
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	ProjectSettings.set_setting("display/window/size/always_on_top", alway_on_top)
	on_button_close_clicked()


func on_button_close_clicked() -> void:
	set_hwin_hwnd(window_title)
	parent.hwin.crop = crop
	self.hide()
	parent.set_process(true)


func on_button_quit_clicked() -> void:
	get_tree().quit()


func on_option_button_item_slected(index: int) -> void:
	if index == 0:
		line_edit_title.placeholder_text = "Application Title"
	else:
		line_edit_title.placeholder_text = "Application PID"


func open() -> void:
	line_edit_title.text = window_title
	spin_box_fps.value = fps
	spin_box_x.value = crop.position.x
	spin_box_y.value = crop.position.y
	spin_box_w.value = crop.size.x
	spin_box_w.value = crop.size.y
	if crop.size != Vector2i.ZERO:
		display_crop.position.x = crop.position.x / scale_x
		display_crop.position.y = crop.position.y / scale_y
		display_crop.size.x = crop.size.x / scale_x
		display_crop.size.y = crop.size.y / scale_y
		display_crop.show()
	else:
		display_crop.hide()
	check_box_fullscreen.button_pressed = fullscreen
	check_box_on_top.button_pressed = alway_on_top
	ProjectSettings.set_setting("display/window/size/always_on_top", false)
	self.show()
	parent.set_process(false)

func close() -> void:
	on_button_close_clicked()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.is_pressed():
			set_process(true)
			on_button_close_clicked()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and not holding:
			if event_rect.has_point(event.position):
				display_crop.show()
				display_crop.global_position.x = clamp(event.position.x, display_rect.position.x, display_rect.size.x)
				display_crop.global_position.y = clamp(event.position.y, display_rect.position.y, display_rect.size.y)
				display_crop.size = Vector2.ZERO
				spin_box_x.value = (event.position.x - display_rect.position.x) * scale_x
				spin_box_y.value = (event.position.y - display_rect.position.y) * scale_y
				spin_box_w.value = display_crop.size.x * scale_x
				spin_box_h.value = display_crop.size.y * scale_y
				holding = true
		else:
			holding = false
			if display_crop.size == Vector2.ZERO:
				display_crop.hide()
	elif event is InputEventMouseMotion and holding:
		display_crop.size.x = clamp(event.position.x - display_crop.global_position.x, 0, display_rect.size.x - display_crop.position.x - 1)
		display_crop.size.y = clamp(event.position.y - display_crop.global_position.y, 0, display_rect.size.y - display_crop.position.y - 1)
		spin_box_w.value = display_crop.size.x * scale_x
		spin_box_h.value = display_crop.size.y * scale_y
