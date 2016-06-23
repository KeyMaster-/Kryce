package ;
import luxe.Color;

class ColorMgr {
    public static var bullet:Color;
    public static var laser:Color;
    public static var player:Color;
    public static var first_ring:Color;
    public static var ring_alphas:Array<Float>;
    public static var background:Color;
    public static var spawner:Color;

    public static function init() {
        bullet = new Color();
        laser = new Color();
        player = new Color();
        first_ring = new Color();
        background = new Color();
        spawner = new Color();
    }

    public static function resources(_colors_json:Dynamic):Void {
        bullet.rgb(Std.parseInt('0x' + _colors_json.bullet));
        laser.rgb(Std.parseInt('0x' + _colors_json.laser));
        player.rgb(Std.parseInt('0x' + _colors_json.player));
        first_ring.rgb(Std.parseInt('0x' + _colors_json.first_ring));
        ring_alphas = _colors_json.ring_alphas;
        background.rgb(Std.parseInt('0x' + _colors_json.background));
        spawner.rgb(Std.parseInt('0x' + _colors_json.spawner));
    }
}