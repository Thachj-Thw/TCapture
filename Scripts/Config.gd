extends Node
class_name ConfigManager


const CONFIG_PATH = "user://settings.ini"
var config: ConfigFile = ConfigFile.new()
var setting: Setting


func _init(setting_node: Setting) -> void:
	setting = setting_node
	if !FileAccess.file_exists(CONFIG_PATH):
		config.set_value("Display", "hwnd_mode", 0)
		config.set_value("Display", "hwnd_value", "")
		config.set_value("Display", "fullscreen", true)
		config.set_value("Display", "stretch_mode", 0)
		config.set_value("Display", "fps", 45)
		config.set_value("Display", "flip_h", false)
		config.set_value("Display", "flip_v", false)
		config.set_value("Crop", "x", 0)
		config.set_value("Crop", "y", 0)
		config.set_value("Crop", "width", 0)
		config.set_value("Crop", "height", 0)
		config.set_value("Scale", "x", 1.0)
		config.set_value("Scale", "y", 1.0)
		
		config.save(CONFIG_PATH)
	else:
		config.load(CONFIG_PATH)


func load_config() -> void:
	setting.hwnd_mode = config.get_value("Display", "hwnd_mode", 0)
	setting.hwnd_value = config.get_value("Display", "hwnd_value", "")
	setting.fullscreen = config.get_value("Display", "fullscreen", true)
	setting.stretch_mode = config.get_value("Display", "stretch_mode", 0)
	setting.fps = config.get_value("Display", "fps", 45)
	setting.flip_h = config.get_value("Display", "flip_h", false)
	setting.flip_v = config.get_value("Display", "flip_v", false)
	setting.crop.position.x = config.get_value("Crop", "x", 0)
	setting.crop.position.y = config.get_value("Crop", "y", 0)
	setting.crop.size.x = config.get_value("Crop", "width", 0)
	setting.crop.size.y = config.get_value("Crop", "height", 0)
	setting.scale_x = config.get_value("Scale", "x", 1.0)
	setting.scale_y = config.get_value("Scale", "y", 1.0)


func save_config() -> void:
	config.set_value("Display", "hwnd_mode", setting.hwnd_mode)
	config.set_value("Display", "hwnd_value", setting.hwnd_value)
	config.set_value("Display", "fullscreen", setting.fullscreen)
	config.set_value("Display", "stretch_mode", setting.stretch_mode)
	config.set_value("Display", "fps", setting.fps)
	config.set_value("Display", "flip_h", setting.flip_h)
	config.set_value("Display", "flip_v", setting.flip_v)
	config.set_value("Crop", "x", setting.crop.position.x)
	config.set_value("Crop", "y", setting.crop.position.y)
	config.set_value("Crop", "width", setting.crop.size.x)
	config.set_value("Crop", "height", setting.crop.size.y)
	config.set_value("Scale", "x", setting.scale_x)
	config.set_value("Scale", "y", setting.scale_y)
	
	config.save(CONFIG_PATH)
