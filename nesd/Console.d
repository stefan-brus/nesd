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
     * The memory module
     */

    Memory memory;

    /**
     * The 2A03 CPU
     */

    CPU cpu;

    /**
     * Constructor
     *
     * Params:
     *      rom = The iNES ROM file
     */

    this ( iNESFile rom )
    {
        this.memory = Memory(rom);
        this.cpu = CPU(&memory);
    }

    /**
     * Start the console
     */

    void start ( )
    {
        while ( this.cpu.step() ) {}
    }
}
