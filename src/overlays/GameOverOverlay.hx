package overlays;
import luxe.Text;
import luxe.Vector;

class GameOverOverlay extends Overlay {
    public function new() {
        super();
        var regular = Luxe.resources.font('assets/fonts/kelsonsans_regular/kelsonsans_regular.fnt');
        var bold = Luxe.resources.font('assets/fonts/kelsonsans_bold/kelsonsans_bold.fnt');

        texts.push(new Text({
            font:bold,
            sdf:true,
            text:'GAME OVER',
            point_size:140,
            align:TextAlign.center,
            align_vertical:TextAlign.top,
            color:ColorMgr.bullet.clone(),
            depth:5
        })); //texts[0] - game over

        texts.push(new Text({
            font:regular,
            sdf:true,
            text:'Press [start] to try again',
            point_size:40,
            align:TextAlign.center,
            align_vertical:TextAlign.top,
            depth:5
        })); //texts[1] - restart

        texts.push(new Text({
            font:regular,
            sdf:true,
            text:'Press [back|select] to return to title page',
            point_size:40,
            align:TextAlign.center,
            align_vertical:TextAlign.top,
            depth:5
        })); //texts[2] - back

        Luxe.events.listen('Colors.update', colors_update);
    }

    override public function resources(_config:Dynamic) {
        super.resources(_config);
        texts[0].pos.set_xy(_config.game_over.x, _config.game_over.y);
        texts[1].pos.set_xy(_config.restart.x, _config.restart.y);
        texts[2].pos.set_xy(_config.back.x, _config.back.y);
    }

    function colors_update(_) {
        texts[1].color = ColorMgr.menu_instructions_light.clone();
        texts[2].color = ColorMgr.menu_instructions_dark.clone();
    }
}
