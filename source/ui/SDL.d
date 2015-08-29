/**
 * SDL Utilities
 *
 * Wrapper structs and utility functions
 */

module ui.SDL;

import derelict.opengl3.gl; // This module is needed because reload() needs to be called after the context is created
import derelict.sdl2.image;
import derelict.sdl2.mixer;
import derelict.sdl2.sdl;
import derelict.sdl2.ttf;

import std.conv;
import std.string;

/**
 * SDL functions namespace struct wrapper
 */

public struct SDL
{
    /**
     * SDL window wrapper struct
     */

    public struct Window
    {
        /**
         * The SLD_Window pointer
         */

        private SDL_Window* sdl_win;

        /**
         * opCall
         *
         * Params:
         *      sdl_win = If not null, sets sdl_win to this pointer
         *
         * Returns:
         *      The SDL_Window pointer
         */

        public SDL_Window* opCall ( SDL_Window* sdl_win = null )
        {
            if ( sdl_win !is null )
            {
                this.sdl_win = sdl_win;
            }

            return this.sdl_win;
        }

        /**
         * Create an SDL window
         *
         * Does not check if the created window is null or not
         *
         * Params:
         *      name = The name of the window
         *      width = The window width
         *      height = The window height
         *
         * Returns:
         *      The created window wrapped in a struct
         */

        public static Window createWindow ( string name, int width, int height )
        {
            Window result;

            result(SDL_CreateWindow(toStringz(name), 100, 100, width, height, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN));

            return result;
        }

        /**
         * Destroy a given SDL window
         *
         * Params:
         *      win = The SDL window to destroy
         */

        public static void destroyWindow ( Window win )
        {
            SDL_DestroyWindow(win());
        }

        /**
         * Update a given SDL window
         */

        public static void updateWindow ( Window win )
        {
            SDL_UpdateWindowSurface(win());
        }
    }

    /**
     * SDL surface wrapper struct
     */

    public struct Surface
    {
        /**
         * The SLD_Surface pointer
         */

        private SDL_Surface* sdl_surface;

        /**
         * opCall
         *
         * Params:
         *      sdl_surface = If not null, sets sdl_surface to this pointer
         *
         * Returns:
         *      The SDL_Surface pointer
         */

        public SDL_Surface* opCall ( SDL_Surface* sdl_surface = null )
        {
            if ( sdl_surface !is null )
            {
                this.sdl_surface = sdl_surface;
            }

            return this.sdl_surface;
        }

        /**
         * Get the surface of a given SDL window
         *
         * Params:
         *      win = The SDL window
         */

        public static Surface getWindowSurface ( Window win )
        {
            Surface result;

            result(SDL_GetWindowSurface(win()));

            return result;
        }

        /**
         * Create an empty RGBA surface
         *
         * Params:
         *      width = The surface width
         *      height = The surface height
         *
         * Returns:
         *      The created surface
         */

        public static Surface createRGBASurface ( int width, int height )
        {
            Surface result;

            result(SDL_CreateRGBSurface(0, width, height, 32, 0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000));

            return result;
        }

        /**
         * Copy one surface to another
         *
         * Params:
         *      src = The source
         *      dst = The destination
         */

        public static void blitSurface ( Surface src, Surface dst )
        {
            SDL_BlitSurface(src(), null, dst(), null);
        }

        /**
         * Free the given surface
         *
         * Params:
         *      surface = The surface to free
         */

        public static void freeSurface ( Surface surface )
        {
            SDL_FreeSurface(surface());
        }
    }

    /**
     * Color struct
     */

    public struct Color
    {
        /**
         * Color constants
         */

        public static enum RED = Color(0xFF, 0x00, 0x00, 0xFF);
        public static enum GREEN = Color(0x00, 0xFF, 0x00, 0xFF);
        public static enum BLUE = Color(0x00, 0x00, 0xFF, 0xFF);
        public static enum CYAN = Color(0x00, 0xFF, 0xFF, 0xFF);
        public static enum YELLOW = Color(0xFF, 0xFF, 0x00, 0xFF);

        /**
         * Color byte values
         */

        ubyte r;
        ubyte g;
        ubyte b;
        ubyte a;

        /**
         * The SDL_Color
         */

        private SDL_Color sdl_color;

        /**
         * opCall
         *
         * Returns:
         *      The SDL_Color
         */

