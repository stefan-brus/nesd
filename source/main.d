/**
 * Highly experimental NES emulator
 */

module main;

import nesd.Console;
import nesd.INES;

import ui.NESGame;
import ui.SDLApp;

import std.exception;
import std.file;
import std.stdio;

int main ( string[] args )
{
    enforce(args.length == 2, "Argument 'file' missing");

    immutable ubyte[] ines = cast(immutable ubyte[])read(args[1]);

    auto rom_file = iNESFile(ines);

    writefln("ROM file loaded");
    writefln("Header:");
    writefln("%s", rom_file.header.toPrettyString());
    writefln("Starting CPU");

    auto console = Console(rom_file);

    auto game = new NESGame(&console);
    auto app = new SDLApp("NESD", 256, 240, game);

    return app.run();
}
