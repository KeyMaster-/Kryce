package timeline;
import timeline.Timeline;

class Timelines {
    static var timelines:Array<Timeline> = [];
    static var count:Int = 0;

    public static function add(_timeline:Timeline) {
        timelines.push(_timeline);
    }

    public static function step(dt:Float) {
        for(timeline in timelines) {
            timeline.step(dt);
        }

        count++;
        if(count > 60) { //Clean up every 60 frames
            count = 0;
            var idx = timelines.length;
            while(idx > 0) {
                idx--;
                if(timelines[idx].complete) {
                    timelines.splice(idx, 1);
                }
            }
        }
    }

    public static function remove(_timeline:Timeline):Bool {
        return timelines.remove(_timeline);
    }
}