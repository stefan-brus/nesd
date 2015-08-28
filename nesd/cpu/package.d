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
import nesd.Memory;

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
     * Pointer to the memory module
     */

    Memory* memory;

    /**
     * The program counter
     */

    ushort pc;

    /**
     * The number of clock cycles that have passed
     */

    ulong cycles;

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

        this.reset();
    }

    /**
     * Reset the CPU
     */

    void reset ( )
    {
        this.pc = 0x8000;
        this.cycles = 0;
    }

    /**
     * Run one step of the CPU and update the state accordingly.
     *
     * Print the CPU state along the way.
     *
     * Returns:
     *      True if the CPU should continue
     */

    bool step ( )
    in
    {
        assert(this.pc < ushort.max);
    }
    body
    {
        import std.exception;
        import std.stdio;

        auto instruction = OPCODE_TABLE[this.memory.read(this.pc)];
        this.pc++;

        ubyte[] operands;

        if ( instruction.size > 0 ) while ( operands.length < instruction.size - 1 )
        {
            enforce(this.pc < ushort.max, "Instruction requires more operands than program size: " ~ instruction.name);
            operands ~= this.memory.read(this.pc);
            this.pc++;
        }

        this.cycles += instruction.cycles;

        this.runInstruction(instruction);

        writefln("cycles: %d PC: %04x", this.cycles, this.pc);

        return this.pc < ushort.max;
    }

    /**
     * Print the next instruction + operands and increment the program counter.
     *
     * Returns:
     *      True if there is more program to step through.
     */

    bool stepPrintInstructions ( )
    in
    {
        assert(this.pc < ushort.max);
    }
    body
    {
        import std.exception;
        import std.stdio;

        auto instruction = OPCODE_TABLE[this.memory.read(this.pc)];
        this.pc++;

        ubyte[] operands;

        if ( instruction.size > 0 ) while ( operands.length < instruction.size - 1 )
        {
            enforce(this.pc < ushort.max, "Instruction requires more operands than program size: " ~ instruction.name);
            operands ~= this.memory.read(this.pc);
            this.pc++;
        }

        writefln("%s", instruction.toPrettyString(operands));

        return this.pc < ushort.max;
    }

    /**
     * Run an given instruction
     *
     * Params:
     *      instruction = The instruction
     */

    private void runInstruction ( Instruction instruction )
    {
        import std.exception;

        switch ( instruction.name )
        {
            case "BRK":
                this.nop();
                break;
            case "ORA":
                this.nop();
                break;
            case "NOP":
                this.nop();
                break;
            case "ASL":
                this.nop();
                break;
            case "PHP":
                this.nop();
                break;
            case "BPL":
                this.nop();
                break;
            case "CLC":
                this.nop();
                break;
            case "JSR":
                this.nop();
                break;
            case "AND":
                this.nop();
                break;
            case "BIT":
                this.nop();
                break;
            case "ROL":
                this.nop();
                break;
            case "PLP":
                this.nop();
                break;
            case "BMI":
                this.nop();
                break;
            case "SEC":
                this.nop();
                break;
            case "RTI":
                this.nop();
                break;
            case "EOR":
                this.nop();
                break;
            case "LSR":
                this.nop();
                break;
            case "PHA":
                this.nop();
                break;
            case "JMP":
                this.nop();
                break;
            case "CLI":
                this.nop();
                break;
            case "RTS":
                this.nop();
                break;
            case "ADC":
                this.nop();
                break;
            case "ROR":
                this.nop();
                break;
            case "PLA":
                this.nop();
                break;
            case "BVS":
                this.nop();
                break;
            case "BVC":
                this.nop();
                break;
            case "SEI":
                this.nop();
                break;
            case "STA":
                this.nop();
                break;
            case "STY":
                this.nop();
                break;
            case "STX":
                this.nop();
                break;
            case "DEY":
                this.nop();
                break;
            case "TXS":
                this.nop();
                break;
            case "TXA":
                this.nop();
                break;
            case "TYA":
                this.nop();
                break;
            case "BCC":
                this.nop();
                break;
            case "LDY":
                this.nop();
                break;
            case "LDA":
                this.nop();
                break;
            case "LDX":
                this.nop();
                break;
            case "TAY":
                this.nop();
                break;
            case "TAX":
                this.nop();
                break;
            case "TSX":
                this.nop();
                break;
            case "BCS":
                this.nop();
                break;
            case "CLV":
                this.nop();
                break;
            case "CPY":
                this.nop();
                break;
            case "CMP":
                this.nop();
                break;
            case "DEC":
                this.nop();
                break;
            case "INY":
                this.nop();
                break;
            case "DEX":
                this.nop();
                break;
            case "BNE":
                this.nop();
                break;
            case "CLD":
                this.nop();
                break;
            case "CPX":
                this.nop();
                break;
            case "SBC":
                this.nop();
                break;
            case "INC":
                this.nop();
                break;
            case "INX":
                this.nop();
                break;
            case "BEQ":
                this.nop();
                break;
            case "SED":
                this.nop();
                break;
            case "KIL":
            case "SLO":
            case "ANC":
            case "RLA":
            case "SRE":
            case "ALR":
            case "RRA":
            case "ARR":
            case "SAX":
            case "XAA":
            case "TAS":
            case "AHX":
            case "LAX":
            case "SHY":
            case "LAS":
            case "SHX":
            case "DCP":
            case "AXS":
            case "ISC":
                // Illegal instruction
                this.illegal();
                break;
            default:
                enforce(false, "Unknown instruction: " ~ instruction.name);
        }
    }

    /**
     * NOP - No operation
     */

     private void nop ( )
     {

     }

     /**
      * Illegal instruction
      */

    private void illegal ( )
    {

    }
}
