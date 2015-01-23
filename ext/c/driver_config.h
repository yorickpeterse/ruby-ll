#ifndef LIBLL_DRIVER_CONFIG_H
#define LIBLL_DRIVER_CONFIG_H

#include <ruby.h>
#include "macros.h"

typedef struct
{
    VALUE tokens_hash;

    long **rules;
    long *rule_lengths;

    long **table;

    ID   *action_names;
    long *action_arg_amounts;

    long rules_count;
    long table_count;
    long actions_count;

} DriverConfig;

extern void Init_ll_driver_config();
extern DriverConfig *ll_driver_config_get_struct(VALUE config);

#endif
