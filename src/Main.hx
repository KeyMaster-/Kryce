package ;

import InputMap;
import luxe.Vector;
import luxe.GameConfig;
import luxe.Transform;
import luxe.Input.Key;
import luxe.Input.KeyEvent;
import luxe.Input.GamepadEvent;
import luxe.resource.Resource.JSONResource;
import timeline.Timelines;

class Main extends luxe.Game {
    public static var screen_size:Int = 1000;
    public static var mid:Vector;

    var input:InputMap;

    var user_config:JSONResource;
    var patterns_config:JSONResource;
    var phases_config:JSONResource;
    var colors_config:JSONResource;

    var game:MainGame;

    override function config(config:GameConfig) {

        config.window.fullscreen = false;

        config.preload.jsons.push({id:file_path('config.json')});
        config.preload.jsons.push({id:file_path('assets/patterns_config.json')});
        config.preload.jsons.push({id:file_path('assets/phases.json')});
        config.preload.jsons.push({id:file_path('assets/colors.json')});

        config.preload.fonts.push({id:'assets/fonts/kontanter.fnt'});

        return config;

    } //config

    inline function file_path(_file:String) {
        return #if project_assets '../../../../../' + #end _file;
    }

    override function ready() {
        mid = new Vector(screen_size / 2, screen_size / 2);

        user_config = Luxe.resources.json(file_path('config.json'));
        patterns_config = Luxe.resources.json(file_path('assets/patterns_config.json'));
        phases_config = Luxe.resources.json(file_path('assets/phases.json'));
        colors_config = Luxe.resources.json(file_path('assets/colors.json'));

        input = new InputMap();
        input.bind_gamepad_button('reload_config', 11); //dpad up
        input.bind_gamepad_button('reload_game_info', 14); //dpad right

        input.on(InteractType.down, ondown);
        
        ColorMgr.init();
        ColorMgr.resources(colors_config.asset.json);

        game = new MainGame();
        Luxe.scene = game;

        Luxe.on(luxe.Ev.init, oninit);

        Luxe.fixed_timestep = true;
        Luxe.fixed_frame_time = 1/60;

        Luxe.camera.size = new luxe.Vector(screen_size, screen_size);
        Luxe.camera.size_mode = luxe.Camera.SizeMode.fit;

            //Left pillar
        Luxe.draw.box({
            x:-10000,
            y:0,
            w:10000,
            h:screen_size,
            color:new luxe.Color(0, 0, 0, 1),
            depth:100
        });

            //Right pillar
        Luxe.draw.box({
            x:screen_size,
            y:0,
            w:10000,
            h:screen_size,
            color:new luxe.Color(0, 0, 0, 1),
            depth:100
        });

        Luxe.draw.box({
            x:0,
            y:-10000,
            w:screen_size,
            h:10000,
            color:new luxe.Color(0, 0, 0, 1),
            depth:100
        });

        Luxe.draw.box({
            x:0,
            y:screen_size,
            w:screen_size,
            h:10000,
            color:new luxe.Color(0, 0, 0, 1),
            depth:100
        });

        // Luxe.on(luxe.Ev.gamepaddown, function(_e:GamepadEvent){trace(_e.button);});
    } //ready

    function oninit(_) {
        game.resources(patterns_config.asset.json, phases_config.asset.json);
    }

    override public function update(dt:Float) {
        Timelines.step(dt);

        // var hsv_bg = ColorMgr.first_ring.toColorHSV();
        // hsv_bg.h += 360 * dt / 5;
        // ColorMgr.first_ring.fromColorHSV(hsv_bg);

        // var hsv_bullet = ColorMgr.bullet.toColorHSV();
        // hsv_bullet.h += 360 * dt / 5;
        // ColorMgr.bullet.fromColorHSV(hsv_bullet);

        // var hsv_laser = ColorMgr.laser.toColorHSV();
        // hsv_laser.h += 360 * dt / 5;
        // ColorMgr.laser.fromColorHSV(hsv_laser);

        // var hsv_spawner = ColorMgr.spawner.toColorHSV();
        // hsv_spawner.h += 360 * dt / 5;
        // ColorMgr.spawner.fromColorHSV(hsv_spawner);

        // var hsv_player = ColorMgr.player.toColorHSV();
        // hsv_player.h += 360 * dt / 5;
        // ColorMgr.player.fromColorHSV(hsv_player);
    }

    override public function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

    } //onkeyup

    function ondown(_e:InputEvent) {
        switch(_e.name) {
            case 'reload_config':
                user_config.reload().then(function(res:JSONResource) {trace(res.asset.json); user_config = res;});
                colors_config.reload().then(function(res:JSONResource) {
                    colors_config = res;
                    ColorMgr.resources(colors_config.asset.json);
                });
            case 'reload_game_info':
                patterns_config.reload().then(function(res:JSONResource) {
                    patterns_config = res;
                    phases_config.reload().then(function(res:JSONResource) {
                        phases_config = res;
                        game.resources(patterns_config.asset.json, phases_config.asset.json);
                    });
                });
        }
    }
} //Main
