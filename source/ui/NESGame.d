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
