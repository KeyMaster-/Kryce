package timeline;
import timeline.Timeline.TimelineElement;

typedef TweenFunc = Float->Float->Float->Float;

    //A basic tween that handles a single float value. Not useful on its own, use subclasses such as PropTween
class FloatTween implements TimelineElement {
    public var start_t:Float;
    public var end_t:Float;
    public var initialised:Bool = false;
    var diff_t:Float;

    var from_val:Float = Math.NaN;
    var to_val:Float = Math.NaN;
    var delta_val:Float = Math.NaN;
    var tween_func:TweenFunc;

    public function new(_start_t:Float, _end_t:Float, _tween_func:TweenFunc) {
        start_t = _start_t;
        end_t = _end_t;
        diff_t = end_t - start_t;
        tween_func = _tween_func;
    }

    public function to(_val:Float):FloatTween {
        to_val = _val;
        return this;
    }

    public function from(_val:Float):FloatTween {
        from_val = _val;
        return this;
    }

    public function delta(_val:Float):FloatTween {
        delta_val = _val;
        return this;
    }

    function get():Float {
        return 0; //To be overridden
    }

    function set(_val:Float):Void {
        //To be overridden
    }

    public function update(_t:Float) {
        var normalised = (_t - start_t) / diff_t; //NOTE If a tween has diff_t == 0 this will produce NaN values! Easily fixed but not sure if it should be allowed / designed for
        set(tween_func(from_val, delta_val, normalised));
    }

    public function init():Void {
        if(Math.isNaN(from_val)) from_val = get(); //Get a from value if not supplied

        if(!Math.isNaN(to_val)) delta_val = to_val - from_val; //If the to value is valid, calculate the diff
        initialised = true;
    }
}