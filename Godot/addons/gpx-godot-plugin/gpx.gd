extends Node

var gpx = null
var _gpx_interstitial_cb = null
var _gpx_interstitial_cb_fn = null
var _gpx_reward_cb = null
var _gpx_reward_cb_success_fn = null
var _gpx_reward_cb_fail_fn = null
var _pause_cb
var _resume_cb
var _sound_off_cb
var _sound_on_cb
var _visibility_cb
var _host_paused = false
var _sound_muted = false
var _page_hidden = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if OS.has_feature("web"):
		gpx = JavaScriptBridge.get_interface("GamePix")
		if gpx == null:
			printerr("GamePix SDK not found")
		_gpx_interstitial_cb = JavaScriptBridge.create_callback(_interstitial_callback)
		_gpx_reward_cb = JavaScriptBridge.create_callback(_reward_callback)
		if gpx != null:
			_pause_cb = JavaScriptBridge.create_callback(_pause)
			_resume_cb = JavaScriptBridge.create_callback(_resume)
			_sound_off_cb = JavaScriptBridge.create_callback(_sound_off)
			_sound_on_cb = JavaScriptBridge.create_callback(_sound_on)
			gpx.events.on("pause", _pause_cb)
			gpx.events.on("resume", _resume_cb)
			gpx.soundOff = _sound_off_cb
			gpx.soundOn = _sound_on_cb
			_visibility_cb = JavaScriptBridge.create_callback(_visibility_changed)
			JavaScriptBridge.get_interface("document").addEventListener("visibilitychange", _visibility_cb)
			_visibility_changed([])

func lang():
	if gpx != null:
		return gpx.lang()
	return "en"

func setItem(key, value):
	if gpx != null:
		gpx.localStorage.setItem(key, value)

func getItem(key):
	if gpx != null:
		return gpx.localStorage.getItem(key)
	
	return null

func updateScore(score):
	if gpx != null:
		gpx.updateScore(score)

func updateLevel(level):
	if gpx != null:
		gpx.updateLevel(level)

func happyMoment():
	if gpx != null:
		gpx.happyMoment()

func interstitialAd(fn = null):
	if gpx != null:
		_gpx_interstitial_cb_fn = fn
		get_tree().paused = true
		gpx.interstitialAd().then(_gpx_interstitial_cb)
	elif fn != null:
		fn.call()

func _interstitial_callback(args):
	if _gpx_interstitial_cb_fn != null:
		_gpx_interstitial_cb_fn.call()
	_gpx_interstitial_cb_fn = null
	get_tree().paused = false

func rewardAd(success = null, fail = null):
	if gpx != null:
		_gpx_reward_cb_success_fn = success
		_gpx_reward_cb_fail_fn = fail
		get_tree().paused = true
		gpx.rewardAd().then(_gpx_reward_cb)
	elif success != null:
		success.call()
	elif fail != null:
		fail.call()

func _reward_callback(args):
	if args[0].success:
		_gpx_reward_cb_success_fn.call()
	else:
		_gpx_reward_cb_fail_fn.call()

	_gpx_reward_cb_success_fn = null
	_gpx_reward_cb_fail_fn = null
	get_tree().paused = false

func gameStart():
	if gpx != null:
		gpx.lifecycle.gameStart()

func _pause(_args):
	_host_paused = true
	_apply_host_state()

func _resume(_args):
	_host_paused = false
	_apply_host_state()

func _sound_off(_args):
	_sound_muted = true
	_apply_host_state()

func _sound_on(_args):
	_sound_muted = false
	_apply_host_state()

func _visibility_changed(_args):
	_page_hidden = bool(JavaScriptBridge.get_interface("document").hidden)
	_apply_host_state()

func _apply_host_state():
	get_tree().paused = _host_paused or _page_hidden
	AudioServer.set_bus_mute(0, _host_paused or _page_hidden or _sound_muted)
