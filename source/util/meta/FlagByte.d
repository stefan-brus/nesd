/**
 * A convenient way to store and access 1-8 flags in a single byte
 */

module util.meta.FlagByte;

import std.traits;

/**
 * FlagByte template
 *
 * Template params:
 *      Byte = The byte to use as storage
 *      names = The name aliases of the bit flags
 *      bitmasks = The bitmasks to access the aliases
 */

template FlagByte ( alias Byte, string[] names, ubyte[] bitmasks )
{
    import std.format;

    static assert(is(typeof(Byte) == ubyte), "A flag byte must be stored in an actual byte");
    static assert(names.length >= 1 && bitmasks.length >= 1, "A byte flag filed must have at least one flag");
    static assert(names.length <= 8 && bitmasks.length <= 8, "A byte can only have 8 flags");
    static assert(names.length == bitmasks.length, "A flagbyte must have the same amount of names as bitmasks");

    template flags ( ubyte bitmask )
    {
        @property
        {
            ubyte flags ( )
            {
                return Byte & bitmask;
            }

            ubyte flags ( bool val )
            {
                if ( val )
                {
                    Byte |= bitmask;
                }
                else
                {
                    Byte &= ~bitmask;
                }

                return Byte & bitmask;
            }
        }
    }

    mixin(format("alias %s = flags!0x%02x;", names[0], bitmasks[0]));

    static if ( names.length > 1 && bitmasks.length > 1 )
    {
        mixin FlagByte!(Byte, names[1 .. $], bitmasks[1 .. $]);
    }
}
