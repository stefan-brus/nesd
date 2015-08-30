/**
 * The NES Picture Processing Unit
 *
 * Specs: http://wiki.nesdev.com/w/index.php/PPU
 * More information: http://nesdev.com/NES%20emulator%20development%20guide.txt
 */

module nesd.PPU;

import util.meta.MaxCounter;

/**
 * PPU struct
 */

struct PPU
{
    /**
     * Wrapper struct for PPU cycles.
     *
     * Ensures that the cycles are between 0 and 340.
     */

    enum PPU_CYCLES_MAX = 340;

    alias Cycles = MaxCounter!(ulong, PPU_CYCLES_MAX);

    Cycles cycles;

    /**
     * Wrapper struct for scanlines
     *
     * Ensures that the scanline is between 0 and 261
     */

    enum SCANLINE_MAX = 261;

    alias Scanline = MaxCounter!(ulong, SCANLINE_MAX);

    Scanline scanline;

    /**
     * Run one step of the PPU.
     *
     * Print the state along the way.
     */

    void step ( )
    {
        import std.stdio;

        if ( this.cycles == PPU_CYCLES_MAX )
        {
            this.scanline++;
        }

        this.cycles++;

        writefln("cycles: %d scanline: %d", this.cycles, this.scanline);
    }
}
