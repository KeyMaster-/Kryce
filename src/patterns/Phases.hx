package patterns;

class Phases {

    public static var phases:Array<Phase> = [];

    public static function parse_info(_info:Dynamic) {
        var json_phases:Array<Dynamic> = cast(_info, Array<Dynamic>);

        var phase_time:Float = 0;
        for(json_phase in json_phases) {

            var phase = {
                start:phase_time,
                probs:[],
                names:[]
            }

            phase_time += json_phase.duration;

            var prob_sum:Float = 0.0;
            for(field in Reflect.fields(json_phase)) {
                if(field == 'duration') continue;
                var prob:Float = Reflect.getProperty(json_phase, field);
                prob_sum += prob / 100.0;
                phase.probs.push(prob_sum);
                phase.names.push(field);
            }
            phases.push(phase);
            if(prob_sum - 1.0 > 0.0001) {
                trace('Phase has total probabilities > 100%!');
                trace(phase);
            }
            else if(1.0 - prob_sum > 0.0001) {
                trace('Phase has total probabilities < 100%! May lead to infinite loops and out-of-bounds errors in get_pattern');
                trace(phase);
                trace(1 - prob_sum);
            }
        }
    }

    public static function get_rand_pattern(_phase:Phase) {
        var rnd = Math.random();
        var idx = 0;
        while(rnd >= _phase.probs[idx]) {
            idx++;
        }
        return _phase.names[idx];
    }
}

typedef Phase = {
    start:Float,
    probs:Array<Float>,
    names:Array<String>
}