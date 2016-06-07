
import luxe.GameConfig;
import luxe.Input;
import luxe.Visual;
import luxe.Vector;
import luxe.Color;
import luxe.utils.Maths;
import luxe.options.GeometryOptions;
import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;
import phoenix.Batcher.PrimitiveType;
import InputMap;
import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Shape;
import luxe.collision.Collision;
import luxe.collision.data.ShapeCollision;
import luxe.resource.Resource.JSONResource;
import ShapePhysics;

class Main extends luxe.Game {

    var input:InputMap;

    var stick_deadzone:Float = 30.0;

    var rotation_radius:Float = 200;
    var dots_radius:Float = 20;
    var ball_radius:Float = 20;

    var weakspot:Weakspot;

    var phys_engine:ShapePhysics;
    var user_config:JSONResource;

    var ball_spawner:BallSpawner;

    override function config(config:GameConfig) {

        config.window.title = 'luxe game';
        config.window.width = 960;
        config.window.height = 640;
        config.window.fullscreen = false;

        var config_path = 'config.json';
        #if project_assets config_path = '../../../../../' + config_path; #end
        config.preload.jsons.push({id:config_path});

        return config;

    } //config

    override function ready() {

        user_config = Luxe.resources.json(#if project_assets '../../../../../' + #end 'config.json');

        input = new InputMap();
        input.bind_gamepad_range('left_stick', 0, -1, 1, true, false, false);
        input.bind_gamepad_range('left_stick', 1, -1, 1, true, false, false);
        input.bind_gamepad_range('right_stick', 2, -1, 1, true, false, false);
        input.bind_gamepad_range('right_stick', 3, -1, 1, true, false, false);
        // input.bind_gamepad_button('left_bumper', 9);
        // input.bind_gamepad_button('right_bumper', 10);
        input.bind_gamepad_button('reset', 4); //back
        input.bind_gamepad_button('start', 6); //start
        input.bind_gamepad_button('reload_config', 11); //dpad up

        input.on(InteractType.change, onchange);
        input.on(InteractType.down, ondown);

        phys_engine = Luxe.physics.add_engine(ShapePhysics);

        add_walls();

        weakspot = new Weakspot(Luxe.screen.mid.x, Luxe.screen.mid.y, 20, 200, 0.15, phys_engine, {
            depth:2,
            color:new ColorHSV(5, 0.93, 0.88, 1)
        });

        ball_spawner = new BallSpawner(2.0, 400, 600, ball_radius, phys_engine, {
            color: new ColorHSV(5, 0.83, 0.93, 1.0)
        });

        // left_stick_circle = new Visual({
        //     pos:left_stick_base.clone(),
        //     geometry:Luxe.draw.circle({
        //         r:dots_radius,
        //         x:0,
        //         y:0
        //     }),
        //     color:new ColorHSV(5, 0.93, 0.88, 1),
        //     depth:2
        // });

        // right_stick_circle = new Visual({
        //     pos:right_stick_base.clone(),
        //     geometry:Luxe.draw.circle({
        //         r:dots_radius,
        //         x:0,
        //         y:0
        //     }),
        //     color:new ColorHSV(207, 0.64, 0.95, 1),
        //     depth:3
        // });

        var circumference = make_circle_geom(rotation_radius, 5, Maths.radians(10), Maths.radians(10), {
            depth: 0,
            color:new Color(1, 1, 1, 0.5)
        });
        circumference.transform.pos.copy_from(Luxe.screen.mid);

        // Luxe.on(luxe.Ev.gamepaddown, function(_e:GamepadEvent){trace(_ e.button);});
    } //ready

    function add_walls() {
        var shape:Shape = Polygon.rectangle(-10 - 2 * ball_radius, 0, 10, Luxe.screen.h + 4 * ball_radius, false);
        shape.tags.set('destroy_ball', '');
        phys_engine.statics.push(shape);
        shape = Polygon.rectangle(Luxe.screen.w + 2 * ball_radius, 0, 10, Luxe.screen.h + 4 * ball_radius, false);
        shape.tags.set('destroy_ball', '');
        phys_engine.statics.push(shape);
        shape = Polygon.rectangle(0, -10 - 2 * ball_radius, Luxe.screen.w + 4 * ball_radius, 10, false);
        shape.tags.set('destroy_ball', '');
        phys_engine.statics.push(shape);
        shape = Polygon.rectangle(0, Luxe.screen.h + 2 * ball_radius, Luxe.screen.w + 4 * ball_radius, 10, false);
        shape.tags.set('destroy_ball', '');
        phys_engine.statics.push(shape);
    }

    override function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

    } //onkeyup

    override function update(dt:Float) {

    } //update

    function onchange(_e:InputEvent) {
        if(_e.name == 'left_stick') {
            weakspot.axis_change(_e.gamepad_event.axis, _e.gamepad_event.value);
        }
    }

    function ondown(_e:InputEvent) {
        switch(_e.name) {
            case 'reload_config':
                user_config.reload().then(function(res:JSONResource) {trace(res.asset.json); user_config = res;});
        }
    }

        //_radius: radius around 0,0; _line_width: total width of segments, half inside radius, half outside
        //_line_theta: arc length of segments, in radians; _gap_theta: arc length of gaps between segmtens, in radians
    function make_circle_geom(_radius:Float, _line_width:Float, _line_theta:Float, _gap_theta:Float, _options:GeometryOptions):Geometry {
        _line_width /= 2; //Line width becomes the offset from the center line, so overall we get _line_width wide segments

        if(_options.batcher == null) _options.batcher = Luxe.renderer.batcher;
        _options.primitive_type = PrimitiveType.triangles;

        var circle = new Geometry(_options);

        var angle = 0.0;
        var angle_end = 0.0;

        while(2 * Math.PI - angle > 0.0005) {
            angle_end = angle + _line_theta;
            var start_unit = new Vector(Math.cos(angle), Math.sin(angle));
            var end_unit = new Vector(Math.cos(angle_end), Math.sin(angle_end));

            var inner_start = start_unit.clone().multiplyScalar(_radius - _line_width);
            var outer_start = start_unit.multiplyScalar(_radius + _line_width);
            var inner_end = end_unit.clone().multiplyScalar(_radius - _line_width);
            var outer_end = end_unit.multiplyScalar(_radius + _line_width);

            circle.add(new Vertex(inner_start, _options.color));
            circle.add(new Vertex(outer_start, _options.color));
            circle.add(new Vertex(inner_end, _options.color));
            circle.add(new Vertex(outer_start, _options.color));
            circle.add(new Vertex(outer_end, _options.color));
            circle.add(new Vertex(inner_end, _options.color));

            angle = angle_end + _gap_theta;
        }

        return circle;
    }
} //Main
