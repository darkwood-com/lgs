## GamePix Godot Plugin

### Installation

Download the plugin archive and extract it into addons folder of your game.

Folder structure:

```
game-folder
- addons
  - gpx-godot-plugin
	- index.html
	- plugin.cfg
	- plugin.pd
	- gpx.gd
```

Once this is done:

* Open **Project -> Project Settings**
* Activate **Plugins** tab
* Enable **gamepix-sdk** plugin
* Reload project **Project -> Reload Current Project**

### Exporting game for GamePix

* Open the **Export...** dialog
* Select **GamePix** preset
* Export game using this preset and publish zip archive on GamePix

**NOTE:** Please ensure that you name the output file as "index.html" in order for it to function properly on our platform.

### Using SDK

In your scripts, you will be able to use GPX object to interact with the platform. 

For example, let's declare function that handles key events and run GamePix Ads.

### Interstitial AD

```python
func _input(ev):
	if ev is InputEventKey and ev.keycode == KEY_I and not(ev.is_pressed()):
		print("Interstitial AD started")
		GPX.interstitialAd(Callable(self, "onInterstitialComplete"))
  
func onInterstitialComplete():
	print("Intersitital AD completed")
```

When you press the "I" key, interstitial ads will be displayed, and you will see the corresponding output in the console.
```
Interstitial AD started
Intersitital AD completed
```

### Rewarded AD

```python
func _input(ev):
	if ev is InputEventKey and ev.keycode == KEY_R and not(ev.is_pressed()):
		print("Reward AD started")
		GPX.rewardAd(Callable(self, "onRewardSuccess"), Callable(self, "onRewardFail"))

func onRewardSuccess():
	print("Reward AD succeed")

func onRewardFail():
	print("Reward AD failed")
```

When you press the "R" key, reward ads will be displayed, and you will see the corresponding output in the console.
```
Reward AD started
Reward AD succeed (or failed)
```

### Resume/Pause game

When the interstitial/reward ad is active, you must pause the game and sounds. The plugin should do this automatically, but if it's not working for you, please refer to the Godot pause/resume [documentation](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html).

### Other methods

* GPX.lang() - gets the current preferred language by the player
* GPX.updateScore(score) - should be called immediately every time the current score is updated
* GPX.updateLevel(level) - should be called to send the score after the player passed the level
* GPX.happyMoment() - should be called when Happy Moment just happened 
* GPX.setItem(key, value) -  Persistently stores the value. The value must be a string.
* GPX.getItem(key) - Read value from storage.

### Game background

You can add custom background while game is loading, to do this please put `background.jpg` into root of exported game
