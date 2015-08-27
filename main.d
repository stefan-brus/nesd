/**
 * Highly experimental NES emulator
 */

module main;

import nesd.Console;
import nesd.INES;

import std.exception;
import std.file;
import std.stdio;

void main ( string[] args )
{
    enforce(args.length == 2, "Argument 'file' missing");

    immutable ubyte[] ines = cast(immutable ubyte[])read(args[1]);

    auto rom_file = iNESFile(ines);

    writefln("ROM file loaded");
    writefln("Header:");
    writefln("%s", rom_file.header.toPrettyString());
    writefln("Starting CPU");

    auto console = Console(rom_file);

    writefln("Stepping through program ROM");
    console.start();
}
