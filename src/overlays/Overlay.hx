package overlays;
import luxe.Text;
import timeline.Timeline;
import timeline.Timelines;
import timeline.PropTween;
import timeline.Trigger;

class Overlay {
    public var visible(default, null):Bool = true;

    var texts:Array<Text>;

    var tween_in_time:Float = 0;
    var tween_out_time:Float = 0;

    public function new() {
        texts = [];
    }

    public function resources(_config:Dynamic) {
        tween_in_time = _config.tween_in_time;
        tween_out_time = _config.tween_out_time;
    }

    public function set_visible(_v:Bool, _tween:Bool = true):Bool {

        if(_tween) {
            var tl = new Timeline();
            for(text in texts) {
                
                if(_v) {
                    text.visible = _v;
                    text.color.a = 0;
                    tl.add(new PropTween(text.color, 'a', 0, tween_in_time, timeline.easing.Quad.easeInOut).to(1));
                }
                else {
                    text.color.a = 1;
                    tl.add(new PropTween(text.color, 'a', 0, tween_out_time, timeline.easing.Quad.easeInOut).to(0));
                }
            }
            if(!_v) {
                tl.add(new Trigger(tween_out_time, function(_) {
                    for(text in texts) text.visible = false;
                }));
            }
            Timelines.add(tl);
        }
        else {
            for(text in texts) {
                text.visible = _v;
            }
        }

        return visible = _v;
    }
}