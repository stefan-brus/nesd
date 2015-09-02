/**
 * A NES Console.
 *
 * Contains all components such as memory, CPU, PPU, peripherals, etc.
 */

module nesd.Console;

import nesd.cpu.CPU;
import nesd.INES;
import nesd.Memory;
import nesd.PPU;

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
     * The PPU
     */

    PPU ppu;

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
     * Run one step of the console
     */

    void step ( )
    {
        enum PPU_STEPS_PER_CYCLE = 3;

        auto cycles = this.cpu.step();

        for ( auto i = 0; i < cycles * PPU_STEPS_PER_CYCLE; i++ )
        {
            this.ppu.step();
        }
    }
}
