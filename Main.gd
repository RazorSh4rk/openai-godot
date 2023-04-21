extends Node2D

var fname: String = 'user://image.png'
var fun: int = 5

func _ready():
	if fun == 0:
		$OpenAI.list_models()
	
	if fun == 1:
		$OpenAI.retrieve_model('davinci-instruct-beta:2.0.0')
	
	if fun == 2:
		$OpenAI.create_completion(
			'write gdscript code that prints resident evil in japanese',
			16
		)
	
	if fun == 3:
		$OpenAI.create_chat_completion('who is jill valentine in 10 words or less?', 64)
	
	if fun == 4:
		$OpenAI.create_chat_completion(
			JSON.stringify([
				{ 'role': 'system', 'content': 'you are an ai that talks like albert wesker' },
				{ 'role': 'user', 'content': 'how do i kill a zombie?' }
			]),
			256,
			false
		)

	if fun == 5:
		$OpenAI.create_image(
			'interior of a castle in the style of resident evil 1'
		)
		
	pass


func _on_open_ai_response(type, payload):
	if type == 2:
		print(payload.choices[0].text)
		var expression = Expression.new()
		var error = expression.parse(payload.choices[0].text)
		if error != OK:
			print(expression.get_error_text())
			return
		var result = expression.execute()
		if not expression.has_execute_failed():
			print(str(result))
		else:
			print("failed, " + str(result))
			
	elif type == 3:
		print(payload.choices[0].message.content)
		
	elif type == 4:
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

func _exit_tree():
	$OpenAI.cleanup()
