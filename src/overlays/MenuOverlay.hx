package overlays;
import luxe.Text;
import luxe.Vector;
import luxe.Color;

class MenuOverlay extends Overlay {
    public function new() {
        super();

        var regular = Luxe.resources.font('assets/fonts/kelsonsans_regular/kelsonsans_regular.fnt');
        var bold = Luxe.resources.font('assets/fonts/kelsonsans_bold/kelsonsans_bold.fnt');

        texts.push(new Text({
            font:bold,
            sdf:true,
            text:'KRYCE',
            point_size:70 * Luxe.screen.device_pixel_ratio,
            align:TextAlign.center,
            align_vertical:TextAlign.top,
            color:ColorMgr.bullet.clone(),
            depth:5
        })); //texts[0] - title

        texts.push(new Text({
            font:regular,
            sdf:true,
            text:'by Tilman Schmidt {@Keymaster_}\nfor the Simple Jam',
            point_size:20 * Luxe.screen.device_pixel_ratio,
            align:TextAlign.center,
            align_vertical:TextAlign.top,
            depth:5
        })); //texts[1] - credits 1

        texts.push(new Text({
            font:regular,
            sdf:true,
            text:'made with the Luxe game engine {luxeengine.com}',
            point_size:14 * Luxe.screen.device_pixel_ratio,
            align:TextAlign.center,
            align_vertical:TextAlign.bottom,
            pos:new Vector(0, 0),
            color:new luxe.Color(0.8, 0.8, 0.8),
            depth:5
        })); //texts[2] - credits 2 (Luxe credits)

        texts.push(new Text({
            font:regular,
            sdf:true,
            text:'font: Kelson Sans by Bruno Mello, from fontfabric.com',
            point_size:13 * Luxe.screen.device_pixel_ratio,
            align:TextAlign.center,
            align_vertical:TextAlign.bottom,
            pos:new Vector(0, 0),
            color:new luxe.Color(0.75, 0.75, 0.75),
            depth:5
        })); //texts[3] - credits 3 (Font credits)

        var instructions_text = 'use left analog stick to move\n' + 
                            'dodge the shots\n' + 
                            'press start to play\n\n' +
                            'press back/select to use the other analog stick';

        texts.push(new Text({
            font:regular,
            sdf:true,
            text:'use [left analog stick] to move',
            point_size:18 * Luxe.screen.device_pixel_ratio,
            align:TextAlign.center,
            align_vertical:TextAlign.top,
            depth:5
        })); //texts[4] - instructions 1

        texts.push(new Text({
            font:regular,
            sdf:true,
            text:'dodge the shots',
            point_size:18 * Luxe.screen.device_pixel_ratio,
            align:TextAlign.center,
            align_vertical:TextAlign.top,
            depth:5
        })); //texts[5] - instructions 2

        texts.push(new Text({
            font:regular,
            sdf:true,
            text:'press [start] to play',
            point_size:18 * Luxe.screen.device_pixel_ratio,
            align:TextAlign.center,
            align_vertical:TextAlign.top,
            depth:5
        })); //texts[6] - instructions 3

        texts.push(new Text({
            font:regular,
            sdf:true,
            text:'[back|select] to switch analog stick\n[Y|Triangle] to mute sound\n[B/Circle] to quit',
            point_size:16 * Luxe.screen.device_pixel_ratio,
            align:TextAlign.center,
            align_vertical:TextAlign.top,
            depth:5
        })); //texts[7] - instructions 4

        Luxe.events.listen('Colors.update', colors_update);
    }

    override public function resources(_config:Dynamic) {
        super.resources(_config);
        texts[0].pos.set_xy(_config.title.x, _config.title.y);
        texts[1].pos.set_xy(_config.credits.x, _config.credits.y);
        texts[2].pos.set_xy(_config.credits2.x, _config.credits2.y);
        texts[3].pos.set_xy(_config.credits3.x, _config.credits3.y);
        texts[4].pos.set_xy(_config.instructions1.x, _config.instructions1.y);
        texts[5].pos.set_xy(_config.instructions2.x, _config.instructions2.y);
        texts[6].pos.set_xy(_config.instructions3.x, _config.instructions3.y);
        texts[7].pos.set_xy(_config.instructions4.x, _config.instructions4.y);
    }

    function colors_update(_) {
        texts[4].color = ColorMgr.menu_instructions_light.clone();
        texts[5].color = ColorMgr.menu_instructions_dark.clone();
        texts[6].color = ColorMgr.menu_instructions_light.clone();
        texts[7].color = ColorMgr.menu_instructions_dark.clone();
    }
}