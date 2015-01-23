#include "driver_config.h"

void ll_driver_config_free(DriverConfig *config)
{
    long rindex;

    FOR(rindex, config->rules_count)
    {
        free(config->rules[rindex]);
    }

    FOR(rindex, config->table_count)
    {
        free(config->table[rindex]);
    }

    free(config->rules);
    free(config->rule_lengths);
    free(config->table);
    free(config->action_names);
    free(config->action_arg_amounts);

    free(config);
}

void ll_driver_config_mark(DriverConfig *config)
{
    long index;

    rb_gc_mark(config->tokens_hash);

    FOR(index, config->actions_count)
    {
        rb_gc_mark(config->action_names[index]);
        rb_gc_mark(config->action_arg_amounts[index]);
    }
}

VALUE ll_driver_config_allocate(VALUE klass)
{
    DriverConfig *config = ALLOC(DriverConfig);

    return Data_Wrap_Struct(klass, ll_driver_config_mark, ll_driver_config_free, config);
}

DriverConfig *ll_driver_config_get_struct(VALUE source)
{
    DriverConfig *config;

    Data_Get_Struct(source, DriverConfig, config);

    return config;
}

VALUE ll_driver_config_set_tokens(VALUE self, VALUE hash)
{
    DriverConfig *config = ll_driver_config_get_struct(self);

    config->tokens_hash = hash;

    return Qnil;
}

VALUE ll_driver_config_set_rules(VALUE self, VALUE array)
{
    long rindex;
    long cindex;
    long col_count;
    VALUE row;

    DriverConfig *config = ll_driver_config_get_struct(self);

    long row_count = RARRAY_LEN(array);

    config->rules        = ALLOC_N(long*, row_count);
    config->rule_lengths = ALLOC_N(long, row_count);

    FOR(rindex, row_count)
    {
        row       = rb_ary_entry(array, rindex);
        col_count = RARRAY_LEN(row);

        config->rules[rindex] = ALLOC_N(long, col_count);

        FOR(cindex, col_count)
        {
            config->rules[rindex][cindex] = NUM2INT(rb_ary_entry(row, cindex));
        }

        config->rule_lengths[rindex] = col_count;
    }

    config->rules_count = row_count;

    return Qnil;
}

VALUE ll_driver_config_set_table(VALUE self, VALUE array)
{
    long rindex;
    long cindex;
    long col_count;
    VALUE row;

    DriverConfig *config = ll_driver_config_get_struct(self);

    long row_count = RARRAY_LEN(array);

    config->table = ALLOC_N(long*, row_count);

    FOR(rindex, row_count)
    {
        row       = rb_ary_entry(array, rindex);
        col_count = RARRAY_LEN(row);

        config->table[rindex] = ALLOC_N(long, col_count);

        FOR(cindex, col_count)
        {
            config->table[rindex][cindex] = NUM2INT(rb_ary_entry(row, cindex));
        }
    }

    config->table_count = row_count;

    return Qnil;
}

VALUE ll_driver_config_set_actions(VALUE self, VALUE array)
{
    long rindex;
    VALUE row;

    DriverConfig *config = ll_driver_config_get_struct(self);

    long row_count = RARRAY_LEN(array);

    config->action_names       = ALLOC_N(ID, row_count);
    config->action_arg_amounts = ALLOC_N(long, row_count);

    FOR(rindex, row_count)
    {
        row = rb_ary_entry(array, rindex);

        config->action_names[rindex]       = rb_ary_entry(row, 0);
        config->action_arg_amounts[rindex] = NUM2INT(rb_ary_entry(row, 1));
    }

    config->actions_count = row_count;

    return Qnil;
}

void Init_ll_driver_config()
{
    VALUE mLL           = rb_const_get(rb_cObject, rb_intern("LL"));
    VALUE cDriverConfig = rb_const_get(mLL, rb_intern("DriverConfig"));

    rb_define_alloc_func(cDriverConfig, ll_driver_config_allocate);

    rb_define_method(cDriverConfig, "tokens_native=", ll_driver_config_set_tokens, 1);
    rb_define_method(cDriverConfig, "rules_native=", ll_driver_config_set_rules, 1);
    rb_define_method(cDriverConfig, "table_native=", ll_driver_config_set_table, 1);
    rb_define_method(cDriverConfig, "actions_native=", ll_driver_config_set_actions, 1);
}
