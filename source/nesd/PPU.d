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
     * Convenience alias
     */

    alias Address = Memory.Address;

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
    // NB: Initialized to 0x1f

    ubyte reg_status;

    mixin FlagByte!(reg_status, ["f_vblank", "f_sprite_zero", "f_sprite_overflow"],
                                [0x80, 0x40, 0x20]);

    // OAMADDR  $2003   aaaa aaaa   OAM read/write address

    ubyte reg_oam_addr;

    // OAMDATA  $2004   dddd dddd   OAM data read/write

    ubyte reg_oam_data;

    // PPUSCROLL   $2005   xxxx xxxx   fine scroll position (two writes: X, Y)

    ubyte reg_scroll;

    // PPUADDR  $2006   aaaa aaaa   PPU read/write address (two writes: MSB, LSB)

    ubyte reg_addr;

    // PPUDATA  $2007   dddd dddd   PPU data read/write

    ubyte reg_data;

    /**
     * Whether or not an NMI interrupt should be triggered
     */

    bool nmi;

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

        this.initPPUMemory();
        this.reg_status = 0x1f;
        this.nmi = true;
    }

    /**
     * Run one step of the PPU.
     *
     * Print the state along the way.
     */

    void step ( )
    {
        debug ( NESDPPU ) import std.stdio;

        if ( this.cycles == PPU_CYCLES_MAX )
        {
            this.scanline++;
        }

        this.cycles++;

        // render
        if ( this.f_background_enable || this.f_sprite_enable )
        {

        }

        // vblank - scanlines 241 to 261
        if ( this.cycles == 1 )
        {
            if ( this.scanline == 241 )
            {

            }
            else if ( this.scanline == 261 )
            {
                this.f_sprite_zero = false;
                this.f_sprite_overflow = false;
            }
        }

        debug ( NESDPPU ) writefln("cycles: %d scanline: %d",
                  this.cycles, this.scanline);
        debug ( NESDPPU ) writefln("reg_ctrl: %08b reg_mask: %08b reg_status: %08b",
                  this.reg_ctrl, this.reg_mask, this.reg_status);
    }

    /**
     * Initialize the PPU register mapping of the memory module
     */

    private void initPPUMemory ( )
    {
        this.memory.ppu_reg[0] = &this.reg_ctrl;
        this.memory.ppu_reg[1] = &this.reg_mask;
        this.memory.ppu_reg[2] = &this.reg_status;
        this.memory.ppu_reg[3] = &this.reg_oam_addr;
        this.memory.ppu_reg[4] = &this.reg_oam_data;
        this.memory.ppu_reg[5] = &this.reg_scroll;
        this.memory.ppu_reg[6] = &this.reg_addr;
        this.memory.ppu_reg[7] = &this.reg_data;

        this.memory.ppu_read_dg = &this.handleRead;
        this.memory.ppu_write_dg = &this.handleWrite;
    }

    /**
     * Delegates to handle reads and writes to the PPU registers
     *
     * Params:
     *      addr = The address
     */

    private void handleRead ( Address addr )
    {
        switch ( addr % 8 )
        {
            // 0x2002 - status
            case 2:
                this.f_vblank = this.nmi;
                this.nmi = !this.nmi;
                break;
            // 0x2004 - OAM data
            case 4:
                break;
            // 0x2007 - data
            case 7:
                break;

            default:
                break;
        }
    }

    private void handleWrite ( Address addr )
    {

    }
}
