#ifndef LIBLL_DRIVER_H
#define LIBLL_DRIVER_H

#include "libll.h"
#include "vec.h"

typedef vec_t(long) long_vec_t;
typedef vec_t(long_vec_t) long_vec_vec_t;
typedef vec_t(VALUE) VALUE_vec_t;

extern void Init_ll_driver();

#endif
