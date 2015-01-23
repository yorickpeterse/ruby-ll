#ifndef LIBLL_DRIVER_H
#define LIBLL_DRIVER_H

#include <ruby.h>
#include "driver_config.h"
#include "vec_types.h"
#include "macros.h"

typedef struct
{
    DriverConfig *config;

    long_vec_t  stack;
    VALUE_vec_t value_stack;
} DriverState;

extern void Init_ll_driver();

#endif