        public SDL_Color sdlColor ( )
        {
            if ( this.sdl_color == this.sdl_color.init )
            {
                this.sdl_color.r = this.r;
                this.sdl_color.g = this.g;
                this.sdl_color.b = this.b;
                this.sdl_color.a = this.a;
            }

            return this.sdl_color;
        }
    }

    /**
     * SDL event wrapper struct
     */

    public struct Event
    {
        /**
         * SDL event constants
         */

        public static enum QUIT = SDL_QUIT;
        public static enum KEYDOWN = SDL_KEYDOWN;
        public static enum KEYUP = SDL_KEYUP;
        public static enum SCAN_W = SDL_SCANCODE_W;
        public static enum SCAN_A = SDL_SCANCODE_A;
        public static enum SCAN_S = SDL_SCANCODE_S;
        public static enum SCAN_D = SDL_SCANCODE_D;
        public static enum SCAN_M = SDL_SCANCODE_M;
        public static enum SCAN_SPACE = SDL_SCANCODE_SPACE;
        public static enum SCAN_RETURN = SDL_SCANCODE_RETURN;
        public static enum SCAN_TAB = SDL_SCANCODE_TAB;
        public static enum SCAN_LCTRL = SDL_SCANCODE_LCTRL;

        /**
         * The SDL_Event pointer
         */

        private SDL_Event* sdl_event;

        /**
         * opCall
         *
         * Params:
         *      sdl_event = If not null, sets sdl_event to this pointer
         *
         * Returns:
         *      The SDL_Event pointer
         */

        public SDL_Event* opCall ( SDL_Event* sdl_event = null )
        {
            if ( sdl_event !is null )
            {
                this.sdl_event = sdl_event;
            }

            return this.sdl_event;
        }

        /**
         * Get the scancode for this event, as long as this is a keyboard event
         *
         * Returns:
         *      The scancode of this event
         */

        public int getScancode ( )
        in
        {
            bool isKeyType ( )
            {
                return this.sdl_event.type == KEYDOWN ||
                       this.sdl_event.type == KEYUP;
            }

            assert(isKeyType());
        }
        body
        {
            return this.sdl_event.key.keysym.scancode;
        }

        /**
         * Create an SDL event struct
         *
         * Returns:
         *      The created event struct
         */

        public static Event createEvent ( )
        {
            auto sdl_event = new SDL_Event;
            Event result;

            result(sdl_event);

            return result;
        }

        /**
         * Poll the SDL event queue
         *
         * Params:
         *      event = The event to store what is popped from the queue in
         *
         * Returns:
         *      True if there was a pending event, false otherwise
         */

        public static bool pollEvent ( ref Event event )
        {
            if ( SDL_PollEvent(event()) == 0 )
            {
                return false;
            }

            return true;
        }
    }

    /**
     * SDL GL context wrapper struct
     */

    public struct GL
    {
        /**
         * SDL GL constants
         */

        public static enum CONTEXT_MAJOR_VERSION = SDL_GL_CONTEXT_MAJOR_VERSION;
        public static enum CONTEXT_MINOR_VERSION = SDL_GL_CONTEXT_MINOR_VERSION;
        public static enum DOUBLEBUFFER = SDL_GL_DOUBLEBUFFER;
        public static enum DEPTH_SIZE = SDL_GL_DEPTH_SIZE;

        /**
         * SDL_GLContext pointer
         *
         * Static, as there can only be one
         */

        private static SDL_GLContext* sdl_glcontext = null;

        /**
         * opCall
         *
         * Returns:
         *      The SDL_GLContext pointer
         */

        public SDL_GLContext* opCall ( )
        {
            return sdl_glcontext;
        }

        /**
         * Get the SDL GL context
         *
         * Params:
         *      win = The window to create the context from
         *
         * Returns:
         *      The GL context
         */

        public static GL getContext ( Window win )
        {
            if ( sdl_glcontext is null )
            {
                auto ctx = SDL_GL_CreateContext(win());
                sdl_glcontext = &ctx;
                DerelictGL.reload();
            }

            GL result;

            return result;
        }

        /**
         * Delete the SDL GL context
         */

        public static void deleteContext ( )
        in
        {
            assert(sdl_glcontext !is null);
        }
        body
        {
            SDL_GL_DeleteContext(*sdl_glcontext);
        }

