extends Node


enum RESPONSE_TYPE {
	LIST_MODELS,
	RETRIEVE_MODEL,
	CREATE_COMPLETION,
	CREATE_IMAGE
}

signal response(type: RESPONSE_TYPE, payload: Variant)

@export var API_KEY: String = ''
var BEARER = ['']
var CONTENT_TYPE = ['Content-Type: application/json']

var children = []

func _ready():
	print(BEARER+CONTENT_TYPE)
	if API_KEY == '':
		print("NEEDS API KEY")
	else:
		BEARER[0] = 'Authorization: Bearer ' + API_KEY

func list_models():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	children.append(http_request)
	
	http_request.connect("request_completed", self._list_models_request_completed)
	http_request.request(
		'https://api.openai.com/v1/models',
		BEARER,
		HTTPClient.METHOD_GET
	)

func _list_models_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var response_object = JSON.parse_string(body.get_string_from_utf8())
		response.emit(RESPONSE_TYPE.LIST_MODELS, response_object)
	else:
		print(response_code)
		
func retrieve_model(model: String):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	children.append(http_request)
	
	http_request.connect("request_completed", self._retrieve_model_request_completed)
	http_request.request(
		'https://api.openai.com/v1/models/' + model,
		BEARER,
		HTTPClient.METHOD_GET
	)

func _retrieve_model_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var response_object = JSON.parse_string(body.get_string_from_utf8())
		response.emit(RESPONSE_TYPE.RETRIEVE_MODEL, response_object)
	else:
		print(response_code)

func create_completion(
	prompt: String,
	model: String = 'text-davinci-003',
	suffix: String = '',
	max_tokens: int = 16,
	temperature: int = 1,
	top_p: int = 1,
	n: int = 1,
	):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	children.append(http_request)
	
	http_request.connect("request_completed", self._create_completion_request_completed)
	http_request.request(
		'https://api.openai.com/v1/completions',
		CONTENT_TYPE + BEARER,
		HTTPClient.METHOD_POST,
		JSON.stringify({
			'prompt': prompt,
			'model': model,
			'suffix': suffix,
			'max_tokens': max_tokens,
			'temperature': temperature,
			'top_p': top_p,
			'n': n
		})
	)

func _create_completion_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var response_object = JSON.parse_string(body.get_string_from_utf8())
		response.emit(RESPONSE_TYPE.CREATE_COMPLETION, response_object)
	else:
		print(response_code)
		print(body.get_string_from_utf8())

func create_image(
	prompt: String,
	n: int = 1,
	size: String = '256x256',
	response_format: String = 'url'
	):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	children.append(http_request)
	
	http_request.connect("request_completed", self._create_image_request_completed)
	http_request.request(
		'https://api.openai.com/v1/images/generations',
		CONTENT_TYPE + BEARER,
		HTTPClient.METHOD_POST,
		JSON.stringify({
			'prompt': prompt,
			'n': n,
			'size': size,
			'response_format': response_format
		})
	)

func _create_image_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var response_object = JSON.parse_string(body.get_string_from_utf8())
		response.emit(RESPONSE_TYPE.CREATE_IMAGE, response_object)
	else:
		print(response_code)
		print(body.get_string_from_utf8())
