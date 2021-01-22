# Copyright © 2020 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

tool
extends VBoxContainer


signal show_log() # Call if autoopen is enabled.


const MESSAGE = preload("log_message.gd")


export(bool) var auto_open : bool = true # Used only in init.

export(String) var format_time : String = "{hour}:{minute}:{second}"
export(String) var format_text : String = "[{time}][{level}]{text}"

export(Dictionary) var colors : Dictionary = {
	Log.INFO: Color.white,
	Log.DEBUG: Color.gray,
	Log.WARNING: Color.darkorange,
	Log.ERROR: Color.red,
	Log.FATAL: Color.red,
}


var _log_output : RichTextLabel
var _open_check : CheckBox


func _init() -> void:
	_log_output = RichTextLabel.new()
	_log_output.size_flags_horizontal = SIZE_EXPAND_FILL
	_log_output.size_flags_vertical = SIZE_EXPAND_FILL
	_log_output.selection_enabled = true
	_log_output.scroll_following = true
	self.add_child(_log_output)
	
	var btn_box = HBoxContainer.new()
	self.add_child(btn_box)
	
	var btn_spacer = Control.new()
	btn_spacer.size_flags_horizontal = SIZE_EXPAND_FILL
	btn_box.add_child(btn_spacer)
	
	_open_check = CheckBox.new()
	_open_check.text = "Auto open"
	_open_check.pressed = auto_open
	btn_box.add_child(_open_check)
	
	var btn_clear = Button.new()
	btn_clear.text = "Clear"
	btn_clear.connect("pressed", _log_output, "clear")
	btn_box.add_child(btn_clear)
	
	return


func _ready() -> void:
	Log.connect("message", self, "print_message")
	return


func get_message_color(level: int) -> Color:
	if colors.has(level):
		return colors[level]
	
	return Color.white


func format(message: MESSAGE) -> String:
	var time = message.get_time()
	return format_text.format(
		{
			"time": format_time.format(
				{
					"hour":  "%02d" % time.hour,
					"minute":"%02d" % time.minute,
					"second":"%02d" % time.second,
				}
			),
			"level": Log.get_level_name(message.get_level()),
			"text": message.get_text(),
		}
	)


func print_message(message: MESSAGE) -> void:
	_log_output.newline()
	_log_output.push_color(get_message_color(message.get_level()))
	_log_output.add_text(format(message))
	
	if _open_check.pressed:
		emit_signal("show_log")
	
	return