        /**
         * Set an SDL GL attribute
         *
         * Params:
         *      attr = The attribute to set
         *      val = The new value
         */

        public static void setAttribute ( int attr, int val )
        {
            SDL_GL_SetAttribute(attr, val);
        }

        /**
         * Set the interval at which to swap window buffers
         *
         * Params:
         *      interval = The interval
         */

        public static void setSwapInterval ( int interval )
        {
            SDL_GL_SetSwapInterval(interval);
        }

        /**
         * Swap the buffers of the given window
         *
         * Params:
         *      win = The window to swap buffers in
         */

        public static void swapWindow ( Window win )
        {
            SDL_GL_SwapWindow(win());
        }
    }

    /**
     * SDL mixer wrapper struct
     */

    public struct Mix
    {
        /**
         * The maximum mixer volume
         */

        public static enum MAX_VOLUME = 128;

        /**
         * SDL Mix_Chunk wrapper struct
         */

        public struct Chunk
        {
            /**
             * The SDL Mix_chunk pointer
             */

            private Mix_Chunk* mix_chunk;

            /**
             * opCall
             *
             * Params:
             *      mix_chunk = If not null, sets mix_chunk to this pointer
             *
             * Returns:
             *      The Mix_Chunk pointer
             */

            public Mix_Chunk* opCall ( Mix_Chunk* mix_chunk = null )
            {
                if ( mix_chunk !is null )
                {
                    this.mix_chunk = mix_chunk;
                }

                return this.mix_chunk;
            }
        }

        /**
         * SDL Mix_Music wrapper struct
         */

        public struct Music
        {
            /**
             * The SDL Mix_chunk pointer
             */

            private Mix_Music* mix_music;

            /**
             * opCall
             *
             * Params:
             *      mix_music = If not null, sets mix_music to this pointer
             *
             * Returns:
             *      The Mix_Music pointer
             */

            public Mix_Music* opCall ( Mix_Music* mix_music = null )
            {
                if ( mix_music !is null )
                {
                    this.mix_music = mix_music;
                }

                return this.mix_music;
            }
        }

        /**
         * Load a WAV file
         *
         * Params:
         *      path = The path to the file
         *
         * Returns:
         *      The Mix.Chunk struct
         */

        public static Chunk loadWAV ( string path )
        {
            Chunk result;

            auto mix_chunk = Mix_LoadWAV(toStringz(path));

            result(mix_chunk);

            return result;
        }

        /**
         * Load a music file
         *
         * Params:
         *      path = The path to the file
         *
         * Returns:
         *      The Mix.Music struct
         */

        public static Music loadMUS ( string path )
        {
            Music result;

            auto mix_music = Mix_LoadMUS(toStringz(path));

            result(mix_music);

            return result;
        }

        /**
         * Play the given chunk
         *
         * Params:
         *      chunk = The chunk to play
         */

        public static void playChannel ( Chunk chunk )
        {
            Mix_PlayChannel(-1, chunk(), 0);
        }

        /**
         * Play the given music
         *
         * Params:
         *      music = The music to play
         */

        public static void playMusic ( Music music )
        {
            Mix_PlayMusic(music(), -1);
        }

        /**
         * Pause the currently playing music
         */

        public static void pauseMusic ( )
        {
            Mix_PauseMusic();
        }

        /**
         * Resume the currently playing music
         */

        public static void resumeMusic ( )
        {
            Mix_ResumeMusic();
        }

        /**
         * Free the given chunk
         *
         * Params:
         *      chunk = The chunk to free
         */

        public static void freeChunk ( Chunk chunk )
        {
            Mix_FreeChunk(chunk());
        }

        /**
         * Free the given music
         *
         * Params:
         *      music = The music to free
         */

        public static void freeMusic ( Music music )
        {
            Mix_FreeMusic(music());
        }

        /**
         * Set the music volume
         *
         * Must be a number between 0 and MAX_VOLUME
         *
         * Params:
         *      volume = The volume
         */

        public static void volumeMusic ( int volume )
        in
        {
            assert(volume >= 0 && volume <= 128);
        }
        body
        {
            Mix_VolumeMusic(volume);
        }

        /**
         * Get the SDL mixer error message
         *
         * Returns:
         *      The SDL mixer error message
         */

        public static string getError ( )
        {
            return cast(string)fromStringz(Mix_GetError());
        }
    }

