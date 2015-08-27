/**
 * 6502 Instructions
 */

module nesd.cpu.Instructions;

/**
 * Addressing modes
 */

enum AddrMode
{
    Undefined,
    Implied,
    Accumulator,
    Immediate,
    ZeroPage,
    ZeroPageX,
    ZeroPageY,
    Relative,
    Absolute,
    AbsoluteX,
    AbsoluteY,
    Indirect,
    IndirectX,
    IndirectY
}

/**
 * Data about an instruction
 */

struct Instruction
{
    /**
     * The instruction string representation
     */

    immutable string name;

    /**
     * The addressing mode
     */

    AddrMode mode;

    /**
     * The number of bytes this instruction expects
     */

    ubyte size;

    /**
     * The number of cycles this instruction takes
     */

    ubyte cycles;

    /**
     * The number of extra cycles if a page is crossed
     */

    ubyte page_cross_cycles;

    /**
     * Get a human readable string representation of this instruction,
     * with the given operands.
     *
     * TODO: Handle addressing modes.
     *
     * Template params:
     *      T = the operand types
     *
     * Params:
     *      operands = The operands
     *
     * Returns:
     *      The instruction as a human readable string.
     */

    string toPrettyString ( T ... ) ( T operands ... )
    in
    {
        assert(this.size == 0 || T.length == this.size - 1);
    }
    body
    {
        import std.format;

        auto fmt_str = "%s";

        for ( auto _ = 0; _ < T.length; _++ )
        {
            fmt_str ~= " %02x";
        }

        return format(fmt_str, this.name, operands);
    }
}

/**
 * The opcode to instruction map.
 *
 * God help if I ever have to recreate this thing.
 */

