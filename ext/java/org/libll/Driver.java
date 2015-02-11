package org.libll;

import java.util.ArrayList;
import java.util.ArrayDeque;

import org.libll.DriverConfig;

import org.jruby.Ruby;
import org.jruby.RubyModule;
import org.jruby.RubyClass;
import org.jruby.RubyObject;
import org.jruby.RubyArray;
import org.jruby.RubySymbol;
import org.jruby.RubyFixnum;

import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.Arity;
import org.jruby.runtime.Helpers;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.BlockCallback;
import org.jruby.runtime.Block;
import org.jruby.runtime.CallBlock19;
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

    /**
     * @param runtime The current Ruby runtime.
     * @param klass The Driver class.
     */
    public Driver(Ruby runtime, RubyClass klass)
    {
        super(runtime, klass);

        this.runtime = runtime;
        this.config  = (DriverConfig) klass.getConstant("CONFIG");
    }

    /**
     * The main parsing loop of the driver.
     */
    @JRubyMethod
    public IRubyObject parse(ThreadContext context)
    {
        final ArrayDeque<Long> stack = new ArrayDeque<Long>();
        final ArrayDeque<IRubyObject> value_stack = new ArrayDeque<IRubyObject>();
        final Driver self = this;

        // EOF
        stack.push(this.T_EOF);
        stack.push(this.T_EOF);

        // Start rule
        stack.push(this.T_ACTION);
        stack.push((long) 0);

        stack.push(this.T_RULE);
        stack.push((long) 0);

        BlockCallback callback = new BlockCallback()
        {
            public IRubyObject call(ThreadContext context, IRubyObject[] args, Block block)
            {
                RubyArray token   = (RubyArray) args[0];
                IRubyObject type  = token.entry(0);
                IRubyObject value = token.entry(1);

                while ( true )
                {
                    if ( stack.size() == 0 )
                    {
                        self.callMethod(
                            context,
                            "unexpected_input_error",
                            token
                        );
                    }

                    Long stack_value = stack.pop();
                    Long stack_type  = stack.pop();
                    Long token_id    = 0;

                    if ( self.config.terminals.containsKey(type) )
                    {
                        token_id = self.config.terminals.get(type);
                    }

                    // Rule
                    if ( stack_type == self.T_RULE )
                    {
                        Long production_i = self.config.table
                            .get(stack_value.intValue())
                            .get(token_id.intValue());

                        if ( production_i == self.T_EOF )
                        {
                            IRubyObject[] stack_input_error_args = {
                                RubyFixnum.newFixnum(self.runtime, stack_value),
                                token
                            };

                            self.callMethod(
                                context,
                                "stack_input_error",
                                stack_input_error_args
                            );
                        }
                        else
                        {
                            ArrayList<Long> row = self.config.rules
                                .get(production_i.intValue());

                            for ( int index = 0; index < row.size(); index++ )
                            {
                                stack.push(row.get(index));
                            }
                        }
                    }
                    // Terminal
                    else if ( stack_type == self.T_TERMINAL )
                    {
                        if ( stack_value == token_id )
                        {
                            value_stack.push(value);

                            break;
                        }
                        else
                        {
                            IRubyObject[] invalid_terminal_args = {
                                RubyFixnum.newFixnum(self.runtime, token_id),
                                RubyFixnum.newFixnum(self.runtime, stack_value),
                                token
                            };

                            self.callMethod(
                                context,
                                "invalid_terminal_error",
                                invalid_terminal_args
                            );
                        }
                    }
                    // Action
                    else if ( stack_type == self.T_ACTION )
                    {
                        String method = self.config.action_names
                            .get(stack_value.intValue())
                            .toString();

                        long num_args = (long) self.config.action_arg_amounts
                            .get(stack_value.intValue());

                        RubyArray action_args = self.runtime.newArray();

                        if ( num_args > (long) value_stack.size() )
                        {
                            num_args = (long) value_stack.size();
                        }

                        while ( (num_args--) > 0 )
                        {
                            if ( value_stack.size() > 0 )
                            {
                                action_args.store(num_args, value_stack.pop());
                            }
                        }

                        value_stack.push(
                            self.callMethod(context, method, action_args)
                        );
                    }
                    else if ( stack_type == self.T_EOF )
                    {
                        break;
                    }
                }

                return context.nil;
            }
        };

        Helpers.invoke(
            context,
            this,
            "each_token",
            CallBlock19.newCallClosure(
                this,
                this.metaClass,
                Arity.NO_ARGUMENTS,
                callback,
                context
            )
        );

        if ( value_stack.isEmpty() )
        {
            return context.nil;
        }
        else
        {
            return value_stack.pop();
        }
    }
}
