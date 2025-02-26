extends Control

func _ready() -> void:
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scale()


func init(texture :Texture) -> void:
	#var texture = load(path)
	%Sprite.texture = texture
	scale()


func scale(scale: float = 1) -> void:
	var sprite_width :int = %Sprite.texture.get_width()
	var sprite_height :int = %Sprite.texture.get_height()
	var scale_x = Singleton.TARGET * scale / sprite_width
	var scale_y = Singleton.TARGET * scale / sprite_height
	var scale_factor = min(scale_x, scale_y)
	%Sprite.scale = Vector2(scale_factor, scale_factor)


func shake(scale: float = 1, rotate: float = Singleton.MAX_ROTATION) -> void:
	%Sprite.position = Vector2(
			randf_range(scale * -Singleton.POS_VAR , scale * Singleton.POS_VAR  ),
			randf_range(scale * -Singleton.POS_VAR  , scale * Singleton.POS_VAR  ))
	%Sprite.rotation = randf_range(-rotate, rotate)
	%Sprite.flip_h = randi_range(0, 1)