enum Instruction[256] OPCODE_TABLE = [
    Instruction("BRK", AddrMode.Implied, 1, 7, 0), // 00 BRK - Force Interrupt
    Instruction("ORA", AddrMode.IndirectX, 2, 6, 0), // 01 ORA - Logical Inclusive OR
    Instruction("KIL", AddrMode.Implied, 0, 2, 0), // 02 KIL - Illegal Instruction
    Instruction("SLO", AddrMode.IndirectX, 0, 8, 0), // 03 SLO - Illegal Instruction
    Instruction("NOP", AddrMode.ZeroPage, 2, 3, 0), // 04 NOP - No Operation
    Instruction("ORA", AddrMode.ZeroPage, 2, 3, 0), // 05 ORA - Logical Inclusive OR
    Instruction("ASL", AddrMode.ZeroPage, 2, 5, 0), // 06 ASL - Arithmetic Shift Left
    Instruction("SLO", AddrMode.ZeroPage, 0, 5, 0), // 07 SLO - Illegal Instruction
    Instruction("PHP", AddrMode.Implied, 1, 3, 0), // 08 PHP - Push Processor Status
    Instruction("ORA", AddrMode.Immediate, 2, 2, 0), // 09 ORA - Logical Inclusive OR
    Instruction("ASL", AddrMode.Accumulator, 1, 2, 0), // 0A ASL - Arithmetic Shift Left
    Instruction("ANC", AddrMode.Immediate, 0, 2, 0), // 0B ANC - Illegal Instruction
    Instruction("NOP", AddrMode.Absolute, 3, 4, 0), // 0C NOP - No Operation
    Instruction("ORA", AddrMode.Absolute, 3, 4, 0), // 0D ORA - Logical Inclusive OR
    Instruction("ASL", AddrMode.Absolute, 3, 6, 0), // 0E ASL - Arithmetic Shift Left
    Instruction("SLO", AddrMode.Absolute, 0, 6, 0), // 0F SLO - Illegal Instruction
    Instruction("BPL", AddrMode.Relative, 2, 2, 1), // 10 BPL - Branch If Positive
    Instruction("ORA", AddrMode.IndirectY, 2, 5, 1), // 11 ORA - Logical Inclusive OR
    Instruction("KIL", AddrMode.Implied, 0, 2, 0), // 12 KIL - Illegal Instruction
    Instruction("SLO", AddrMode.IndirectY, 0, 8, 0), // 13 SLO - Illegal Instruction
    Instruction("NOP", AddrMode.ZeroPageX, 2, 4, 0), // 14 NOP - No Operation
    Instruction("ORA", AddrMode.ZeroPageX, 2, 4, 0), // 15 ORA - Logical Inclusive OR
    Instruction("ASL", AddrMode.ZeroPageX, 2, 6, 0), // 16 ASL - Arithmetic Shift Left
    Instruction("SLO", AddrMode.ZeroPageX, 0, 6, 0), // 17 SLO - Illegal Instruction
    Instruction("CLC", AddrMode.Implied, 1, 2, 0), // 18 CLC - Clear Carry Flag
    Instruction("ORA", AddrMode.AbsoluteY, 3, 4, 1), // 19 ORA - Logical Inclusive OR
    Instruction("NOP", AddrMode.Implied, 1, 2, 0), // 1A NOP - No Operation
    Instruction("SLO", AddrMode.AbsoluteY, 0, 7, 0), // 1B SLO - Illegal Instruction
    Instruction("NOP", AddrMode.AbsoluteX, 3, 4, 1), // 1C NOP - No Operation
    Instruction("ORA", AddrMode.AbsoluteX, 3, 4, 1), // 1D ORA - Logical Inclusive OR
    Instruction("ASL", AddrMode.AbsoluteX, 3, 7, 0), // 1E ASL - Arithmetic Shift Left
    Instruction("SLO", AddrMode.AbsoluteX, 0, 7, 0), // 1F SLO - Illegal Instruction
    Instruction("JSR", AddrMode.Absolute, 3, 6, 0), // 20 JSR - Jump To Subroutine
    Instruction("AND", AddrMode.IndirectX, 2, 6, 0), // 21 AND - Logical AND
    Instruction("KIL", AddrMode.Implied, 0, 2, 0), // 22 KIL - Illegal Instruction
    Instruction("RLA", AddrMode.IndirectX, 0, 8, 0), // 23 RLA - Illegal Instruction
    Instruction("BIT", AddrMode.ZeroPage, 2, 3, 0), // 24 BIT - Bit Test
    Instruction("AND", AddrMode.ZeroPage, 2, 3, 0), // 25 AND - Logical AND
    Instruction("ROL", AddrMode.ZeroPage, 2, 5, 0), // 26 ROL - Rotate Left
    Instruction("RLA", AddrMode.ZeroPage, 0, 5, 0), // 27 RLA - Illegal Instruction
    Instruction("PLP", AddrMode.Implied, 1, 4, 0), // 28 PLP - Pull Processor Status
    Instruction("AND", AddrMode.Immediate, 2, 2, 0), // 29 AND - Logical AND
    Instruction("ROL", AddrMode.Implied, 1, 2, 0), // 2A ROL - Rotate Left
    Instruction("ANC", AddrMode.Immediate, 0, 2, 0), // 2B ANC - Illegal Instruction
    Instruction("BIT", AddrMode.Absolute, 3, 4, 0), // 2C BIT - Bit Test
    Instruction("AND", AddrMode.Absolute, 3, 4, 0), // 2D AND - Logical AND
    Instruction("ROL", AddrMode.Absolute, 3, 6, 0), // 2E ROL - Rotate Left
    Instruction("RLA", AddrMode.Absolute, 0, 6, 0), // 2F RLA - Illegal Instruction
    Instruction("BMI", AddrMode.Relative, 2, 2, 1), // 30 BMI - Branch If Minus
    Instruction("AND", AddrMode.IndirectY, 2, 5, 1), // 31 AND - Logical AND
    Instruction("KIL", AddrMode.Implied, 0, 2, 0), // 32 KIL - Illegal Instruction
    Instruction("RLA", AddrMode.IndirectY, 0, 8, 0), // 33 RLA - Illegal Instruction
    Instruction("NOP", AddrMode.ZeroPageX, 2, 4, 0), // 34 NOP - No Operation
    Instruction("AND", AddrMode.ZeroPageX, 2, 4, 0), // 35 AND - Logical AND
    Instruction("ROL", AddrMode.ZeroPageX, 2, 6, 0), // 36 ROL - Rotate Left
    Instruction("RLA", AddrMode.ZeroPageX, 0, 6, 0), // 37 RLA - Illegal Instruction
    Instruction("SEC", AddrMode.Implied, 1, 2, 0), // 38 SEC - Set Carry Flag
    Instruction("AND", AddrMode.AbsoluteY, 3, 4, 1), // 39 AND - Logical And
    Instruction("NOP", AddrMode.Implied, 1, 2, 0), // 3A NOP - No Operation
    Instruction("RLA", AddrMode.AbsoluteY, 0, 7, 0), // 3B RLA - Illegal Instruction
    Instruction("NOP", AddrMode.AbsoluteX, 3, 4, 1), // 3C NOP - No Operation
    Instruction("AND", AddrMode.AbsoluteX, 3, 4, 1), // 3D AND - Logical AND
    Instruction("ROL", AddrMode.AbsoluteX, 3, 7, 0), // 3E ROL - Rotate Left
    Instruction("RLA", AddrMode.AbsoluteX, 0, 7, 0), // 3F RLA - Illegal Instruction
    Instruction("RTI", AddrMode.Implied, 1, 6, 0), // 40 RTI - Return From Interrupt
    Instruction("EOR", AddrMode.IndirectX, 2, 6, 0), // 41 EOR - Exclusive OR
    Instruction("KIL", AddrMode.Implied, 0, 2, 0), // 42 KIL - Illegal Instruction
    Instruction("SRE", AddrMode.IndirectX, 0, 8, 0), // 43 SRE - Illegal Instruction
    Instruction("NOP", AddrMode.ZeroPage, 2, 3, 0), // 44 NOP - No Operation
    Instruction("EOR", AddrMode.ZeroPage, 2, 3, 0), // 45 EOR - Exclusive OR
    Instruction("LSR", AddrMode.ZeroPage, 2, 5, 0), // 46 LSR - Logical Shift Right
    Instruction("SRE", AddrMode.ZeroPage, 0, 5, 0), // 47 SRE - Illegal Instruction
    Instruction("PHA", AddrMode.Implied, 1, 3, 0), // 48 PHA - Push Accumulator
    Instruction("EOR", AddrMode.Immediate, 2, 2, 0), // 49 EOR - Exclusive OR
    Instruction("LSR", AddrMode.Implied, 1, 2, 0), // 4A LSR - Logical Shift Right
    Instruction("ALR", AddrMode.Immediate, 0, 2, 0), // 4B ALR - Illegal Instruction
    Instruction("JMP", AddrMode.Absolute, 3, 3, 0), // 4C JMP - Jump
    Instruction("EOR", AddrMode.Absolute, 3, 4, 0), // 4D EOR - Exclusive OR
    Instruction("LSR", AddrMode.Absolute, 3, 6, 0), // 4E LSR - Logical Shift Right
    Instruction("SRE", AddrMode.Absolute, 0, 6, 0), // 4F SRE - Illegal Instruction
    Instruction("BVC", AddrMode.Relative, 2, 2, 1), // 50 BVC - Branch If Overflow Clear
    Instruction("EOR", AddrMode.IndirectY, 2, 5, 1), // 51 EOR - Exclusive OR
    Instruction("KIL", AddrMode.Implied, 0, 2, 0), // 52 KIL - Illegal Instruction
    Instruction("SRE", AddrMode.IndirectY, 0, 8, 0), // 53 SRE - Illegal Instruction
    Instruction("NOP", AddrMode.ZeroPageX, 2, 4, 0), // 54 NOP - No Operation
    Instruction("EOR", AddrMode.ZeroPageX, 2, 4, 0), // 55 EOR - Exclusive OR
    Instruction("LSR", AddrMode.ZeroPageX, 2, 6, 0), // 56 LSR - Logical Shift Right
    Instruction("SRE", AddrMode.ZeroPageX, 0, 6, 0), // 57 SRE - Illegal Instruction
    Instruction("CLI", AddrMode.Implied, 1, 2, 0), // 58 CLI - Clear Interrupt Disable
    Instruction("EOR", AddrMode.AbsoluteY, 3, 4, 1), // 59 EOR - Exclusive OR
    Instruction("NOP", AddrMode.Implied, 1, 2, 0), // 5A NOP - No Operation
    Instruction("SRE", AddrMode.AbsoluteY, 0, 7, 0), // 5B SRE - Illegal Instruction
    Instruction("NOP", AddrMode.AbsoluteX, 3, 4, 1), // 5C NOP - No Operation
    Instruction("EOR", AddrMode.AbsoluteX, 3, 4, 1), // 5D EOR - Exclusive OR
    Instruction("LSR", AddrMode.AbsoluteX, 3, 7, 0), // 5E LSR - Logical Shift Right
    Instruction("SRE", AddrMode.AbsoluteX, 0, 7, 0), // 5F SRE - Illegal Instruction
    Instruction("RTS", AddrMode.Implied, 1, 6, 0), // 60 RTS - Return From Subroutine
    Instruction("ADC", AddrMode.IndirectX, 2, 6, 0), // 61 ADC - Add With Carry
    Instruction("KIL", AddrMode.Implied, 0, 2, 0), // 62 KIL - Illegal Instruction
    Instruction("RRA", AddrMode.IndirectX, 0, 8, 0), // 63 RRA - Illegal Instruction
    Instruction("NOP", AddrMode.ZeroPage, 2, 3, 0), // 64 NOP - No Operation
    Instruction("ADC", AddrMode.ZeroPage, 2, 3, 0), // 65 ADC - Add With Carry
    Instruction("ROR", AddrMode.ZeroPage, 2, 5, 0), // 66 ROR - Rotate Right
    Instruction("RRA", AddrMode.ZeroPage, 0, 5, 0), // 67 RRA - Illegal Instruction
    Instruction("PLA", AddrMode.Implied, 1, 4, 0), // 68 PLA - Pull Accumulator
    Instruction("ADC", AddrMode.Immediate, 2, 2, 0), // 69 ADC - Add With Carry
    Instruction("ROR", AddrMode.Implied, 1, 2, 0), // 6A ROR - Rotate Right
    Instruction("ARR", AddrMode.Immediate, 0, 2, 0), // 6B ARR - Illegal Instruction
    Instruction("JMP", AddrMode.Indirect, 3, 5, 0), // 6C JMP - Jump
    Instruction("ADC", AddrMode.Absolute, 3, 4, 0), // 6D ADC - Add With Carry
    Instruction("ROR", AddrMode.Absolute, 3, 6, 0), // 6E ROR - Rotate Right
    Instruction("RRA", AddrMode.Absolute, 0, 6, 0), // 6F RRA - Illegal Instruction
    Instruction("BVS", AddrMode.Relative, 2, 2, 1), // 70 BVS - Branch If Overflow Set
    Instruction("ADC", AddrMode.IndirectY, 2, 5, 1), // 71 ADC - Add With Carry
    Instruction("KIL", AddrMode.Implied, 0, 2, 0), // 72 KIL - Illegal Instruction
    Instruction("RRA", AddrMode.IndirectY, 0, 8, 0), // 73 RRA - Illegal Instruction
    Instruction("NOP", AddrMode.ZeroPageX, 2, 4, 0), // 74 NOP - No Operation
    Instruction("ADC", AddrMode.ZeroPageX, 2, 4, 0), // 75 ADC - Add With Carry
    Instruction("ROR", AddrMode.ZeroPageX, 2, 6, 0), // 76 ROR - Rotate Right
    Instruction("RRA", AddrMode.ZeroPageX, 0, 6, 0), // 77 RRA - Illegal Instruction
    Instruction("SEI", AddrMode.Implied, 1, 2, 0), // 78 SEI - Set Interrupt Disable
    Instruction("ADC", AddrMode.AbsoluteY, 3, 4, 1), // 79 ADC - Add With Carry
    Instruction("NOP", AddrMode.Implied, 1, 2, 0), // 7A NOP - No Operation
    Instruction("RRA", AddrMode.AbsoluteY, 0, 7, 0), // 7B RRA - Illegal Instruction
    Instruction("NOP", AddrMode.AbsoluteX, 3, 4, 1), // 7C NOP - No Operation
    Instruction("ADC", AddrMode.AbsoluteX, 3, 4, 1), // 7D ADC - Add With Carry
    Instruction("ROR", AddrMode.AbsoluteX, 3, 7, 0), // 7E ROR - Rotate RIght
    Instruction("RRA", AddrMode.AbsoluteX, 0, 7, 0), // 7F RRA - Illegal Instruction
    Instruction("NOP", AddrMode.Immediate, 2, 2, 0), // 80 NOP - No Operation
    Instruction("STA", AddrMode.IndirectX, 2, 6, 0), // 81 STA - Store Accumulator
    Instruction("NOP", AddrMode.Immediate, 0, 2, 0), // 82 NOP - No Operation
    Instruction("SAX", AddrMode.IndirectX, 0, 6, 0), // 83 SAX - Illegal Instruction
    Instruction("STY", AddrMode.ZeroPage, 2, 3, 0), // 84 STY - Store Y Register
    Instruction("STA", AddrMode.ZeroPage, 2, 3, 0), // 85 STA - Store Accumulator
    Instruction("STX", AddrMode.ZeroPage, 2, 3, 0), // 86 STX - Store X Register
    Instruction("SAX", AddrMode.ZeroPage, 0, 3, 0), // 87 SAX - Illegal Instruction
    Instruction("DEY", AddrMode.Implied, 1, 2, 0), // 88 DEY - Decrement Y Register
    Instruction("NOP", AddrMode.Immediate, 0, 2, 0), // 89 NOP - No Operation
    Instruction("TXA", AddrMode.Implied, 1, 2, 0), // 8A TXA - Transfer X To Accumulator
    Instruction("XAA", AddrMode.Immediate, 0, 2, 0), // 8B XAA - Illegal Instruction
    Instruction("STY", AddrMode.Absolute, 3, 4, 0), // 8C STY - Store Y Register
    Instruction("STA", AddrMode.Absolute, 3, 4, 0), // 8D STA - Store Accumulator
    Instruction("STX", AddrMode.Absolute, 3, 4, 0), // 8E STX - Store X Register
    Instruction("SAX", AddrMode.Absolute, 0, 4, 0), // 8F SAX - Illegal Instruction
    Instruction("BCC", AddrMode.Relative, 2, 2, 1), // 90 BCC - Branch If Carry Clear
    Instruction("STA", AddrMode.IndirectY, 2, 6, 0), // 91 STA - Store Accumulator
    Instruction("KIL", AddrMode.Implied, 0, 2, 0), // 92 KIL - Illegal Instruction
    Instruction("AHX", AddrMode.IndirectY, 0, 6, 0), // 93 AHX - Illegal Instruction
    Instruction("STY", AddrMode.ZeroPageX, 2, 4, 0), // 94 STY - Store Y Register
    Instruction("STA", AddrMode.ZeroPageX, 2, 4, 0), // 95 STA - Store Accumulator
    Instruction("STX", AddrMode.ZeroPageY, 2, 4, 0), // 96 STX - Store X Register
    Instruction("SAX", AddrMode.ZeroPageY, 0, 4, 0), // 97 SAX - Illegal Instruction
    Instruction("TYA", AddrMode.Implied, 1, 2, 0), // 98 TYA - Transfer Y To Accumulator
    Instruction("STA", AddrMode.AbsoluteY, 3, 5, 0), // 99 STA - Store Accumulator
    Instruction("TXS", AddrMode.Implied, 1, 2, 0), // 9A TXS - Transfer X To Stack Pointer
    Instruction("TAS", AddrMode.AbsoluteY, 0, 5, 0), // 9B TAS - Illegal Instruction
    Instruction("SHY", AddrMode.AbsoluteX, 0, 5, 0), // 9C SHY - Illegal Instruction
    Instruction("STA", AddrMode.AbsoluteX, 3, 5, 0), // 9D STA - Store Accumulator
    Instruction("SHX", AddrMode.AbsoluteY, 0, 5, 0), // 9E SHX - Illegal Instruction
    Instruction("AHX", AddrMode.AbsoluteY, 0, 5, 0), // 9F AHX - Illegal Instruction
    Instruction("LDY", AddrMode.Immediate, 2, 2, 0), // A0 LDY - Load Y Register
    Instruction("LDA", AddrMode.IndirectX, 2, 6, 0), // A1 LDA - Load Accumulator
    Instruction("LDX", AddrMode.Immediate, 2, 2, 0), // A2 LDX - Load X Register
    Instruction("LAX", AddrMode.IndirectX, 0, 6, 0), // A3 LAX - Illegal Instruction
    Instruction("LDY", AddrMode.ZeroPage, 2, 3, 0), // A4 LDY - Load Y Register
    Instruction("LDA", AddrMode.ZeroPage, 2, 3, 0), // A5 LDA - Load Accumulator
    Instruction("LDX", AddrMode.ZeroPage, 2, 3, 0), // A6 LDX - Load X Register
    Instruction("LAX", AddrMode.ZeroPage, 0, 3, 0), // A7 LAX - Illegal Instruction
    Instruction("TAY", AddrMode.Implied, 1, 2, 0), // A8 TAY - Transfer Accumulator To Y
    Instruction("LDA", AddrMode.Immediate, 2, 2, 0), // A9 LDA - Load Accumulator
    Instruction("TAX", AddrMode.Implied, 1, 2, 0), // AA TAX - Transfer Accumulator To X
    Instruction("LAX", AddrMode.Immediate, 0, 2, 0), // AB LAX - Illegal Instruction
    Instruction("LDY", AddrMode.Absolute, 3, 4, 0), // AC LDY - Load Y Register
    Instruction("LDA", AddrMode.Absolute, 3, 4, 0), // AD LDA - Load Accumulator
    Instruction("LDX", AddrMode.Absolute, 3, 4, 0), // AE LDX - Load X Register
    Instruction("LAX", AddrMode.Absolute, 0, 4, 0), // AF LAX - Illegal Instruction
    Instruction("BCS", AddrMode.Relative, 2, 2, 1), // B0 BCS - Branch If Carry Set
    Instruction("LDA", AddrMode.IndirectY, 2, 5, 1), // B1 LDA - Load Accumulator
    Instruction("KIL", AddrMode.Implied, 0, 2, 0), // B2 KIL - Illegal Instruction
    Instruction("LAX", AddrMode.IndirectY, 0, 5, 1), // B3 LAX - Illegal Instruction
    Instruction("LDY", AddrMode.ZeroPageX, 2, 4, 0), // B4 LDY - Load Y Register
    Instruction("LDA", AddrMode.ZeroPageX, 2, 4, 0), // B5 LDA - Load Accumulator
    Instruction("LDX", AddrMode.ZeroPageY, 2, 4, 0), // B6 LDX - Load X Register
    Instruction("LAX", AddrMode.ZeroPageY, 0, 4, 0), // B7 LAX - Illegal Instruction
    Instruction("CLV", AddrMode.Implied, 1, 2, 0), // B8 CLV - Clear Overflow Flag
    Instruction("LDA", AddrMode.AbsoluteY, 3, 4, 1), // B9 LDA - Load Accumulator
    Instruction("TSX", AddrMode.Implied, 1, 2, 0), // BA TSX - Transfer Stack Pointer To X
    Instruction("LAS", AddrMode.AbsoluteY, 0, 4, 1), // BB LAS - Illegal Instruction
    Instruction("LDY", AddrMode.AbsoluteX, 3, 4, 1), // BC LDY - Load Y Register
    Instruction("LDA", AddrMode.AbsoluteX, 3, 4, 1), // BD LDA - Load Accumulator
    Instruction("LDX", AddrMode.AbsoluteY, 3, 4, 1), // BE LDX - Load X Register
    Instruction("LAX", AddrMode.AbsoluteY, 0, 4, 1), // BF LAX - Illegal Instruction
    Instruction("CPY", AddrMode.Immediate, 2, 2, 0), // C0 CPY - Compare Y Register
    Instruction("CMP", AddrMode.IndirectX, 2, 6, 0), // C1 CMP - Compare
    Instruction("NOP", AddrMode.Immediate, 0, 2, 0), // C2 NOP - No Operation
    Instruction("DCP", AddrMode.IndirectX, 0, 8, 0), // C3 DCP - Illegal Instruction
    Instruction("CPY", AddrMode.ZeroPage, 2, 3, 0), // C4 CPY - Compare Y Register
    Instruction("CMP", AddrMode.ZeroPage, 2, 3, 0), // C5 CMP - Compare
    Instruction("DEC", AddrMode.ZeroPage, 2, 5, 0), // C6 DEC - Decrement Memory
    Instruction("DCP", AddrMode.ZeroPage, 0, 5, 0), // C7 DCP - Illegal Instruction
    Instruction("INY", AddrMode.Implied, 1, 2, 0), // C8 INY - Increment Y Register
    Instruction("CMP", AddrMode.Immediate, 2, 2, 0), // C9 CMP - Compare
    Instruction("DEX", AddrMode.Implied, 1, 2, 0), // CA DEX - Decrement X Register
    Instruction("AXS", AddrMode.Immediate, 0, 2, 0), // CB AXS - Illegal Instruction
    Instruction("CPY", AddrMode.Absolute, 3, 4, 0), // CC CPY - Compare Y Register
    Instruction("CMP", AddrMode.Absolute, 3, 4, 0), // CD CMP - Compare
    Instruction("DEC", AddrMode.Absolute, 3, 6, 0), // CE DEC - Decrement Memory
    Instruction("DCP", AddrMode.Absolute, 0, 6, 0), // CF DCP - Illegal Instruction
    Instruction("BNE", AddrMode.Relative, 2, 2, 1), // D0 BNE - Branch If Not Equal
    Instruction("CMP", AddrMode.IndirectY, 2, 5, 1), // D1 CMP - Compare
    Instruction("KIL", AddrMode.Implied, 0, 2, 0), // D2 KIL - Illegal Instruction
    Instruction("DCP", AddrMode.IndirectY, 0, 8, 0), // D3 DCP - Illegal Instruction
    Instruction("NOP", AddrMode.ZeroPageX, 2, 4, 0), // D4 NOP - No Operation
    Instruction("CMP", AddrMode.ZeroPageX, 2, 4, 0), // D5 CMP - Compare
    Instruction("DEC", AddrMode.ZeroPageX, 2, 6, 0), // D6 DEC - Decrement Memory
    Instruction("DCP", AddrMode.ZeroPageX, 0, 6, 0), // D7 DCP - Illegal Instruction
    Instruction("CLD", AddrMode.Implied, 1, 2, 0), // D8 CLD - Clear Decimal Mode
    Instruction("CMP", AddrMode.AbsoluteY, 3, 4, 1), // D9 CMP - Compare
    Instruction("NOP", AddrMode.Implied, 1, 2, 0), // DA NOP - No Operation
    Instruction("DCP", AddrMode.AbsoluteY, 0, 7, 0), // DB DCP - Illegal Instruction
    Instruction("NOP", AddrMode.AbsoluteX, 3, 4, 1), // DC NOP - No Operation
    Instruction("CMP", AddrMode.AbsoluteX, 3, 4, 1), // DD CMP - Compare
    Instruction("DEC", AddrMode.AbsoluteX, 3, 7, 0), // DE DEC - Decrement Memory
    Instruction("DCP", AddrMode.AbsoluteX, 0, 7, 0), // DF DCP - Illegal Instruction
    Instruction("CPX", AddrMode.Immediate, 2, 2, 0), // E0 CPX - Compare X Register
    Instruction("SBC", AddrMode.IndirectX, 2, 6, 0), // E1 SBC - Subtract With Carry
    Instruction("NOP", AddrMode.Immediate, 0, 2, 0), // E2 NOP - No Operation
    Instruction("ISC", AddrMode.IndirectX, 0, 8, 0), // E3 ISC - Illegal Instruction
    Instruction("CPX", AddrMode.ZeroPage, 2, 3, 0), // E4 CPX - Compare X Register
    Instruction("SBC", AddrMode.ZeroPage, 2, 3, 0), // E5 SBC - Subtract With Carry
    Instruction("INC", AddrMode.ZeroPage, 2, 5, 0), // E6 INC - Increment Memory
    Instruction("ISC", AddrMode.ZeroPage, 0, 5, 0), // E7 ISC - Illegal Instruction
    Instruction("INX", AddrMode.Implied, 1, 2, 0), // E8 INX - Increnemt X Register
    Instruction("SBC", AddrMode.Immediate, 2, 2, 0), // E9 SBC - Subtract With Carry
    Instruction("NOP", AddrMode.Implied, 1, 2, 0), // EA NOP - No Operation
    Instruction("SBC", AddrMode.Immediate, 0, 2, 0), // EB SBC - Subtract With Carry
    Instruction("CPX", AddrMode.Absolute, 3, 4, 0), // EC CPX - Compare X Register
    Instruction("SBC", AddrMode.Absolute, 3, 4, 0), // ED SBC - Subtract With Carry
    Instruction("INC", AddrMode.Absolute, 3, 6, 0), // EE INC - Increment Memory
    Instruction("ISC", AddrMode.Absolute, 0, 6, 0), // EF ISC - Illegal Instruction
    Instruction("BEQ", AddrMode.Relative, 2, 2, 1), // F0 BEQ - Branch If Equal
    Instruction("SBC", AddrMode.IndirectY, 2, 5, 1), // F1 SBC - Subtract With Carry
    Instruction("KIL", AddrMode.Implied, 0, 2, 0), // F2 KIL - Illegal Instruction
    Instruction("ISC", AddrMode.IndirectY, 0, 8, 0), // F3 ISC - Illegal Instruction
    Instruction("NOP", AddrMode.ZeroPageX, 2, 4, 0), // F4 NOP - No Operation
    Instruction("SBC", AddrMode.ZeroPageX, 2, 4, 0), // F5 SBC - Subtract With Carry
    Instruction("INC", AddrMode.ZeroPageX, 2, 6, 0), // F6 INC - Increment Memory
    Instruction("ISC", AddrMode.ZeroPageX, 0, 6, 0), // F7 ISC - Illegal Instruction
    Instruction("SED", AddrMode.Implied, 1, 2, 0), // F8 SED - Set Decimal Flag
    Instruction("SBC", AddrMode.AbsoluteY, 2, 4, 1), // F9 SBC - Subtract With Carry
    Instruction("NOP", AddrMode.Implied, 1, 2, 0), // FA NOP - No Operation
    Instruction("ISC", AddrMode.AbsoluteY, 0, 7, 0), // FB ISC - Illegal Instruction
    Instruction("NOP", AddrMode.AbsoluteX, 3, 4, 1), // FC NOP - No Operation
    Instruction("SBC", AddrMode.AbsoluteX, 3, 4, 1), // FD SBC - Subtract With Carry
    Instruction("INC", AddrMode.AbsoluteX, 3, 7, 0), // FE INC - Increment Memory
    Instruction("ISC", AddrMode.AbsoluteX, 0, 7, 0)  // FF ISC - Illegal Instruction
];
