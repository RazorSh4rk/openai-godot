extends Node


enum RESPONSE_TYPE {
	LIST_MODELS,
	RETRIEVE_MODEL,
	CREATE_COMPLETION,
	CREATE_CHAT_COMPLETION,
	CREATE_IMAGE
}
const RESOLUTIONS = ['256x256', '512x512', '1024x1024']
signal response(type: RESPONSE_TYPE, payload: Variant)
@export var API_KEY: String = ''

var BEARER = ['']
var CONTENT_TYPE = ['Content-Type: application/json']
var chat_completion_single = [
	{ 'role': 'system', 'content': 'You are an AI assistant \
		that lives in the godot game engine and helps the user in creating video games.' },
	{ 'role': 'user', 'content': '' }
]

var children = []

func _ready():
	if API_KEY == '':
		print("NEEDS API KEY")
	else:
		BEARER[0] = 'Authorization: Bearer ' + API_KEY

# Get rid of the added http request nodes
func cleanup():
	for req in children:
		print('removing ' + str(req))
		remove_child(req)

func return_callback(result, response_code, headers, body, resp_type: RESPONSE_TYPE):
	if response_code == 200:
		var response_object = JSON.parse_string(body.get_string_from_utf8())
		response.emit(resp_type, response_object)
	else:
		print(response_code)
		print(body.get_string_from_utf8())

# list completion models you have access to
# @tutorial: https://platform.openai.com/docs/api-reference/models/list
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
	return_callback(result, response_code, headers, body, RESPONSE_TYPE.LIST_MODELS)

# @tutorial: https://platform.openai.com/docs/api-reference/models/retrieve
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
	return_callback(result, response_code, headers, body, RESPONSE_TYPE.RETRIEVE_MODEL)

func create_completion(
	prompt: String,
	max_tokens: int = 16,
	model: String = 'text-davinci-003',
	temperature: int = 1,
	top_p: int = 1,
	n: int = 1,
	suffix: String = '',
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
	return_callback(result, response_code, headers, body, RESPONSE_TYPE.CREATE_COMPLETION)

func create_chat_completion(
	prompt: String,
	max_tokens: int = 16,
	single: bool = true,
	model: String = 'gpt-3.5-turbo',
	temperature: int = 1,
	top_p: int = 1,
	n: int = 1,
	):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	children.append(http_request)
	
	var gen_prompt: Array
	if single:
		gen_prompt = chat_completion_single
		gen_prompt[1]['content'] = prompt
	else:
		gen_prompt = JSON.parse_string(prompt)
	
	http_request.connect("request_completed", self._create_chat_completion_request_completed)
	http_request.request(
		'https://api.openai.com/v1/chat/completions',
		CONTENT_TYPE + BEARER,
		HTTPClient.METHOD_POST,
		JSON.stringify({
			'messages': gen_prompt,
			'model': model,
			'max_tokens': max_tokens,
			'temperature': temperature,
			'top_p': top_p,
			'n': n
		})
	)

func _create_chat_completion_request_completed(result, response_code, headers, body):
	return_callback(result, response_code, headers, body, RESPONSE_TYPE.CREATE_CHAT_COMPLETION)

func create_image(
	prompt: String,
	size: String = '256x256',
	n: int = 1,
	response_format: String = 'url'
	):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	children.append(http_request)
	
	if not size in RESOLUTIONS: size = '256x256'
	
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
	return_callback(result, response_code, headers, body, RESPONSE_TYPE.CREATE_IMAGE)
