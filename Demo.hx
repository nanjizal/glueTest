import gluon.webgl.GLBuffer;
import gluon.webgl.GLContext;
import gluon.webgl.GLProgram;
import gluon.webgl.GLShader;
import typedarray.Float32Array;
import haxe.Timer;

// gl stuff
import kitGL.gluon.BufferGL;
import kitGL.gluon.ColorPositions;
import kitGL.gluon.HelpGL;
import kitGL.gluon.Shaders;

// Color pallettes
import pallette.simple.QuickARGB;
// SVG path parser
import justPath.*;
import justPath.transform.ScaleContext;
import justPath.transform.ScaleTranslateContext;
import justPath.transform.TranslationContext;
// Sketching
import trilateral3.drawing.StyleEndLine;
import trilateral3.drawing.Sketch;
import trilateral3.drawing.StyleSketch;
import trilateral3.drawing.Fill;
import trilateral3.drawing.Pen;
import trilateral3.geom.FlatColorTriangles;
import trilateral3.nodule.PenNodule;



/**
    Draws a triangle with OpenGL

    This class is fully cross platform (and can also be used with WebGL)

    It doesn't have any ownership or knowledge of the native window
**/
class Demo {
    
    public var pen: Pen;
    public var penNodule = new PenNodule();
    public var posLoc: Int;
    public var colorLoc: Int;
    final gl:             GLContext;
    public var program:        GLProgram;
    public var buf: GLBuffer;
    public
    function new( gl: GLContext ){
        this.gl = gl;
        trace('MinimalGL created');
        setup();
    }
    inline
    function setup(){
        pen = penNodule.pen;
        program = programSetup( gl, vertexString0, fragmentString0 );
        draw();
        buf = interleaveXYZ_RGBA( gl
                                , program
                                , penNodule.data
                                , 'vertexPosition', 'vertexColor', true );
        
        gl.disable(    CULL_FACE );
        posLoc   = gl.getAttribLocation( program, 'vertexPosition' );
        colorLoc = gl.getAttribLocation( program, 'vertexColor' );
    }
    // override this for drawing initial scene
    public
    function draw(){
        
        pen.addTriangle( 100., 100., 0.
                       , 500., 500., 0.
                       , 100., 500., 0. );
        pen.addTriangle( 100, 100, 0
                       , 500, 100, 0
                       , 500, 500, 0);
        pen.addTriangle( 300, 300, 0
                       , 400, 300, 0
                       , 400, 400, 0);
        // start coloring from second triangle
        pen.pos = 0;
        pen.colorTriangles( 0xFFFFFF, 1 ); // White
        pen.colorTriangles( 0xFFFF0000, 1 ); // Red
        pen.colorTriangles( 0xFFFFFF00, 1 ); // Yellow
        // drawing a border 
        var sketch = new Sketch( pen, StyleSketch.Fine, StyleEndLine.both ); // ending not working at moment
        //pen.currentColor = 0xFF00FFFF; <- not working... need to check.
        sketch.width = 30;
        var start = pen.pos;
        sketch.moveTo( 50., 50. );
        sketch.lineTo( 550., 50. );
        sketch.lineTo( 550., 550. );
        sketch.lineTo( 50., 550. );
        sketch.lineTo( 50., 50. );
        var end = pen.pos;
        pen.pos = start;
        var numberTriangles = Std.int( end-start );
        pen.colorTriangles( 0xFF0000FF, numberTriangles ); // color border Blue
    }
    public
    function drawFrame() {
        var t_s = haxe.Timer.stamp();
        // execute commands on the OpenGL context
        trace( 'drawFrame' );
        //clearAll( gl, 400, 400 );
        renderDraw();
        gl.bindBuffer( ARRAY_BUFFER, buf );
        interleaveXYZ_RGBA_reconnect( gl
                                    , program
                                    , 'vertexPosition', 'vertexColor' );
                                    //trace( penNodule.data );
        var angle = Math.PI * 2 / 3;
        var datum = new Float32Array([
            Math.sin( angle * 0 ), Math.cos( angle * 0 ), 1., 0xff, 0xff, 0x00, 0x00,
            Math.sin( angle * 1 ), Math.cos( angle * 1 ), 1., 0xff, 0xff, 0x00, 0x00,
            Math.sin( angle * 2 ), Math.cos( angle * 2 ), 1., 0xff, 0xff, 0x00, 0x00
        ]);
        gl.bufferSubData( ARRAY_BUFFER, 0, datum );//penNodule.data );
        gl.useProgram( program );
        gl.drawArrays( TRIANGLES, 0, penNodule.size );
        
    }
    // override this for drawing every frame or changing the data.
    public
    function renderDraw(){
    
    }
}