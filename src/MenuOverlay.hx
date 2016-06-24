package ;
import luxe.Text;
import luxe.Vector;

class MenuOverlay {
    public var visible(default, set):Bool = true;

    var title:Text;
    var instructions1:Text;
    var instructions2:Text;
    var instructions3:Text;
    var instructions4:Text;
    var credits:Text;
    var font_credits:Text;

    public function new() {
        var regular = Luxe.resources.font('assets/fonts/kelsonsans_regular/kelsonsans_regular.fnt');
        var bold = Luxe.resources.font('assets/fonts/kelsonsans_bold/kelsonsans_bold.fnt');

        title = new Text({
            font:bold,
            sdf:true,
            text:'GAME THING',
            point_size:70 * Luxe.screen.device_pixel_ratio,
            align:TextAlign.center,
            align_vertical:TextAlign.top,
            pos:new Vector(0, 0),
            depth:5
        });

        credits = new Text({
            font:regular,
            sdf:true,
            text:'by Tilman Schmidt {@Keymaster_}\nfor the Simple Jam',
            point_size:20 * Luxe.screen.device_pixel_ratio,
            align:TextAlign.center,
            align_vertical:TextAlign.top,
            pos:new Vector(0, 0),
            depth:5
        });

        var instructions_text = 'use left analog stick to move\n' + 
                            'dodge the shots\n' + 
                            'press start to play\n\n' +
                            'press back/select to use other analog stick';

        instructions1 = new Text({
            font:regular,
            sdf:true,
            text:'use [left analog stick] to move',
            point_size:18 * Luxe.screen.device_pixel_ratio,
            align:TextAlign.left,
            align_vertical:TextAlign.top,
            pos:new Vector(0, 0),
            depth:5
        });

        instructions2 = new Text({
            font:regular,
            sdf:true,
            text:'dodge the shots',
            point_size:18 * Luxe.screen.device_pixel_ratio,
            align:TextAlign.left,
            align_vertical:TextAlign.top,
            pos:new Vector(0, 0),
            depth:5
        });

        instructions3 = new Text({
            font:regular,
            sdf:true,
            text:'press [start] to play',
            point_size:18 * Luxe.screen.device_pixel_ratio,
            align:TextAlign.left,
            align_vertical:TextAlign.top,
            pos:new Vector(0, 0),
            depth:5
        });

        instructions4 = new Text({
            font:regular,
            sdf:true,
            text:'press [back|select] to use other analog stick',
            point_size:18 * Luxe.screen.device_pixel_ratio,
            align:TextAlign.center,
            align_vertical:TextAlign.top,
            pos:new Vector(0, 0),
            depth:5
        });
    }

    public function resources(_config:Dynamic) {
        title.pos.set_xy(_config.title.x, _config.title.y);
        credits.pos.set_xy(_config.credits.x, _config.credits.y);
        instructions1.pos.set_xy(_config.instructions1.x, _config.instructions1.y);
        instructions2.pos.set_xy(_config.instructions2.x, _config.instructions2.y);
        instructions3.pos.set_xy(_config.instructions3.x, _config.instructions3.y);
        instructions4.pos.set_xy(_config.instructions4.x, _config.instructions4.y);
    }

    function set_visible(_v:Bool):Bool {
        title.visible = _v;
        instructions1.visible = _v;
        instructions2.visible = _v;
        instructions3.visible = _v;
        instructions4.visible = _v;
        credits.visible = _v;
        return visible = _v;
    }
}