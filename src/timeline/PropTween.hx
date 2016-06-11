package timeline;
import timeline.FloatTween;

class PropTween extends FloatTween {
    var target:Dynamic;
    var prop:String;

    public function new(_target:Dynamic, _prop:String, _start_t:Float, _end_t:Float, _tween_func:TweenFunc) {
        target = _target;
        prop = _prop;
        super(_start_t, _end_t, _tween_func); //Do super call after setup, since super will call get(), which needs prop and target set
    }

    override function get() {
        return Reflect.getProperty(target, prop);
    }

    override function set(_val:Float) {
        Reflect.setProperty(target, prop, _val);
    }
}