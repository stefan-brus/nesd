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
     * Convenience alias
     */

    alias Address = Memory.Address;

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

    Address pc;

    /**
     * The stack pointer
     */

    ubyte sp;

    /**
     * The number of clock cycles that have passed
     */

    ulong cycles;

    /**
     * The processor flags
     *
     * Template params:
     *      bitmask = The bitmask to compare against the processor flags
     */

    private ubyte flags_;

    template flags ( ubyte bitmask )
    {
        @property
        {
            ubyte flags ( )
            {
                return this.flags_ & bitmask;
            }

            ubyte flags ( bool val )
            {
                if ( val )
                {
                    this.flags_ |= bitmask;
                }
                else
                {
                    this.flags_ &= ~bitmask;
                }

                return this.flags_ & bitmask;
            }
        }
    }

    alias c = flags!0x01;
    alias z = flags!0x02;
    alias i = flags!0x04;
    alias d = flags!0x08;
    alias b = flags!0x10;
    alias u = flags!0x20;
    alias v = flags!0x40;
    alias n = flags!0x80;

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
        this.sp = 0xff;
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
        assert(this.pc < Address.max);
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
            enforce(this.pc < Address.max, "Instruction requires more operands than program size: " ~ instruction.name);
            operands ~= this.memory.read(this.pc);
            this.pc++;
        }

        this.cycles += instruction.cycles;

        this.runInstruction(instruction, operands);

        writefln("cycles: %d PC: %04x SP: %02x", this.cycles, this.pc, this.sp);

        return this.pc < Address.max;
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
        assert(this.pc < Address.max);
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
            enforce(this.pc < Address.max, "Instruction requires more operands than program size: " ~ instruction.name);
            operands ~= this.memory.read(this.pc);
            this.pc++;
        }

        writefln("%s", instruction.toPrettyString(operands));

        return this.pc < Address.max;
    }

    /**
     * Push a value onto the stack.
     *
     * Memory addresses 0x0100 to 0x01ff are reserved for the stack.
     *
     * Params:
     *      val = The value
     */

    private void push ( ubyte val )
    {
        this.memory.write(0x0100 + this.sp, val);

        this.sp--;
    }

    /**
     * Push a word (2 bytes) onto the stack.
     * Memory addresses 0x0100 to 0x01ff are reserved for the stack.
     *
     * Params:
     *      val = The value
     */

    private void pushw ( ushort val )
    {
        ubyte hi = val >> 8,
              lo = cast(ubyte)val;

        this.push(hi);
        this.push(lo);
    }

    /**
     * Pop a value from the stack.
     *
     * Memory addresses 0x0100 to 0x01ff are reserved for the stack.
     *
     * Returns:
     *      The value on top of the stack
     */

    private ubyte pop ( ubyte val )
    {
        this.sp++;

        return this.memory.read(0x0100 + this.sp);
    }

    /**
     * Add to the cycle counter when branching.
     *
     * Add an extra cycle if the branch goes out of page.
     *
     * Params:
     *      addr = The address to branch to
     */

    private void addBranchCycles ( Address addr )
    {
        this.cycles++;

        if ( !Memory.samePage(addr, this.pc) )
        {
            this.cycles++;
        }
    }

    /**
     * Run a given instruction
     *
     * Params:
     *      instruction = The instruction
     *      operands = The operands
     */

    private void runInstruction ( Instruction instruction, ubyte[] operands )
    {
        import std.exception;

        Address addr;

        // Fetch the address for the instruction's addressing mode
        with ( AddrMode ) final switch ( instruction.mode )
        {
            case Undefined:
                enforce(false, "Undefined addressing mode");
                break;
            case Implied:
                break;
            case Accumulator:
                break;
            case Immediate:
                break;
            case ZeroPage:
                break;
            case ZeroPageX:
                break;
            case ZeroPageY:
                break;
            case Relative:
                enforce(operands.length > 0, "Relative addressing mode requires at least 1 operand");

                auto offset = cast(Address)operands[0];

                addr += this.pc;
                addr += offset;
                addr++;

                if ( offset > 0x7f )
                {
                    addr -= 0x100;
                }
                break;
            case Absolute:
                enforce(operands.length > 1, "Absolute addressing mode requires at least 2 operands");

                addr += operands[0];
                addr += operands[1] << 8;
                break;
            case AbsoluteX:
                break;
            case AbsoluteY:
                break;
            case Indirect:
                break;
            case IndirectX:
                break;
            case IndirectY:
                break;
        }

        // Evaluate the instructon
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
                this.php();
                break;
            case "BPL":
                this.bpl(addr);
                break;
            case "CLC":
                this.clc();
                break;
            case "JSR":
                this.jsr(addr);
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
     * JSR - Jump To Subroutine
     *
     * Params:
     *      addr = The address
     */

    private void jsr ( Address addr )
    {
        this.pushw(cast(ushort)(this.pc - 1));
        this.pc = addr;
    }

    /**
     * CLC - Clear Carry Flag
     */

    private void clc ( )
    {
        this.c = false;
    }

    /**
     * BPL - Branch If Positive
     *
     * Params:
     *      addr = The address
     */

    private void bpl ( Address address )
    {
        if ( this.n == 0 )
        {
            this.addBranchCycles(address);
            this.pc = address;
        }
    }

    /**
     * PHP - Push Processor Status
     */

    private void php ( )
    {
        this.push(this.b);
    }

    /**
     * NOP - No Operation
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
