/**
 * Struct representing an iNES ROM file.
 */

module nesd.INES;

/**
 * An iNES ROM file.
 *
 * TODO: Some ROMs contain 512 bytes of "trainer" code before the program ROM.
 * TODO: Everything after CHR ROM
 *
 * iNES file format (from NESdev wiki):
 * Header (16 bytes)
 * Trainer, if present (0 or 512 bytes)
 * PRG ROM data (16384 * x bytes)
 * CHR ROM data, if present (8192 * y bytes)
 * PlayChoice INST-ROM, if present (0 or 8192 bytes)
 * PlayChoice PROM, if present (16 bytes Data, 16 bytes CounterOut) (this is often missing, see PC10 ROM-Images for details)
 * Some ROM-Images additionally contain a 128-byte (or sometimes 127-byte) title at the end of the file.
 */

struct iNESFile
{
    /**
     * The 16-byte iNES header
     */

    immutable iNESHeader header;

    // Trainer should probably go here

    /**
     * The PRG ROM
     */

    enum PRG_ROM_BLOCK_SIZE = 16384;

    immutable ubyte[] prg_rom;

    /**
     * The CHR ROM
     */

    enum CHR_ROM_BLOC_SIZE = 8192;

    immutable ubyte[] chr_rom;

    /**
     * Struct initializer.
     *
     * Allocates prg_rom and chr_rom according to the number of
     * specified blocks in the header.
     *
     * Params:
     *      ines = The raw iNES ROM file
     */

    this ( immutable ubyte[] ines )
    {
        import std.exception;

        this.header = *(cast(iNESHeader*)ines[0 .. iNESHeader.sizeof].ptr);
        enforce(this.header.validate(), "iNES header is invalid");

        auto prg_rom_size = this.header.prg_size * PRG_ROM_BLOCK_SIZE,
             chr_rom_size = this.header.chr_size * CHR_ROM_BLOC_SIZE;

        enforce(ines.length >= this.header.sizeof + prg_rom_size + chr_rom_size,
            "iNES file is smaller than header describes");

        auto prg_rom_offset = this.header.sizeof,
             chr_rom_offset = prg_rom_offset + prg_rom_size,
             end_offset = chr_rom_offset + chr_rom_size;

        this.prg_rom = ines[prg_rom_offset .. chr_rom_offset];
        this.chr_rom = ines[chr_rom_offset .. end_offset];
    }
}

/**
 * The header of an iNES ROM file.
 *
 * Byte format (from NESdev wiki):
 * 0-3: Constant $4E $45 $53 $1A ("NES" followed by MS-DOS end-of-file)
 * 4: Size of PRG ROM in 16 KB units
 * 5: Size of CHR ROM in 8 KB units (Value 0 means the board uses CHR RAM)
 * 6: Flags 6
 * 7: Flags 7
 * 8: Size of PRG RAM in 8 KB units (Value 0 infers 8 KB for compatibility; see PRG RAM circuit)
 * 9: Flags 9
 * 10: Flags 10 (unofficial)
 * 11-15: Zero filled
 */

struct iNESHeader
{
    enum iNES_CONSTANT = 0x1a53454e;

    uint ines_const;
    ubyte prg_size;
    ubyte chr_size;
    ubyte flags6;
    ubyte flags7;
    ubyte prg_size_8kb;
    ubyte flags9;
    ubyte flags10;
    ubyte[5] zero;

    /**
     * Validate this header.
     *
     * Returns:
     *      True if the header is valid, false otherwise.
     */

    immutable bool validate ( )
    {
        auto result = true;

        result &= this.ines_const == iNES_CONSTANT;
        result &= this.zero == [0, 0, 0, 0, 0];

        return result;
    }

    /**
     * Turn this header into a printable string.
     *
     * Returns:
     *      This header as a human readable string.
     */

    immutable string toPrettyString ( )
    {
        import std.format;

        string result;

        result ~= format("INES CONSTANT: %x\n", this.ines_const);
        result ~= format("PRG SIZE:      %d\n", this.prg_size);
        result ~= format("CHR SIZE:      %d\n", this.chr_size);
        result ~= format("FLAGS6:        %08b\n", this.flags6);
        result ~= format("FLAGS7:        %08b\n", this.flags7);
        result ~= format("PRG SIZE 8KB:  %d\n", this.prg_size_8kb);
        result ~= format("FLAGS9:        %08b\n", this.flags9);
        result ~= format("FLAGS10:       %08b\n", this.flags10);
        result ~= format("ZERO PADDING:  %s", this.zero);

        return result;
    }
}
