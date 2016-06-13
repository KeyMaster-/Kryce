package timeline;
import timeline.Timeline.TimelineElement;

class Updater implements TimelineElement {
    public var start_t:Float;
    public var end_t:Float;
    public var initialised:Bool = true;

    var callback:Float->Void;

    public function new(_callback:Float->Void, _start_t:Float, _end_t:Float) {
        callback = _callback;
        start_t = _start_t;
        end_t = _end_t;
    }

    public function update(_t:Float):Void {
        callback(_t);
    }

    public function init() {}
}