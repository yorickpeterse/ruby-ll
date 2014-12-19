#include "driver.h"

#define T_EOF -1
#define T_RULE 0
#define T_TERMINAL 1
#define T_EPSILON 2
#define T_ACTION 3

#define SET_CURRENT_TOKEN \
    token = rb_ary_entry(rb_ivar_get(self, id_tokens_ivar), position); \
    if ( !NIL_P(token) ) \
    { \
        type  = rb_ary_entry(token, 0); \
        value = rb_ary_entry(token, 1); \
    }

ID id_tokens_ivar;
ID id_pop;
ID id_send;
ID id_tokens_const;
ID id_rules_const;
ID id_table_const;
ID id_actions_const;

ID id_tokens_hash;
ID id_rules_table;
ID id_table_table;
ID id_actions_table;

ID id_missing_rule_error;
ID id_invalid_terminal_error;

/**
 * Returns the maximum amount of columns in a table.
 *
 * Example:
 *
 *     [
 *       [10, 20, 30],
 *       [10, 20, 30, 40, 50]
 *     ]
 *
 * Here the maximum amount of columns would be 5.
 *
 * @param [Array] array
 * @return [Fixnum]
 */
VALUE ll_driver_max_columns(VALUE array)
{
    long columns = 0;
    long rindex;
    VALUE row;

    for ( rindex = 0; rindex < RARRAY_LEN(array); rindex++ )
    {
        row = rb_ary_entry(array, rindex);

        if ( RARRAY_LEN(row) > columns )
        {
            columns = RARRAY_LEN(row);
        }
    }

    return columns;
}

/**
 * Parsing loop for LL::Driver. This method loads the various Ruby based parsing
 * arrays/tables (RULES, TOKENS, etc) into C and starts parsing the current
 * input.
 *
 * The return value is the first value on the stack, as returned by the various
 * parsing actions.
 *
 * @return [Mixed]
 */
