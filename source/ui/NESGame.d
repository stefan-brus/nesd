/**
 * NESGame class
 *
 * Handles communication between console and peripherals
 */

module ui.NESGame;

import nesd.Console;

import ui.model.IGame;
import ui.GL;
import ui.SDL;

/**
 * NESGame class
 */

public class NESGame : IGame
{
    /**
     * Console reference
     */

    private Console* console;

    /**
     * Constructor
     *
     * Params:
     *      console = The console reference
     */

    public this ( Console* console )
    {
        this.console = console;
    }

    /**
     * Initialize the game
     */

    override public void init ( )
    {

    }

    /**
     * Render the world
     */

    override public void render ( )
    {
        GL.clear(GL.COLOR_BUFFER_BIT);

        ubyte[256 * 240 * 4] data;

        foreach ( i, val; data )
        {
            import std.random;
            data[i] = cast(ubyte)uniform(0, ubyte.max);
        }

        import derelict.opengl3.gl;

        glDrawPixels(256, 240, GL.RGBA, GL.UNSIGNED_BYTE, data.ptr);

        GL.flush();
    }

    /**
     * Handle the given event
     *
     * Params:
     *      event = The event
     *
     * Returns:
     *      True on success
     */

    override public bool handle ( SDL.Event event )
    {
        return true;
    }

    /**
     * Update the world
     *
     * Params:
     *      ms = The number of elapsed milliseconds since the last step
     */

    override public void step ( uint ms )
    {
        this.console.step();
    }
}
