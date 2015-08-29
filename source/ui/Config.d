/**
 * Game configuration
 */

module ui.Config;

/**
 * Config wrapper
 */

public struct Config
{
    /**
     * The number of frames per second to ambitiously aim for
     */

    public static enum FPS = 75;

    /**
     * Number of ms per frame at the above FPS
     */

    public static enum MS_PER_FRAME = 1000 / FPS;

    /**
     * The path to the log file
     */

    public static enum LOG_FILE = "nesd.log";
}
