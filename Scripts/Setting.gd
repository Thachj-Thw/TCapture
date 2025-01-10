extends Window
class_name Setting


var display: Main
var hwnd_mode: int = 0
var hwnd_value: String = ""
var crop: Rect2i = Rect2i(0, 0, 0, 0)
var fps: int = 45
var img: Image
var img_width: int = 0
var img_height: int = 0
var holding: bool = false
var scale_x: float = 1.0
var scale_y: float = 1.0
var event_rect: Rect2
var fullscreen: bool = false
var stretch_mode: int = 0
var flip_h: bool = false
var flip_v: bool = false


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
@onready var label_notification: Label = %Label_notification
@onready var option_button_stretch_mode: OptionButton = %OptionButton_stretch_mode
@onready var check_box_flip_h: CheckBox = %CheckBox_flip_h
@onready var check_box_flip_v: CheckBox = %CheckBox_flip_v


var config_manager = ConfigManager.new(self)


func _ready() -> void:
	config_manager.load_config()
	print(scale_x)
	option_button.get_popup().set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
	option_button_stretch_mode.get_popup().set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
	button_capture.pressed.connect(on_button_capture_clicked)
	button_clear.pressed.connect(on_button_clear_clicked)
	button_save.pressed.connect(on_button_save_clicked)
	button_close.pressed.connect(on_button_close_clicked)
	button_quit.pressed.connect(on_button_quit_clicked)
	option_button.item_selected.connect(on_option_button_item_slected)
	check_box_fullscreen.toggled.connect(func(is_on: bool): fullscreen = is_on)
	spin_box_x.value_changed.connect(on_spin_box_x_value_changed)
	spin_box_y.value_changed.connect(on_spin_box_y_value_changed)
	spin_box_w.value_changed.connect(on_spin_box_w_value_changed)
	spin_box_h.value_changed.connect(on_spin_box_h_value_changed)
	line_edit_title.text_submitted.connect(func(_t: String): on_button_capture_clicked())
	option_button_stretch_mode.item_selected.connect(func(i: int): stretch_mode = i)
	check_box_flip_h.toggled.connect(func(is_on: bool): flip_h = is_on)
	check_box_flip_v.toggled.connect(func(is_on: bool): flip_v = is_on)


func set_hwin_hwnd(text: String) -> void:
	if text:
		if hwnd_mode == 0:
			display.hwin.create_from_title(text)
			return
		elif hwnd_mode == 1 and text.is_valid_int():
			display.hwin.create_from_pid(int(text))
			return
	display.hwin.hwnd = 0


func on_button_capture_clicked() -> void:
	set_hwin_hwnd(line_edit_title.text)
	if line_edit_title.text and display.hwin.hwnd == 0:
		label_notification.text = "Window not found"
		display_setting.texture = null
		img = Image.new()
		update_display_value()
		return
	display.hwin.crop.size = Vector2i(0, 0)
	img = display.hwin.screenshot()
	if img.is_empty():
		label_notification.text = "Image is empty"
		display_setting.texture = null
	else:
		display_setting.texture = ImageTexture.create_from_image(img)
		print("display size ",display_setting.size)
	update_display_value()


func update_display_value() -> void:
	spin_box_x.max_value = img_width
	spin_box_y.max_value = img_height
	spin_box_w.max_value = img_width
	spin_box_h.max_value = img_height
	event_rect = display_setting.get_parent().get_rect()
	event_rect.position = display_setting.get_parent().global_position


func on_button_clear_clicked() -> void:
	display_crop.size = Vector2.ZERO
	spin_box_x.value = 0
	spin_box_y.value = 0
	spin_box_w.value = 0
	spin_box_h.value = 0


func on_button_save_clicked() -> void:
	hwnd_mode = option_button.selected
	hwnd_value = line_edit_title.text
	crop = convert_rect(display_crop.get_rect(), img.get_size(), display_setting.size)
	fps = roundi(spin_box_fps.value)
	update_display()
	on_button_close_clicked()
	config_manager.save_config()

func update_display() -> void:
	match stretch_mode:
		0:
			display.display.stretch_mode = TextureRect.STRETCH_SCALE
		1:
			display.display.stretch_mode = TextureRect.STRETCH_TILE
		2:
			display.display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	display.display.flip_h = flip_h
	display.display.flip_v = flip_v
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func on_button_close_clicked() -> void:
	set_hwin_hwnd(hwnd_value)
	display.hwin.crop = crop
	self.hide()
	display.set_process(true)


func on_button_quit_clicked() -> void:
	get_tree().quit()


func on_option_button_item_slected(index: int) -> void:
	if index == 0:
		line_edit_title.placeholder_text = "Application Title"
	else:
		line_edit_title.placeholder_text = "Application PID"


func on_spin_box_x_value_changed(value: float) -> void:
	spin_box_w.max_value = img_width - value
	display_crop.position.x = value / scale_x

func on_spin_box_y_value_changed(value: float) -> void:
	spin_box_h.max_value = img_height - value
	display_crop.position.y = value / scale_y

func on_spin_box_w_value_changed(value: float) -> void:
	display_crop.size.x = roundi(value / scale_x)
	display_crop.visible = value + spin_box_h.value != 0

func on_spin_box_h_value_changed(value: float) -> void:
	display_crop.size.y = roundi(value / scale_y)
	display_crop.visible = value + spin_box_w.value != 0

func convert_rect(rect: Rect2, size1: Vector2, size2: Vector2) -> Rect2i:
	var c: Rect2i
	var scale_x: float = size1.x / size2.x
	var scale_y: float = size1.y / size2.y
	c.position.x = roundi(rect.position.x * scale_x)
	c.position.y = roundi(rect.position.y * scale_y)
	c.size.x = roundi(rect.size.x * scale_x)
	c.size.x = roundi(rect.size.x * scale_y)
	return c

func open() -> void:
	display.set_process(false)
	option_button.selected = hwnd_mode
	line_edit_title.text = hwnd_value
	on_button_capture_clicked()
	spin_box_fps.value = fps
	spin_box_x.value = crop.position.x
	spin_box_y.value = crop.position.y
	spin_box_w.value = crop.size.x
	spin_box_h.value = crop.size.y
	check_box_fullscreen.button_pressed = fullscreen
	line_edit_title.grab_focus()
	option_button_stretch_mode.select(stretch_mode)
	check_box_flip_h.button_pressed = flip_h
	check_box_flip_v.button_pressed = flip_v
	self.show()

func close() -> void:
	on_button_close_clicked()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.is_pressed():
			set_process(true)
			on_button_close_clicked()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and not holding:
			if event_rect.has_point(event.position):
				var crop_pos : Vector2i = event.position - display_setting.global_position
				spin_box_x.value = crop_pos.x * scale_x
				spin_box_y.value = crop_pos.y * scale_y
				spin_box_w.value = 0
				spin_box_h.value = 0
				holding = true
		else:
			holding = false
			if display_crop.size == Vector2.ZERO:
				display_crop.hide()
	elif event is InputEventMouseMotion and holding:
		var crop_size : Vector2i = event.position - display_crop.global_position
		spin_box_w.value = crop_size.x * scale_x
		spin_box_h.value = crop_size.y * scale_y
