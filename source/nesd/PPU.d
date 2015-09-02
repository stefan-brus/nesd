/**
 * The NES Picture Processing Unit
 *
 * Specs: http://wiki.nesdev.com/w/index.php/PPU
 * More information: http://nesdev.com/NES%20emulator%20development%20guide.txt
 */

module nesd.PPU;

import nesd.Memory;

import util.meta.FlagByte;
import util.meta.MaxCounter;

/**
 * PPU struct
 */

struct PPU
{
    /**
     * Pointer to the memory module
     */

    Memory* memory;

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
     * PPU registers
     */

    // PPUCTRL  $2000   VPHB SINN   NMI enable (V), PPU master/slave (P), sprite height (H), background tile select (B), sprite tile select (S), increment mode (I), nametable select (NN)
    // NB: Only one nametable select bit is used here

    ubyte reg_ctrl;

    mixin FlagByte!(reg_ctrl, ["f_nmi_enable", "f_master_slave", "f_sprite_height", "f_background_tile", "f_sprite_tile", "f_increment_mode", "f_nametable"],
                              [0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02]);

    // PPUMASK  $2001   BGRs bMmG   color emphasis (BGR), sprite enable (s), background enable (b), sprite left column enable (M), background left column enable (m), greyscale (G)

    ubyte reg_mask;

    mixin FlagByte!(reg_mask, ["f_color_b", "f_color_g", "f_color_r", "f_sprite_enable", "f_background_enable", "f_sprite_left", "f_background_left", "f_greyscale"],
                              [0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01]);

    // PPUSTATUS    $2002   VSO- ----   vblank (V), sprite 0 hit (S), sprite overflow (O), read resets write pair for $2005/2006

    ubyte reg_status;

    mixin FlagByte!(reg_status, ["f_vblank", "f_sprite_zero", "f_sprite_overflow"],
                                [0x80, 0x40, 0x20]);

    /**
     * Constructor
     *
     * Params:
     *      memory = The memory module
     */

    this ( Memory* memory )
    in
    {
        assert(memory !is null);
    }
    body
    {
        this.memory = memory;
    }

    /**
     * Run one step of the PPU.
     *
     * Print the state along the way.
     */

    void step ( )
    {
        import std.stdio;

        this.readRegisters();

        if ( this.cycles == PPU_CYCLES_MAX )
        {
            this.scanline++;
        }

        this.cycles++;

        if ( this.f_background_enable || this.f_sprite_enable )
        {

        }

        writefln("cycles: %d scanline: %d",
                  this.cycles, this.scanline);
        writefln("reg_ctrl: %08b reg_mask: %08b reg_status: %08b",
                  this.reg_ctrl, this.reg_mask, this.reg_status);

        this.writeRegisters();
    }

    /**
     * Read the values of the registers from memory
     */

    private void readRegisters ( )
    {
        this.reg_ctrl = this.memory.read(0x2000);
        this.reg_mask = this.memory.read(0x2001);
        this.reg_status = this.memory.read(0x2002);
    }

    /**
     * Write the values of the registers to memory
     */

    private void writeRegisters ( )
    {
        this.memory.write(0x2000, this.reg_ctrl);
        this.memory.write(0x2001, this.reg_mask);
        this.memory.write(0x2002, this.reg_status);
    }
}
