/**
 * Wrapper for an std.experimental.logger MultiLogger.
 *
 * Logs to stdout and the configured log file.
 */

module ui.Log;

import std.experimental.logger;
import std.stdio;

/**
 * The game logger, logs to stdout and the configured log file
 */

public class GameLogger : MultiLogger
{
    /**
     * A file logger, using a customized log message format
     */

    private class GameFileLogger : FileLogger
    {
        /**
         * Path constructor
         *
         * Params:
         *      path = The path to the file
         */

        this ( string path )
        {
            super(path);
        }

        /**
         * File constructor
         *
         * Params:
         *      file = The file
         */

        this ( File file )
        {
            super(file);
        }

        /**
         * Override this method for custom log message formatting
         *
         * Params:
         *      payload = The log message data
         */

        override protected void writeLogMsg ( ref LogEntry payload )
        {
            // 2015-08-23 02:19:11 [info] game.SDLApp.SDLApp.run: Initializing game
            enum FORMAT_STR = "%04d-%02d-%02d %02d:%02d:%02d [%s] %s: %s";
            auto t = payload.timestamp;
            this.file.writefln(FORMAT_STR, t.year, t.month, t.day, t.hour, t.minute, t.second,
                payload.logLevel, payload.funcName, payload.msg);
        }
    }

    /**
     * Constructor
     *
     * Params:
     *      path = The path to the log file
     */

    public this ( string path )
    {
        this.insertLogger("stdout", new GameFileLogger(stdout));
        this.insertLogger("logfile", new GameFileLogger(path));
    }
}
