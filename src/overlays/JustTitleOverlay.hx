package overlays;
import luxe.Text;
import luxe.Vector;
import luxe.Color;

class JustTitleOverlay extends Overlay {
    public function new() {
        super();

        var bold = Luxe.resources.font('assets/fonts/kelsonsans_bold/kelsonsans_bold.fnt');

        texts.push(new Text({
            font:bold,
            sdf:true,
            text:'KRYCE',
            point_size:70 * Luxe.screen.device_pixel_ratio,
            align:TextAlign.center,
            align_vertical:TextAlign.center,
            color:ColorMgr.bullet.clone(),
            depth:5
        })); //texts[0] - title
        texts[0].pos.copy_from(Main.mid);
    }
}