extends RichTextLabel

var original_text :String
var translation :String

func _ready():
	original_text = self.text
	translate()

func translate():
	var translation = original_text
	var i := 0
	while true:
		i = translation.find("tr_", i)
		if i == -1:
			break
		var end := translation.find("_", i + 3)
		var to_translate :String = translation.substr(i, end - i)
		translation = translation.replace(to_translate + "_" , tr(to_translate))
		i += 1
	self.text = translation
