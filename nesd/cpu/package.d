/**
 * The 2A03 CPU, running the 6502 instruction set.
 *
 * This implementation is based on this 6502 instruction set reference:
 * http://www.obelisk.demon.co.uk/6502/reference.html
 *
 * General CPU specs:
 * http://wiki.nesdev.com/w/index.php/CPU
 */

module nesd.cpu;

import nesd.cpu.Instructions;

import std.exception;

/**
 * CPU struct
 */

struct CPU
{
    /**
     * The frequency of the NTSC NES/Famicom CPU, 1.789773 MHz
     */

    enum CLOCK_FREQ = 1789773;

    /**
     * The program ROM memory
     *
     * TODO: Replace with memory module
     */

    immutable ubyte[] prg_rom;

    /**
     * The program counter
     */

    ushort pc;

    /**
     * Constructor
     *
     * Params:
     *      prg_rom = The program ROM memory
     */

    this ( immutable ubyte[] prg_rom )
    {
        this.prg_rom = prg_rom;
    }

    /**
     * Print the next instruction + operands and increment the program counter.
     *
     * Returns:
     *      True if there is more program to step through.
     */

    bool stepPrint ( )
    in
    {
        assert(this.pc < this.prg_rom.length);
    }
    body
    {
        import std.exception;
        import std.stdio;

        auto instruction = OPCODE_TABLE[this.prg_rom[this.pc]];
        this.pc++;

        ubyte[] operands;

        if ( instruction.size > 0 ) while ( operands.length < instruction.size - 1 )
        {
            enforce(this.pc < this.prg_rom.length, "Instruction requires more operands than program size: " ~ instruction.toPrettyString!()());
            operands ~= this.prg_rom[this.pc];
            this.pc++;
        }

        string inst_string;

        // TODO: Dirty as fuck
        switch ( operands.length )
        {
            case 0:
                inst_string = instruction.toPrettyString!()();
                break;

            case 1:
                inst_string = instruction.toPrettyString!(ubyte)(operands[0]);
                break;

            case 2:
                inst_string = instruction.toPrettyString!(ubyte, ubyte)(operands[0], operands[1]);
                break;

            case 3:
                inst_string = instruction.toPrettyString!(ubyte, ubyte, ubyte)(operands[0], operands[1], operands[2]);
                break;

            default:
                enforce(false, "Can't print instructions with more than 3 operands");
        }

        writefln("%s", inst_string);

        return this.pc < this.prg_rom.length;
    }
}
