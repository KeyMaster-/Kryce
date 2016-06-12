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
    var patterns_file:JSONResource;

    var game:MainGame;

    override function config(config:GameConfig) {

        config.window.title = 'luxe game';
        config.window.width = 960;
        config.window.height = 640;
        config.window.fullscreen = false;

        config.preload.jsons.push({id:file_path('config.json')});
        config.preload.jsons.push({id:file_path('assets/patterns.json')});

        return config;

    } //config

    inline function file_path(_file:String) {
        return #if project_assets '../../../../../' + #end _file;
    }

    override function ready() {

        user_config = Luxe.resources.json(file_path('config.json'));
        patterns_file = Luxe.resources.json(file_path('assets/patterns.json'));

        input = new InputMap();
        input.bind_gamepad_button('reload_config', 11); //dpad up
        input.bind_gamepad_button('reload_patterns', 14); //dpad right

        input.on(InteractType.down, ondown);

        game = new MainGame();
        Luxe.scene = game;

        Luxe.on(luxe.Ev.init, oninit);

        // Luxe.on(luxe.Ev.gamepaddown, function(_e:GamepadEvent){trace(_e.button);});
    } //ready

    function oninit(_) {
        game.resources(patterns_file.asset.json);
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
            case 'reload_patterns':
                patterns_file.reload().then(function(res:JSONResource) {
                    trace(res.asset.json);
                    patterns_file = res;
                    game.resources(patterns_file.asset.json);
                });
        }
    }
} //Main
