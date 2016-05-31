package shapes;
import luxe.Vector;
import phoenix.geometry.Geometry;

interface TwoPointForm {
    function reposition(left_pos:Vector, right_pos:Vector):Void;
    function show():Void;
    function hide():Void;
    
    function duplicate():TwoPointForm;
}