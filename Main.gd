extends Node2D

var fname: String = 'user://image.png'

func _ready():
	#$OpenAI.list_models()
	#$OpenAI.retrieve_model('davinci-instruct-beta:2.0.0')
	$OpenAI.create_completion("write gdscript code to print hello from openai")
	$OpenAI.create_image("cat")

func _on_open_ai_response(type, payload):
	if type == 2:
		var expression = Expression.new()
		var error = expression.parse(payload.choices[0].text)
		if error != OK:
			print(expression.get_error_text())
			return
		var result = expression.execute()
		if not expression.has_execute_failed():
			print(str(result))
	
	if type == 3:
		var im_dl = HTTPRequest.new()
		add_child(im_dl)
		im_dl.connect("request_completed", self._im_dl_completed)
		im_dl.request(payload.data[0].url)

func _im_dl_completed(result, response_code, headers, body):
	var image = Image.new()
	var image_error = image.load_png_from_buffer(body)
	if image_error != OK:
		print("An error occurred while trying to display the image.")
	else:
		print("image loaded")
	image.save_png(fname)

	var texture = ImageTexture.create_from_image(image)
	$TextureRect.texture = texture