VALUE ll_driver_parse(VALUE self)
{
    long_vec_t stack;
    VALUE value_stack = rb_ary_new();

    VALUE token   = Qnil;
    VALUE type    = 0;
    VALUE value   = 0;
    long position = 0;

    /* TOKENS in Ruby */
    VALUE tokens_hash = rb_ivar_get(self, id_tokens_hash);

    /* RULES in Ruby */
    VALUE rules_array = rb_ivar_get(self, id_rules_table);

    /* TABLE in Ruby */
    VALUE table_array = rb_ivar_get(self, id_table_table);

    /* ACTIONS in Ruby */
    VALUE actions_array = rb_ivar_get(self, id_actions_table);

    VALUE method;
    VALUE num_args;
    VALUE action_args;

    VALUE token_id_value;
    long token_id;

    long rule_i;
    long production_i;

    long stack_type;
    long stack_value;

    /* RULES array in Ruby */
    long rules[RARRAY_LEN(rules_array)][ll_driver_max_columns(rules_array)];

    /* Contains the column count per RULES row */
    long rule_lengths[RARRAY_LEN(rules_array)];

    /* TABLE array in Ruby */
    long table[RARRAY_LEN(table_array)][ll_driver_max_columns(table_array)];

    /* ACTIONS array in Ruby */
    ID action_names[RARRAY_LEN(actions_array)];
    VALUE action_arg_amounts[RARRAY_LEN(actions_array)];

    vec_init(&stack);

    vec_reserve(&stack, 16);

    /* EOF rule */
    vec_push(&stack, -1);
    vec_push(&stack, -1);

    /* Start rule */
    vec_push(&stack, 0);
    vec_push(&stack, 0);

    /* Load the Ruby based RULES array into a C array */
    {
        long rindex;
        long cindex;
        VALUE row;

        for ( rindex = 0; rindex < RARRAY_LEN(rules_array); rindex++ )
        {
            row = rb_ary_entry(rules_array, rindex);

            for ( cindex = 0; cindex < RARRAY_LEN(row); cindex++ )
            {
                rules[rindex][cindex] = NUM2INT(rb_ary_entry(row, cindex));
            }

            rule_lengths[rindex] = RARRAY_LEN(row);
        }
    }

    /* Load the Ruby based TABLE array into a C array */
    {
        long rindex;
        long cindex;
        VALUE row;

        for ( rindex = 0; rindex < RARRAY_LEN(table_array); rindex++ )
        {
            row = rb_ary_entry(table_array, rindex);

            for ( cindex = 0; cindex < RARRAY_LEN(row); cindex++ )
            {
                table[rindex][cindex] = NUM2INT(rb_ary_entry(row, cindex));
            }
        }
    }

    /* Load the Ruby based ACTIONS array into two C arrays */
    {
        long rindex;
        VALUE row;

        for ( rindex = 0; rindex < RARRAY_LEN(actions_array); rindex++ )
        {
            row = rb_ary_entry(actions_array, rindex);

            action_names[rindex]       = rb_ary_entry(row, 0);
            action_arg_amounts[rindex] = rb_ary_entry(row, 1);
        }
    }

    /* TODO: call each_token instead */

    SET_CURRENT_TOKEN;

    while ( 1 )
    {
        stack_value    = vec_pop(&stack);
        stack_type     = vec_pop(&stack);
        token_id_value = rb_hash_aref(tokens_hash, type);

        if ( token_id_value != Qnil )
        {
            token_id = NUM2INT(token_id_value);
        }
        else
        {
            token_id = T_EOF;
        }

        /* Rule */
        if ( stack_type == T_RULE )
        {
            production_i = table[stack_value][token_id];

            if ( production_i == T_EOF )
            {
                rb_funcall(self, id_missing_rule_error, 1, INT2NUM(stack_value));
            }

            for ( rule_i = 0; rule_i < rule_lengths[production_i]; rule_i++ )
            {
                vec_push(&stack, rules[production_i][rule_i]);
            }
        }
        /* Terminal */
        else if ( stack_type == T_TERMINAL )
        {
            if ( stack_value == token_id )
            {
                rb_ary_push(value_stack, value);

                position++;

                SET_CURRENT_TOKEN;
            }
            else
            {
                rb_funcall(
                    self,
                    id_invalid_terminal_error,
                    2,
                    INT2NUM(token_id),
                    INT2NUM(stack_value)
                );
            }
        }
        /* Action */
        else if ( stack_type == T_ACTION )
        {
            method      = action_names[stack_value];
            num_args    = action_arg_amounts[stack_value];
            action_args = rb_funcall(value_stack, id_pop, 1, num_args);

            rb_ary_push(
                value_stack,
                rb_funcall(self, id_send, 2, method, action_args)
            );
        }
        /* EOF */
        else if ( stack_type == T_EOF )
        {
            break;
        }
    }

    vec_deinit(&stack);

    return rb_ary_entry(value_stack, 0);
}

void Init_ll_driver()
{
    VALUE mLL     = rb_const_get(rb_cObject, rb_intern("LL"));
    VALUE cDriver = rb_const_get(mLL, rb_intern("Driver"));

    rb_define_method(cDriver, "parse", ll_driver_parse, 0);

    id_tokens_ivar   = rb_intern("@tokens");
    id_pop           = rb_intern("pop");
    id_send          = rb_intern("send");
    id_tokens_const  = rb_intern("TOKENS");
    id_rules_const   = rb_intern("RULES");
    id_table_const   = rb_intern("TABLE");
    id_actions_const = rb_intern("ACTIONS");

    id_missing_rule_error     = rb_intern("missing_rule_error");
    id_invalid_terminal_error = rb_intern("invalid_terminal_error");

    id_tokens_hash   = rb_intern("@tokens_hash");
    id_rules_table   = rb_intern("@rules_table");
    id_table_table   = rb_intern("@table_table");
    id_actions_table = rb_intern("@actions_table");
}
