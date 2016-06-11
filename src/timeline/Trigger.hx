package timeline;
import timeline.Timeline.TimelineElement;

class Trigger implements TimelineElement {
    public var start_t:Float;
    public var end_t:Float;
    public var initialised:Bool = true;

    var callback:Float->Void;

    public function new(_time:Float, _callback:Float->Void) { //The current time will be passed to the callback
        start_t = end_t = _time;
        callback = _callback;
    }

    public function update(_t:Float):Void {
        callback(_t); //If start_t = end_t, update will only be called once, so the callback will only trigger once
    }

    public function init():Void {}
}