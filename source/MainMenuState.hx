package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import lime.utils.Assets;
import flixel.math.FlxMath;
import flixel.text.FlxText;

using StringTools;

class MainMenuState extends MusicBeatState
{
	
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	
	//var configText:FlxText;
	//var configSelected:Int = 0;
	
	var optionShit:Array<String> = ['play', "options"];
	var optionLocations:Array<Array<Float>> = [[600, 50], [425, 325]];

	var jet:FlxSprite;
	var magenta:FlxSprite;
	var magentaJet:FlxSprite;

	var versionText:FlxText;
	var keyWarning:FlxText;

	override function create()
	{

		openfl.Lib.current.stage.frameRate = 144;

		if (!FlxG.sound.music.playing)
		{	
			FlxG.sound.playMusic("assets/music/jetMenuLoop.ogg", 1);
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-320).loadGraphic(Paths.image("jet/menu/YellowBG"));
		bg.scrollFactor.set(0);
		bg.antialiasing = true;
		add(bg);

		jet = new FlxSprite(-54, 40).loadGraphic(Paths.image("jet/menu/jetYellow"));
		jet.scrollFactor.set(0);
		jet.antialiasing = true;
		add(jet);

		magenta = new FlxSprite(-320).loadGraphic(Paths.image("jet/menu/PinkBG"));
		magenta.scrollFactor.set(0);
		magenta.antialiasing = true;
		magenta.visible = false;
		add(magenta);

		magentaJet = new FlxSprite(-54, 40).loadGraphic(Paths.image("jet/menu/jetPink"));
		magentaJet.scrollFactor.set(0);
		magentaJet.antialiasing = true;
		magentaJet.visible = false;
		add(magentaJet);

		jet.x -= jet.width;
		FlxTween.tween(jet, {x: jet.x + jet.width}, 1.2, {ease: FlxEase.quintOut});

		magentaJet.x -= magentaJet.width;
		FlxTween.tween(magentaJet, {x: magentaJet.x + magentaJet.width}, 1.2, {ease: FlxEase.quintOut});

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas("jet/menu/menuButtons");

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite();
			menuItem.x = optionLocations[i][0];
			menuItem.y = optionLocations[i][1];
			menuItem.frames = tex;
			
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}

		versionText = new FlxText(5, FlxG.height - 21, 0, Assets.getText('assets/data/version.txt'), 16);
		versionText.scrollFactor.set();
		versionText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionText);

		keyWarning = new FlxText(5, FlxG.height - 21 + 16, 0, "If your controls aren't working, try pressing BACKSPACE to reset them.", 16);
		keyWarning.scrollFactor.set();
		keyWarning.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyWarning.alpha = 0;
		add(keyWarning);

		FlxTween.tween(versionText, {y: versionText.y - 16}, 0.75, {ease: FlxEase.quintOut, startDelay: 10});
		FlxTween.tween(keyWarning, {alpha: 1, y: keyWarning.y - 16}, 0.75, {ease: FlxEase.quintOut, startDelay: 10});

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();
		
		//Offset Stuff
		Config.reload();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
	
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
				changeItem(1);
			}

			if (FlxG.keys.justPressed.BACKSPACE)
			{
				KeyBinds.resetBinds();
				FlxG.switchState(new MainMenuState());
			}

			if (controls.BACK && !selectedSomethin)
			{
				selectedSomethin = true;
				FlxG.sound.play('assets/sounds/cancelMenu.ogg');
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
			
				//Config.write(offsetValue, accuracyType, healthValue / 10.0, healthDrainValue / 10.0);
			
				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game", "&"]);
					#else
					FlxG.openURL('https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game');
					#end
				}
				
				else
				{
					selectedSomethin = true;
					FlxG.sound.play('assets/sounds/confirmMenu.ogg', 0.7);
					
					var daChoice:String = optionShit[curSelected];
					
					switch (daChoice){
						case 'play':
							FlxG.sound.music.stop();
						case 'options':
							FlxG.sound.music.stop();
					}

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);
					FlxFlicker.flicker(magentaJet, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								//var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'play':
										PlayState.SONG = Song.loadFromJson("top-that-hard", "top-that");
										PlayState.returnLocation = "main";
										FlxG.switchState(new PlayState());
									case 'options':
										FlxG.switchState(new ConfigMenu());
										trace("options time");
								}
							});
						}
					});
				}
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;
		//configSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
 		if (curSelected < 0)
			curSelected = menuItems.length - 1;
			
		/*if (configSelected > 3)
			configSelected = 0;
		if (configSelected < 0)
			configSelected = 3;*/

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
			}

			spr.updateHitbox();
		});
	}
}
