/*
   Copyright (C) 2010 bg <bg_one@mail.ru>
*/
#ifndef CHAN_QUECTEL_MEMMEM_H_INCLUDED
#define CHAN_QUECTEL_MEMMEM_H_INCLUDED

#ifdef HAVE_MEMMEM

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif /* _GNU_SOURCE */
#include <string.h>

#else /* HAVE_MEMMEM */

#include <sys/types.h> /* size_t */

void* memmem(const void* l, size_t l_len, const void* s, size_t s_len);

#endif /* HAVE_MEMMEM */
#endif /* CHAN_QUECTEL_MANAGER_H_INCLUDED */
