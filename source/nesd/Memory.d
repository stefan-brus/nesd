/**
 * The memory module.
 *
 * Based on these specifications:
 * http://wiki.nesdev.com/w/index.php/CPU_memory_map
 */

module nesd.Memory;

import nesd.INES;

/**
 * Memory struct
 */

struct Memory
{
    /**
     * A memory address is 16 bits
     */

    alias Address = ushort;

    static assert(Address.sizeof == 2);

    /**
     * $0000-$07FF  $0800   2KB internal RAM
     */

    ubyte[0x0800] ram;

    /**
     * $2000-$2007  $0008   NES PPU registers
     *
     * Initialized as a pointer array to write directly to the PPU.
     * Expected to be initialized by the PPU module.
     * A delegate is called when these addresses are read or written.
     */

    ubyte*[0x0008] ppu_reg;

    alias PPURegDg = void delegate ( Address );
    PPURegDg ppu_read_dg;
    PPURegDg ppu_write_dg;

    /**
     * $4000-$401F  $0020   NES APU and I/O registers
     */

    ubyte[0x0020] apu_reg;

    /**
     * $4020-$FFFF  $BFE0   Cartridge space: PRG ROM, PRG RAM, and mapper registers
     *
     * TODO: Implement mappers and rename this
     */

    ubyte[0xbfe0] magic;

    /**
     * Constructor
     *
     * Params:
     *      rom = The iNES rom file to initialize the memory from
     */

    this ( iNESFile rom )
    {
        import std.exception;

        this.ram[] = rom.chr_rom[0 .. this.ram.sizeof];

        if ( rom.header.prg_size == 2 )
        {
            this.magic[0x8000 - 0x4020 .. $] = rom.prg_rom[];
        }
        else if ( rom.header.prg_size == 1 )
        {
            this.magic[0xc000 - 0x4020 .. $] = rom.prg_rom[];
        }
        else
        {
            enforce(false, "Unhandled PRG ROM size");
        }
    }

    /**
     * Read the value at the given address
     *
     * Params:
     *      addr = The address
     *
     * Returns:
     *      The value at the address
     */

    ubyte read ( Address addr )
    {
        return *(this.access(addr));
    }

    /**
     * Read a word (2 bytes) starting from the given address.
     *
     * Little endianness is used so the low byte is stored first.
     *
     * Params:
     *      addr = The address
     *
     * Returns:
     *      The two bytes at the address, and the one after it
     */

    ushort readw ( Address addr )
    {
        ubyte lo = *(this.access(addr));
        ubyte hi = *(this.access(cast(Address)(addr + 1)));

        return (hi << 8) | lo;
    }

    /**
     * Write a value to the given address
     *
     * Params:
     *      addr = The address
     *      val = The value
     */

    void write ( Address addr, ubyte val )
    {
        *(this.access!false(addr)) = val;
    }

    /**
     * Check if two addresses are on the same page
     *
     * Params:
     *      addr1 = The first address
     *      addr2 = The second address
     *
     * Returns:
     *      True if they are on the same page, false otherwise
     */

    static bool samePage ( Address addr1, Address addr2 )
    {
        return (addr1 & 0xff00) == (addr2 & 0xff00);
    }

    /**
     * Get a pointer to the value at the given address.
     *
     * Addresses sometimes mirror other parts of the memory, and these are
     * accessed according to the specification in the NESdev wiki.
     *
     * Template params:
     *      read = Whether or not this is a read
     *
     * Params:
     *      addr = The address
     *
     * Returns:
     *      A pointer to the value at the given address
     */

    private ubyte* access ( bool read = true ) ( Address addr )
    out ( ptr )
    {
        assert(ptr !is null);
    }
    body
    {
        import std.exception;

        ubyte* ptr;

        // $0000-$07FF  $0800   2KB internal RAM
        if ( addr <= 0x07ff )
        {
            ptr = &this.ram[addr];
        }
        // $0800-$0FFF  $0800   Mirrors of $0000-$07FF
        // $1000-$17FF  $0800   Mirrors of $0000-$07FF
        // $1800-$1FFF  $0800   Mirrors of $0000-$07FF
        else if ( addr <= 0x1fff )
        {
            ptr = &this.ram[addr % this.ram.sizeof];
        }
        // $2000-$2007  $0008   NES PPU registers
        // $2008-$3FFF  $1FF8   Mirrors of $2000-2007 (repeats every 8 bytes)
        // NB: PPU register pointers must be initialized at this point
        else if ( addr <= 0x3fff )
        {
            auto idx = addr % this.ppu_reg.sizeof;
            assert(this.ppu_reg[idx] !is null, "PPU registers not initialized");

            static if ( read )
            {
                assert(this.ppu_read_dg !is null, "PPU read delegate not initialized");
                this.ppu_read_dg(addr);
            }
            else
            {
                assert(this.ppu_write_dg !is null, "PPU write delegate not initialized");
                this.ppu_write_dg(addr);
            }

            ptr = this.ppu_reg[idx];
        }
        // $4000-$401F  $0020   NES APU and I/O registers
        else if ( addr <= 0x401f )
        {
            ptr = &this.apu_reg[addr % this.apu_reg.sizeof];
        }
        // $4020-$FFFF  $BFE0   Cartridge space: PRG ROM, PRG RAM, and mapper registers
        else
        {
            ptr = &this.magic[addr - 0x4020];
        }

        return ptr;
    }
}
