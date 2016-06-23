package ;
import luxe.Scene;
import luxe.Vector;
import luxe.Text;
import luxe.Color;

class Timer {
    var seconds_text:Text;
    var decimals_text:Text;
    var point_size:Int = 60;

    var cur_t:Float = 0.0;

    public function new(_rotation_radius:Float, _scene:Scene) {
        var font = Luxe.resources.font('assets/fonts/kontanter.fnt');

            //now that we have some fonts, lets write something
        seconds_text = new Text({
            font:font,
            sdf:true,
            shader:Luxe.renderer.shaders.bitmapfont.shader,
            text : "00",
            pos:new Vector((Main.screen_size / 2) - _rotation_radius * Main.screen_size, Main.screen_size / 2),
            color : new Color().rgb(0xB0B0B0),
            align : TextAlign.center,
            align_vertical : luxe.Text.TextAlign.center,
            point_size : point_size * Luxe.screen.device_pixel_ratio,
            depth:0,
            scene:_scene
        });

        decimals_text = new Text({
            font:font,
            sdf:true,
            shader:Luxe.renderer.shaders.bitmapfont.shader,
            text : "00",
            pos:new Vector((Main.screen_size / 2) + _rotation_radius * Main.screen_size, Main.screen_size / 2),
            color : new Color().rgb(0xB0B0B0),
            align : TextAlign.center,
            align_vertical : luxe.Text.TextAlign.center,
            point_size : point_size * Luxe.screen.device_pixel_ratio,
            depth:0,
            scene:_scene
        });
    }

    public function update(_dt:Float) {
        cur_t += _dt;
        var seconds = Math.floor(cur_t);
        var decimals = cur_t - seconds;
        decimals = Math.floor(decimals * 100); //2 decimal points
        seconds_text.text = Std.string(seconds);
        var decimals_string = Std.string(decimals);
        if(decimals_string.length == 1) decimals_string = '0' + decimals_string;
        decimals_text.text = decimals_string;

    }
}