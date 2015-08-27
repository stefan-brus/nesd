/**
 * A NES Console.
 *
 * Contains all components such as memory, CPU, PPU, peripherals, etc.
 */

module nesd.Console;

import nesd.cpu;
import nesd.INES;
import nesd.Memory;

/**
 * Console struct
 */

struct Console
{
    /**
     * The 2A03 CPU
     */

    CPU cpu;

    /**
     * The memory module
     */

    Memory memory;

    /**
     * Constructor
     *
     * Params:
     *      rom = The iNES ROM file
     */

    this ( iNESFile rom )
    {
        this.cpu = CPU(rom.prg_rom);
    }

    /**
     * Start the console
     */

    void start ( )
    {
        while ( this.cpu.step() ) {}
    }
}
