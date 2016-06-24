package ;
import luxe.Scene;
import luxe.Vector;
import luxe.Text;
import luxe.Color;

class TimerDisplay {
    var seconds_left:Text;
    var seconds_right:Text;
    var decimals_left:Text;
    var decimals_right:Text;

    var point_size:Int = 60;

    var rotation_radius:Float;

    public function new(_rotation_radius:Float, _scene:Scene) {
        rotation_radius = _rotation_radius;

        var font = Luxe.resources.font('assets/fonts/kelsonsans_bold/kelsonsans_bold.fnt');

        var color = ColorMgr.background.clone();
        var color_hsv = color.toColorHSV();
        color_hsv.v *= 0.4;
        color = color_hsv.toColor();

            //now that we have some fonts, lets write something
        seconds_left = new Text({
            font:font,
            sdf:true,
            shader:Luxe.renderer.shaders.bitmapfont.shader,
            text : '0',
            pos:Main.mid.clone().add_xyz(-rotation_radius * Main.screen_size),
            color : color,
            align : TextAlign.right,
            align_vertical : luxe.Text.TextAlign.center,
            point_size : point_size * Luxe.screen.device_pixel_ratio,
            depth:0,
            scene:_scene
        });

        seconds_right = new Text({
            font:font,
            sdf:true,
            shader:Luxe.renderer.shaders.bitmapfont.shader,
            text : '0',
            pos:Main.mid.clone().add_xyz(-rotation_radius * Main.screen_size),
            color : color,
            align : TextAlign.left,
            align_vertical : luxe.Text.TextAlign.center,
            point_size : point_size * Luxe.screen.device_pixel_ratio,
            depth:0,
            scene:_scene
        });

        decimals_left = new Text({
            font:font,
            sdf:true,
            shader:Luxe.renderer.shaders.bitmapfont.shader,
            text : '0',
            pos:Main.mid.clone().add_xyz(rotation_radius * Main.screen_size),
            color : color,
            align : TextAlign.right,
            align_vertical : luxe.Text.TextAlign.center,
            point_size : point_size * Luxe.screen.device_pixel_ratio,
            depth:0,
            scene:_scene
        });

        decimals_right = new Text({
            font:font,
            sdf:true,
            shader:Luxe.renderer.shaders.bitmapfont.shader,
            text : '0',
            pos:Main.mid.clone().add_xyz(rotation_radius * Main.screen_size),
            color : color,
            align : TextAlign.left,
            align_vertical : luxe.Text.TextAlign.center,
            point_size : point_size * Luxe.screen.device_pixel_ratio,
            depth:0,
            scene:_scene
        });
    }

    public function update(_time:Float) {
        var seconds = Math.floor(_time);
        var seconds_tens = Math.floor(seconds / 10);
        var seconds_ones = seconds - seconds_tens * 10;

        seconds_left.text = Std.string(seconds_tens);
        seconds_right.text = Std.string(seconds_ones);

        // seconds_text.text = Std.string(seconds);
        var decimals = _time - seconds;
        decimals = Math.floor(decimals * 100); //2 decimal points

        var decimals_tens = Math.floor(decimals / 10);
        var decimals_ones = decimals - decimals_tens * 10;
        
        decimals_left.text = Std.string(decimals_tens);
        decimals_right.text = Std.string(decimals_ones);

    }

    public function resources(_config:Dynamic) {
        seconds_left.pos.x = Main.mid.x - rotation_radius * Main.screen_size + _config.seconds.x_offset;
        seconds_right.pos.x = seconds_left.pos.x;
        decimals_left.pos.x = Main.mid.x + rotation_radius * Main.screen_size + _config.decimals.x_offset;
        decimals_right.pos.x = decimals_left.pos.x;
    }
}