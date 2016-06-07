package ;

import InputMap;
import luxe.GameConfig;
import luxe.Input;
import luxe.resource.Resource.JSONResource;
import tween.Delta;

class Main extends luxe.Game {

    var input:InputMap;

    var user_config:JSONResource;

    override function config(config:GameConfig) {

        config.window.title = 'luxe game';
        config.window.width = 960;
        config.window.height = 640;
        config.window.fullscreen = false;

        var config_path = 'config.json';
        #if project_assets config_path = '../../../../../' + config_path; #end
        config.preload.jsons.push({id:config_path});

        return config;

    } //config

    override function ready() {

        user_config = Luxe.resources.json(#if project_assets '../../../../../' + #end 'config.json');

        input = new InputMap();
        input.bind_gamepad_button('reload_config', 11); //dpad up

        input.on(InteractType.down, ondown);

        trace(Luxe.scene);

        Luxe.scene = new MainGame();

        // Luxe.on(luxe.Ev.gamepaddown, function(_e:GamepadEvent){trace(_ e.button);});
    } //ready

    override public function update(dt:Float) {
        Delta.step(dt);
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
        }
    }
} //Main
