#ifndef LIBLL_DRIVER_CONFIG_H
#define LIBLL_DRIVER_CONFIG_H

#include <ruby.h>
#include "macros.h"
#include "khash.h"

KHASH_MAP_INIT_INT64(int64_map, long)

typedef struct
{
    khash_t(int64_map) *tokens;

    long **rules;
    long *rule_lengths;

    long **table;

    ID   *action_names;
    long *action_arg_amounts;

    long rules_count;
    long table_count;
    long actions_count;
    long tokens_count;
} DriverConfig;

extern void Init_ll_driver_config();

#endif
