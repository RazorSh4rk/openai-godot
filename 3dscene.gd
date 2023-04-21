extends Node3D

func _ready():
	$OpenAI.create_image('texture of old brick wall')

func _process(delta):
	pass

func _on_open_ai_response(type, payload):
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

	var texture = ImageTexture.create_from_image(image)
	$wall0.get_active_material(0).albedo_texture = texture
	$wall1.get_active_material(0).albedo_texture = texture

func _exit_tree():
	$OpenAI.cleanup()
