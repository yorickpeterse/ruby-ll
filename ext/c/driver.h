#ifndef LIBLL_DRIVER_H
#define LIBLL_DRIVER_H

#include <ruby.h>
#include "driver_config.h"
#include "macros.h"
#include "kvec.h"

typedef struct
{
    DriverConfig *config;

    kvec_t(long) stack;
    kvec_t(VALUE) value_stack;
} DriverState;

extern void Init_ll_driver();

#endif
