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
     */

    ubyte[0x0008] ppu_reg;

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
        this.ram[] = rom.chr_rom[0 .. this.ram.sizeof];
        this.magic[0x8000 - 0x4020 .. $] = rom.prg_rom[0 .. 0xffff - 0x7fff];
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
     * Write a value to the given address
     *
     * Params:
     *      addr = The address
     *      val = The value
     */

    void write ( Address addr, ubyte val )
    {
        *(this.access(addr)) = val;
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
     * Params:
     *      addr = The address
     *
     * Returns:
     *      A pointer to the value at the given address
     */

    private ubyte* access ( Address addr )
    out ( ptr )
    {
        assert(ptr !is null);
    }
    body
    {
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
        else if ( addr <= 0x3fff )
        {
            ptr = &this.ppu_reg[addr % this.ppu_reg.sizeof];
        }
        // $4000-$401F  $0020   NES APU and I/O registers
        else if ( addr <= 0x401f )
        {
            ptr = &this.apu_reg[addr % this.apu_reg.sizeof];
        }
        // $4020-$FFFF  $BFE0   Cartridge space: PRG ROM, PRG RAM, and mapper registers (See Note)
        else
        {
            ptr = &this.magic[addr - 0x4020];
        }

        return ptr;
    }
}
