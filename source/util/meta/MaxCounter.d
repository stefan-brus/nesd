/**
 * Wrapper struct for a counter that wraps around at a given maximum value
 */

module util.meta.MaxCounter;

import std.traits;

/**
 * MaxCounter template
 *
 * Template params:
 *      T = The numerical type
 *      max = The maximum number
 */

struct MaxCounter ( T, T max )
{
    static assert(isNumeric!T, "MaxCounter only works with numeric types");

    /**
     * The counter value and this alias
     */

    T counter;

    alias counter this;

    /**
     * Increment operator
     *
     * Template params:
     *      op = The operator
     *
     * Returns:
     *      The counter value
     */

    T opUnary ( string op ) ( ) if ( op == "++" )
    {
        if ( this >= max )
        {
            this = 0;
        }
        else
        {
            this += 1;
        }

        return this;
    }

    /**
     * Invariant, makes sure that the counter is never above max
     */

    invariant
    {
        assert(this <= max, "MaxCounter out of bounds");
    }
}
