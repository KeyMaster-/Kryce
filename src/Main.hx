package ;

import InputMap;
import luxe.GameConfig;
import luxe.Input.Key;
import luxe.Input.KeyEvent;
import luxe.Input.GamepadEvent;
import luxe.resource.Resource.JSONResource;
import timeline.Timelines;

class Main extends luxe.Game {

    var input:InputMap;

    var user_config:JSONResource;
    var patterns_config:JSONResource;
    var phases_config:JSONResource;

    var game:MainGame;

    override function config(config:GameConfig) {

        config.window.width = 960;
        config.window.height = 640;
        config.window.fullscreen = false;

        config.preload.jsons.push({id:file_path('config.json')});
        config.preload.jsons.push({id:file_path('assets/patterns_config.json')});
        config.preload.jsons.push({id:file_path('assets/phases.json')});

        return config;

    } //config

    inline function file_path(_file:String) {
        return #if project_assets '../../../../../' + #end _file;
    }

    override function ready() {

        user_config = Luxe.resources.json(file_path('config.json'));
        patterns_config = Luxe.resources.json(file_path('assets/patterns_config.json'));
        phases_config = Luxe.resources.json(file_path('assets/phases.json'));

        input = new InputMap();
        input.bind_gamepad_button('reload_config', 11); //dpad up
        input.bind_gamepad_button('reload_game_info', 14); //dpad right

        input.on(InteractType.down, ondown);

        game = new MainGame();
        Luxe.scene = game;

        Luxe.on(luxe.Ev.init, oninit);

        Luxe.fixed_timestep = true;
        Luxe.fixed_frame_time = 1/60;

        // Luxe.on(luxe.Ev.gamepaddown, function(_e:GamepadEvent){trace(_e.button);});
    } //ready

    function oninit(_) {
        game.resources(patterns_config.asset.json, phases_config.asset.json);
    }

    override public function update(dt:Float) {
        Timelines.step(dt);
    }

    override function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

    } //onkeyup

    function ondown(_e:InputEvent) {
        switch(_e.name) {
            case 'reload_config':
                user_config.reload().then(function(res:JSONResource) {trace(res.asset.json); user_config = res;});
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
