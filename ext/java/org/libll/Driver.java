package org.libll;

import java.util.ArrayList;
import java.util.ArrayDeque;

import org.libll.DriverConfig;

import org.jruby.Ruby;
import org.jruby.RubyModule;
import org.jruby.RubyClass;
import org.jruby.RubyObject;
import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.builtin.IRubyObject;

@JRubyClass(name="LL::Driver", parent="Object")
public class Driver extends RubyObject
{
    private static long T_EOF      = -1;
    private static long T_RULE     = 0;
    private static long T_TERMINAL = 1;
    private static long T_EPSILON  = 2;
    private static long T_ACTION   = 3;

    /**
     * The current Ruby runtime.
     */
    private Ruby runtime;

    /**
     * The driver configuration.
     */
    private DriverConfig config;

    /**
     * Stack for storing the rules/actions/etc to process.
     */
    private ArrayDeque<Long> stack = new ArrayDeque<Long>();

    /**
     * Stack for storing action return values.
     */
    private ArrayDeque<IRubyObject> value_stack = new ArrayDeque<IRubyObject>();

    /**
     * Sets up the class in the Ruby runtime.
     */
    public static void load(Ruby runtime)
    {
        RubyModule ll = (RubyModule) runtime.getModule("LL");

        RubyClass driver = ll.defineClassUnder(
            "Driver",
            runtime.getObject(),
            ALLOCATOR
        );

        driver.defineAnnotatedMethods(Driver.class);
    }

    private static final ObjectAllocator ALLOCATOR = new ObjectAllocator()
    {
        public IRubyObject allocate(Ruby runtime, RubyClass klass)
        {
            return new org.libll.Driver(runtime, klass);
        }
    };

    public Driver(Ruby runtime, RubyClass klass)
    {
        super(runtime, klass);

        this.runtime = runtime;
        this.config  = (DriverConfig) klass.getConstant("CONFIG");
    }

    /**
     * The main parsing loop of a driver.
     */
    @JRubyMethod
    public IRubyObject parse(ThreadContext context)
    {
        // EOF
        this.stack.add(this.T_EOF);
        this.stack.add(this.T_EOF);

        // Start rule
        this.stack.add(this.T_RULE);
        this.stack.add(this.T_RULE);

        if ( this.value_stack.isEmpty() )
        {
            return context.nil;
        }
        else
        {
            return this.value_stack.pop();
        }
    }
}
