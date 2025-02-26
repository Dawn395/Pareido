extends Control

# Called when the node enters the scene tree for the first time.
func init(mouse_pos :Vector2, text: String) -> void:
	var screensize_x = (DisplayServer.window_get_size().x)
	var screensize_y = (DisplayServer.window_get_size().y)
	var quadrant = Vector2(0, 0)
	
	if mouse_pos.x > screensize_x / 2:
		quadrant.x = 1  # Right half
	if mouse_pos.y > screensize_y / 2:
		quadrant.y = 1  # Bottom half
	
	%Label.text = text
	
	#print(%PanelContainer.size[0]) #x
	#print(%PanelContainer.size[1]) #y
	match quadrant:
		Vector2(0, 0):  # Top-left
			$".".set_position(Vector2(
					mouse_pos.x, mouse_pos.y))
		Vector2(1, 0):  # Top-right
			$".".set_position(Vector2(
					mouse_pos.x - %PanelContainer.size[0], mouse_pos.y))
		Vector2(0, 1):  # Bottom-left
			$".".set_position(Vector2(
					mouse_pos.x , mouse_pos.y - %PanelContainer.size[1]))
		Vector2(1, 1):  # Bottom-right
			$".".set_position(Vector2(
					mouse_pos.x - %PanelContainer.size[0], mouse_pos.y - %PanelContainer.size[1]))
