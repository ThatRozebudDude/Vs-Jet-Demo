package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;
//import polymod.Polymod;

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = true;
	static var firstStart = true;
	static public var soundExt:String = ".ogg";

	override public function create():Void
	{
		//Polymod.init({modRoot: "mods", dirs: ['introMod']});

		// DEBUG BULLSHIT

		super.create();
		FlxG.mouse.visible = false;

		FlxG.save.bind('data');

		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		KeyBinds.keyCheck();
		PlayerSettings.init();

		Main.fpsDisplay.visible = true;

		startIntro();
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		Conductor.changeBPM(110);
		persistentUpdate = true;

		logoBl = new FlxSprite(25, 15);
		logoBl.frames = Paths.getSparrowAtlas("jet/menu/logo");
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump',  true);
		logoBl.updateHitbox();

		var bg:FlxSprite = new FlxSprite(-320).loadGraphic(Paths.image("jet/menu/YellowBG"));

		var bars:FlxSprite = new FlxSprite(-320).loadGraphic(Paths.image("jet/menu/bars"));

		var jet:FlxSprite = new FlxSprite(785, 40).loadGraphic(Paths.image("jet/menu/jetMenu"));

		jet.x += jet.width;
		FlxTween.tween(jet, {x: jet.x - jet.width}, 1.6, {ease: FlxEase.quintOut, startDelay: 0.5});

		add(bg);
		add(jet);
		add(bars);
		add(logoBl);

		//titleText = new FlxSprite(100, FlxG.height * 0.8);
		//titleText.frames = Paths.getSparrowAtlas("titleEnter");
		//titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		//titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		//titleText.antialiasing = true;
		//titleText.animation.play('idle');
		//titleText.updateHitbox();
		// titleText.screenCenter(X);
		//add(titleText);

		skipIntro();
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if(initialized){
			Conductor.songPosition = FlxG.sound.music.time;
			// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

			if (FlxG.keys.justPressed.F)
			{
				FlxG.fullscreen = !FlxG.fullscreen;
			}

			var pressedEnter:Bool = controls.ACCEPT || controls.PAUSE;

			if (pressedEnter && !transitioning && skippedIntro)
			{
				//titleText.animation.play('press');

				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play('assets/sounds/confirmMenu.ogg', 0.7);

				if(firstStart){
					var scratch = new FlxSound().loadEmbedded("assets/sounds/jetMenuTransition.ogg", false, true);
					scratch.onComplete = function(){
						FlxG.sound.playMusic("assets/music/jetMenuLoop.ogg", 1);
						FlxG.sound.music.volume = 1;
					};
					scratch.play();

					FlxG.sound.music.fadeOut(0.1, 0);

					firstStart = false;
				}

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					// Check if version is outdated
					FlxG.switchState(new MainMenuState());
				});
				// FlxG.sound.play('assets/music/titleShoot' + TitleState.soundExt, 0.7);
			}
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump', true);

		FlxG.log.add(curBeat);
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			FlxG.camera.flash(FlxColor.WHITE, 1);
			PlayerSettings.player1.controls.loadKeyBinds();
			Config.configCheck();
			skippedIntro = true;
		}
	}
}
