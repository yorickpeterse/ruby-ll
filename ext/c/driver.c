#include "driver.h"

#define T_EOF -1
#define T_RULE 0
#define T_TERMINAL 1
#define T_EPSILON 2
#define T_ACTION 3

ID id_config_const;
ID id_each_token;
ID id_send;

ID id_missing_rule_error;
ID id_invalid_token_error;

void ll_driver_free(DriverState *state)
{
    vec_deinit(&state->stack);
    vec_deinit(&state->value_stack);

    free(state);
}

void ll_driver_mark(DriverState *state)
{
    int index;
    VALUE value;

    vec_foreach(&state->value_stack, value, index)
    {
        rb_gc_mark(value);
    }
}

VALUE ll_driver_allocate(VALUE klass)
{
    DriverState *state = ALLOC(DriverState);

    state->config = ll_driver_config_get_struct(
        rb_const_get(klass, id_config_const)
    );

    vec_init(&state->stack);
    vec_init(&state->value_stack);

    return Data_Wrap_Struct(klass, ll_driver_mark, ll_driver_free, state);
}

VALUE ll_driver_each_token(VALUE token, VALUE self)
{
    VALUE method;
    VALUE action_args;
    long num_args;
    long args_i;

    long token_id_value;
    long token_id;

    long rule_i;
    long production_i;

    long stack_type;
    long stack_value;

    DriverState *state;

    VALUE type  = rb_ary_entry(token, 0);
    VALUE value = rb_ary_entry(token, 1);

    Data_Get_Struct(self, DriverState, state);

    while ( 1 )
    {
        stack_value    = vec_pop(&state->stack);
        stack_type     = vec_pop(&state->stack);
        token_id_value = -1;
        token_id       = -1;

        {
            khint64_t found = kh_get(int64_map, state->config->tokens, type);

            if ( found != kh_end(state->config->tokens) )
            {
                token_id_value = kh_value(state->config->tokens, found);
            }
        }

        if ( token_id_value == -1 )
        {
            token_id = T_EOF;
        }
        else
        {
            token_id = token_id_value;
        }

        /* Rule */
        if ( stack_type == T_RULE )
        {
            production_i = state->config->table[stack_value][token_id];

            if ( production_i == T_EOF )
            {
                rb_funcall(self, id_missing_rule_error, 1, INT2NUM(stack_value));
            }

            FOR(rule_i, state->config->rule_lengths[production_i])
            {
                vec_push(
                    &state->stack,
                    state->config->rules[production_i][rule_i]
                );
            }
        }
        /* Terminal */
        else if ( stack_type == T_TERMINAL )
        {
            if ( stack_value == token_id )
            {
                vec_push(&state->value_stack, value);

                break;
            }
            else
            {
                rb_funcall(
                    self,
                    id_invalid_token_error,
                    2,
                    INT2NUM(token_id),
                    INT2NUM(stack_value)
                );
            }
        }
        /* Action */
        else if ( stack_type == T_ACTION )
        {
            method      = state->config->action_names[stack_value];
            num_args    = state->config->action_arg_amounts[stack_value];
            action_args = rb_ary_new2(num_args);
            args_i      = num_args;

            while ( args_i-- )
            {
                rb_ary_store(
                    action_args,
                    args_i,
                    vec_pop(&state->value_stack)
                );
            }

            vec_push(
                &state->value_stack,
                rb_funcall(self, id_send, 2, method, action_args)
            );
        }
        /* EOF */
        else if ( stack_type == T_EOF )
        {
            break;
        }
    }

    return Qnil;
}

VALUE ll_driver_parse(VALUE self)
{
    DriverState *state;

    Data_Get_Struct(self, DriverState, state);

    // EOF rule
    vec_push(&state->stack, T_EOF);
    vec_push(&state->stack, T_EOF);

    // Start rule
    vec_push(&state->stack, T_RULE);
    vec_push(&state->stack, T_RULE);

    rb_block_call(
        self,
        id_each_token,
        0,
        NULL,
        RUBY_METHOD_FUNC(ll_driver_each_token),
        self
    );

    return vec_pop(&state->value_stack);
}

void Init_ll_driver()
{
    VALUE mLL     = rb_const_get(rb_cObject, rb_intern("LL"));
    VALUE cDriver = rb_const_get(mLL, rb_intern("Driver"));

    rb_define_method(cDriver, "parse", ll_driver_parse, 0);

    rb_define_alloc_func(cDriver, ll_driver_allocate);

    id_send                = rb_intern("send");
    id_config_const        = rb_intern("CONFIG");
    id_each_token          = rb_intern("each_token");
    id_missing_rule_error  = rb_intern("missing_rule_error");
    id_invalid_token_error = rb_intern("invalid_token_error");
}
