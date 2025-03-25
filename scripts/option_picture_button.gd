extends Button

func init(texture: Texture2D, text: String, checked: bool) -> void:
	%Sprite2D.texture = texture
	%ButtonText.text = text
	%CheckBox.button_pressed = checked


func _on_toggled(toggled_on: bool) -> void:
	%CheckBox.button_pressed = toggled_on