    /**
     * TTF wrapper struct
     */

    public struct TTF
    {
        /**
         * SDL TTF_Font wrapper struct
         */

        public struct Font
        {
            /**
             * The TTF_Font pointer
             */

            private TTF_Font* ttf_font;

            /**
             * opCall
             *
             * Params:
             *      ttf_font = If not null, sets ttf_font to this pointer
             *
             * Returns:
             *      The TTF_Font pointer
             */

            public TTF_Font* opCall ( TTF_Font* ttf_font = null )
            {
                if ( ttf_font !is null )
                {
                    this.ttf_font = ttf_font;
                }

                return this.ttf_font;
            }
        }

        /**
         * Open a font
         *
         * Params:
         *      path = The path to the font
         *      size = The size of the font
         *
         * Returns:
         *      The opened font
         */

        public static Font openFont ( string path, int size )
        {
            Font result;

            auto ttf_font = TTF_OpenFont(toStringz(path), size);

            result(ttf_font);

            return result;
        }

        /**
         * Close the given font
         *
         * Params:
         *      font = The font to close
         */

        public static void closeFont ( Font font )
        {
            TTF_CloseFont(font());
        }

        /**
         * Render an SDL surface with the given text
         *
         * Params:
         *      font = The font to render with
         *      text = The text to display
         *      color = The text color
         *
         * Returns:
         *      The rendered SDL surface
         */

        public static Surface renderTextBlended ( Font font, string text, Color color )
        {
            Surface result;

            auto sdl_surface = TTF_RenderText_Blended(font(), toStringz(text), color.sdlColor());

            result(sdl_surface);

            return result;
        }
    }

    /**
     * Whether or not SDL/SDL GL has been initialized
     */

    private static bool initialized = false;

    private static bool gl_initialized = false;

    /**
     * Initialize SDL, if it hasn't been already
     *
     * Returns:
     *      True if SDL was successfully initialized
     */

    public static bool init ( )
    {
        if ( !initialized )
        {
            DerelictSDL2.load();
            DerelictSDL2Image.load();
            DerelictSDL2Mixer.load();
            DerelictSDL2ttf.load();
            initialized = Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 2048) == 0;
            initialized &= TTF_Init() == 0;
            return initialized &= SDL_Init(SDL_INIT_VIDEO) == 0;
        }

        return true;
    }

    /**
     * Initialize the SDL OpenGL bindings, if they haven't been already
     *
     * SDL must be initialized first
     *
     * Returns:
     *      True if SDL GL was successfully initialized
     */

    public static bool initGL ( )
    in
    {
        assert(initialized);
    }
    body
    {
        if ( !gl_initialized )
        {
            GL.setAttribute(GL.CONTEXT_MAJOR_VERSION, 3);
            GL.setAttribute(GL.CONTEXT_MINOR_VERSION, 2);
            GL.setAttribute(GL.DOUBLEBUFFER, 1);
            GL.setAttribute(GL.DEPTH_SIZE, 32);
        }

        return true;
    }

    /**
     * Load the image at the given path into an SDL surface
     *
     * Params:
     *      path = The path to the image
     *
     * Returns:
     *      The SDL surface containing the image
     */

    public static Surface imgLoad ( string path )
    {
        Surface result;

        auto sdl_surface = IMG_Load(toStringz(path));

        result(sdl_surface);

        return result;
    }

    /**
     * Get the current keyboard state as a ubyte array
     *
     * Returns:
     *      The keyboard state array pointer
     */

    public static ubyte* getKeyboardState ( )
    {
        return SDL_GetKeyboardState(null);
    }

    /**
     * Get the number of elapsed ticks since SDL was initialized
     *
     * Returns:
     *      The number of ticks
     */

    public static uint getTicks ( )
    {
        return SDL_GetTicks();
    }

    /**
     * Sleep for the given number of ms
     *
     * Params:
     *      ms = The number of ms to sleep for
     */

    public static void delay ( uint ms )
    {
        SDL_Delay(ms);
    }

    /**
     * Quit SDL
     */

    public static void quit ( )
    {
        IMG_Quit();
        Mix_Quit();
        TTF_Quit();
        SDL_Quit();
    }

    /**
     * Get the SDL error string
     */

    public static string error ( )
    {
        return to!string(SDL_GetError());
    }
}
