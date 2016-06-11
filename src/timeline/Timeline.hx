package timeline;

class Timeline {
    public var end_t(default, null):Float = 0.0;
    public var start_t(default, null):Float = 0.0;
    public var complete(default, null):Bool = false;

    var cur_time:Float = 0.0;
    var elements:Array<TimelineElement>;

    public function new() {
        elements = [];
    }

    public function add(_element:TimelineElement) {
        var idx:Int = 0;
        while(idx < elements.length && elements[idx].start_t < _element.start_t) {
            idx++;
        }
        elements.insert(idx, _element);
        start_t = Math.min(start_t, _element.start_t);
        end_t = Math.max(end_t, _element.end_t);
    }

    public function step(dt:Float) {
        if(complete) return;

        cur_time += dt;

        var idx:Int = 0;
        while(idx < elements.length) {
            var elem = elements[idx];
            if(elem.start_t <= cur_time) {
                if(!elem.initialised) elem.init();
                if(elem.end_t <= cur_time) {
                    elem.update(elem.end_t);
                    elements.splice(idx, 1);
                    continue;
                }
                elem.update(cur_time);
                idx++;
            }
            else {
                break;
            }
        }
        
        if(cur_time >= end_t) complete = true;
    }
}

interface TimelineElement {
        // start and end in seconds
    public var start_t:Float;
    public var end_t:Float;
    public var initialised:Bool;

        //Takes the current timestamp in seconds from the timeline object
    public function update(t:Float):Void;
    public function init():Void;
}