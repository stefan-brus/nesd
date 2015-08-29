/**
 * OpenGL utilities
 *
 * Wrapper structs and utility functions
 */

module ui.GL;

import derelict.opengl3.gl;

/**
 * GL functions namespace struct wrapper
 */

public struct GL
{
    /**
     * OpenGL constants
     */

    public static enum PROJECTION = GL_PROJECTION;
    public static enum COLOR_BUFFER_BIT = GL_COLOR_BUFFER_BIT;
    public static enum QUADS = GL_QUADS;
    public static enum TRIANGLES = GL_TRIANGLES;
    public static enum TEXTURE_2D = GL_TEXTURE_2D;
    public static enum LINEAR = GL_LINEAR;
    public static enum TEXTURE_MIN_FILTER = GL_TEXTURE_MIN_FILTER;
    public static enum TEXTURE_MAG_FILTER = GL_TEXTURE_MAG_FILTER;
    public static enum RGBA = GL_RGBA;
    public static enum UNSIGNED_BYTE = GL_UNSIGNED_BYTE;
    public static enum BLEND = GL_BLEND;
    public static enum SRC_ALPHA = GL_SRC_ALPHA;
    public static enum ONE_MINUS_SRC_ALPHA = GL_ONE_MINUS_SRC_ALPHA;

    /**
     * Struct to hold information about an OpenGL texture
     */

    public struct Texture
    {
        /**
         * The texture handle
         */

        uint handle;

        /**
         * Dimensions
         */

        float width;
        float height;
    }

    /**
     * Static constructor
     *
     * Initialize Derelict OpenGL bindings
     */

    static this ( )
    {
        DerelictGL.load();
    }

    /**
     * Enable an OpenGL capability
     *
     * Params:
     *      cap = The capability
     */

    public static void enable ( int cap )
    {
        glEnable(cap);
    }

    /**
     * Disable an OpenGL capability
     *
     * Params:
     *      cap = The capability
     */

    public static void disable ( int cap )
    {
        glDisable(cap);
    }

    /**
     * Set the clear color
     *
     * Params:
     *      r = red
     *      g = green
     *      b = blue
     *      a = alpha
     */

    public static void clearColor ( float r, float g, float b, float a )
    {
        glClearColor(r,g,b,a);
    }

    /**
     * Set the matrix mode
     *
     * Params:
     *      mode = The matrix mode
     */

    public static void matrixMode ( int mode )
    {
        glMatrixMode(mode);
    }

    /**
     * Load the identity matrix
     */

    public static void loadIdentity ( )
    {
        glLoadIdentity();
    }

    /**
     * Multiply the current matrix with an orthographic matrix
     *
     * I have no idea what this means
     *
     * Params:
     *      l = left
     *      r = right
     *      b = bottom
     *      t = top
     *      n = near
     *      f = far
     */

    public static void ortho ( double l, double r, double b, double t, double n, double f )
    {
        glOrtho(l,r,b,t,n,f);
    }

    /**
     * Clear the given buffer
     *
     * Params:
     *      buffer = The buffer bit
     */

    public static void clear ( int buffer )
    {
        glClear(buffer);
    }

    /**
     * Begin drawing the given primitive
     *
     * Params:
     *      mode = The primitive to draw
     */

    public static void begin ( int mode )
    {
        glBegin(mode);
    }

    /**
     * Finish drawing a primitive
     */

    public static void end ( )
    {
        glEnd();
    }

    /**
     * Add a vertex at the given (x,y) point
     *
     * Params:
     *      x = The x coordinate
     *      y = The y coordinate
     */

    public static void vertex2f ( float x, float y )
    {
        glVertex2f(x, y);
    }

    /**
     * Set the current color
     *
     * Params:
     *      r = red
     *      g = green
     *      b = blue
     */

    public static void color3ub ( ubyte r, ubyte g, ubyte b )
    {
        glColor3ub(r, g, b);
    }

    /**
     * Set the current color
     *
     * Params:
     *      r = red
     *      g = green
     *      b = blue
     *      a = alpha
     */

    public static void color4ub ( ubyte r, ubyte g, ubyte b, ubyte a )
    {
        glColor4ub(r, g, b, a);
    }

    /**
     * Translate the current matrix along (x, y)
     *
     * Params:
     *      x = The distance along the x axis
     *      y = The distance along the y axis
     */

    public static void translate2f ( float x, float y )
    {
        glTranslatef(x, y, 0);
    }

    /**
     * Push the current matrix to some kind of stack (presumably)
     */

    public static void pushMatrix ( )
    {
        glPushMatrix();
    }

    /**
     * (Probably) pop the top matrix from the magic matrix stack
     */

    public static void popMatrix ( )
    {
        glPopMatrix();
    }

    /**
     * Generate a texture handle
     *
     * Returns:
     *      The texture handle
     */

    public static uint genTexture ( )
    {
        uint result;

        glGenTextures(1, &result);

        return result;
    }

    /**
     * Bind the given texture handle
     *
     * Params:
     *      handle = The texture handle
     */

    public static void bindTexture ( uint handle )
    {
        glBindTexture(TEXTURE_2D, handle);
    }

    /**
     * Set a texture parameter
     *
     * Params:
     *      pname = The parameter name
     *      param = The parameter value
     */

    public static void texParameteri ( int pname, int param )
    {
        glTexParameteri(TEXTURE_2D, pname, param);
    }

    /**
     * Specify an image for a texture
     *
     * Most parameters in the glTexImage2D call use default values
     *
     * Params:
     *      width = The width
     *      height = The height
     *      pixels = The pixel data
     */

    public static void texImage2D ( int width, int height, void* pixels )
    {
        glTexImage2D(TEXTURE_2D, 0, 4, width, height, 0, RGBA, UNSIGNED_BYTE, pixels);
    }

    /**
     * Set the current texture coordinates
     *
     * Params:
     *      s = The s texture coordinate
     *      t = The t texture coordinate
     */

    public static void texCoord2i ( int s, int t )
    {
        glTexCoord2i(s, t);
    }

    /**
     * Set the current texture coordinates
     *
     * Params:
     *      s = The s texture coordinate
     *      t = The t texture coordinate
     */

    public static void texCoord2f ( float s, float t )
    {
        glTexCoord2f(s, t);
    }

    /**
     * Specify how to blend pixels
     *
     * Params:
     *      sfactor = The source factor
     *      dfactor = The destination factor
     */

    public static void blendFunc ( int sfactor, int dfactor )
    {
        glBlendFunc(sfactor, dfactor);
    }

    /**
     * Flush the GL command buffer (I think)
     */

    public static void flush ( )
    {
        glFlush();
    }
}
