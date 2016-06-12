package timeline;
import timeline.FloatTween;

class FuncTween extends FloatTween {
    var get_func:Void->Float;
    var set_func:Float->Void;

    public function new(_get_func:Void->Float, _set_func:Float->Void, _start_t:Float, _end_t:Float, _tween_func:TweenFunc) {
        get_func = _get_func;
        set_func = _set_func;
        super(_start_t, _end_t, _tween_func);
    }

    override function get() {
        return get_func();
    }

    override function set(_val:Float) {
        set_func(_val);
    }
}