package patterns;
import luxe.Visual;
import timeline.Timeline;
import timeline.Timelines;
import timeline.PropTween;

    //Import all easing classes to make sure they're around for reflection to find
    // import timeline.easing.* doesn't seem to work
import timeline.easing.Back;
import timeline.easing.Bounce;
import timeline.easing.Cubic;
import timeline.easing.Elastic;
import timeline.easing.Expo;
import timeline.easing.Linear;
import timeline.easing.Quad;
import timeline.easing.Quart;
import timeline.easing.Quint;
import timeline.easing.Sine;

class Patterns {
    var patterns:Map<String, PatternDef>;

    public function new() {
        Luxe.events.listen('Patterns.reload', read);
        patterns = new Map();
    }

    public function read(_json:Dynamic) {
        var json_patterns:Array<Dynamic> = _json;
        for(pattern in json_patterns) {
            var pattern_def:PatternDef = {
                name:pattern.name,
                tweens:[]
            }

            var tweens:Array<Dynamic> = pattern.tweens;
            for(tween in tweens) {
                switch(tween.type) {
                    case 'sequence':
                        parse_sequence(pattern_def.tweens, tween);
                    case 'tween':
                        pattern_def.tweens.push(parse_prop_tween(tween));
                }
            }

            patterns.set(pattern.name, pattern_def);
        }
    }

    function parse_sequence(_tween_defs:Array<PropTweenDef>, _sequence:Dynamic) {
        var cur_t = _sequence.start_t;
        var tweens:Array<Dynamic> = _sequence.tweens;
        for(tween in tweens) {
            var def = parse_prop_tween(tween);
            def.start_t = cur_t;
            cur_t += tween.duration;
            def.end_t = cur_t;
            _tween_defs.push(def);
        }
    }

    function parse_prop_tween(_tween:Dynamic):PropTweenDef {
        return {
            prop:_tween.prop,
            start_t:_tween.start_t,
            end_t:_tween.end_t,
            easing:_tween.easing == null ? timeline.easing.Linear.none : get_easing(_tween.easing),
            from:_tween.from,
            to:_tween.to,
            delta:_tween.delta
        };
    }

    public function apply(_pattern:String, _target:Visual):Timeline {
        var tweens = patterns.get(_pattern).tweens;
        var tl = new Timeline();
        for(tween in tweens) {
            var prop_tween = make_prop_tween(tween, _target);
            tl.add(prop_tween);
        }
        Timelines.add(tl);
        return tl;
    }

    function make_prop_tween(_tween:PropTweenDef, _target:Visual):PropTween {
        function apply_tween_values(_tween:PropTweenDef, _prop_tween:PropTween, _scale:Float) {
            if(_tween.from != null) {
                _prop_tween.from(_tween.from * _scale);
            }
            if(_tween.to != null) {
                _prop_tween.to(_tween.to * _scale);
            }
            if(_tween.delta != null) {
                _prop_tween.delta(_tween.delta * _scale);
            }
        }

        var prop_tween:PropTween = null;
        switch(_tween.prop) {
            case 'pos.x' | 'pos.y':
                prop_tween = new PropTween(_target.pos, _tween.prop.charAt(4), _tween.start_t, _tween.end_t, _tween.easing);
                apply_tween_values(_tween, prop_tween, _tween.prop == 'pos.x' ? Luxe.screen.w : Luxe.screen.h);
            case 'angle':
                prop_tween = new PropTween(_target, 'rotation_z', _tween.start_t, _tween.end_t, _tween.easing);
                apply_tween_values(_tween, prop_tween, 1);

            default:
                throw 'Unrecognised property ${_tween.prop} in $_tween';
        }

        return prop_tween;
    }

    function get_easing(_path:String):timeline.FloatTween.TweenFunc {
        var dot_pos = _path.indexOf('.');
        if(dot_pos == -1) {
            trace('Easing name "$_path" lacks a dot!');
            return timeline.easing.Linear.none;
        }

        var type_name = _path.substring(0, dot_pos); //Tween type, e.g. Quad, Sine etc
        var flavour_name = _path.substring(dot_pos + 1); //Tween "flavour", i.e. in, out or inout
        var tween_class = Type.resolveClass('timeline.easing.' + type_name);
        
        if(tween_class == null) {
            trace('Easing class "$type_name" does not exist! (Full lookup path is "timeline.easing.$type_name")');
            return timeline.easing.Linear.none;
        }

        var func_name = switch(flavour_name) {
            case 'in': 'easeIn';
            case 'out': 'easeOut';
            case 'inout': 'easeInOut';
            default: 'easeInOut';
        }

        var tween_func = Reflect.field(tween_class, func_name);
        if(tween_func == null) {
            trace('Couldn\'t find $func_name on $type_name');
            return timeline.easing.Linear.none;
        }
        return tween_func;
    }
}

typedef PatternDef = {
    name:String,
    tweens:Array<PropTweenDef>
}

typedef PropTweenDef = {
    prop:String,
    start_t:Float,
    end_t:Float,
    easing:timeline.FloatTween.TweenFunc,
    ?from:Float,
    ?to:Float,
    ?delta:Float
}