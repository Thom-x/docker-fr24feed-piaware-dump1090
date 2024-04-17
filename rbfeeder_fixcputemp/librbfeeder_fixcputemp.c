// SPDX-License-Identifier: GPL-2.0
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

#undef fopen

ssize_t cputemp_read(void *cookie, char *buf, size_t size)
{
    const char temp[] = "0";
    size_t len = sizeof(temp);
    if (size < len)
    {
        return -1;
    }
    memcpy(buf, temp, len);
    return len;
}

cookie_io_functions_t cputemp_funcs = {
    .read = cputemp_read,
};

FILE *fopen(const char *path, const char *mode)
{
    FILE *orig_file = NULL;
    static FILE *(*real_fopen)(const char *, const char *) = NULL;
    if (real_fopen == NULL)
    {
        real_fopen = dlsym(RTLD_NEXT, "fopen");
        if (real_fopen == NULL)
        {
            fprintf(stderr, "fixcputemp: Error in `dlsym`: %s\n", dlerror());
            return NULL;
        }
    }

    orig_file = real_fopen(path, mode);
    if (orig_file)
    {
        return orig_file;
    }

    if (strcmp(path, "/sys/class/thermal/thermal_zone0/temp") == 0)
    {
        if (strcmp(mode, "r") != 0)
        {
            fprintf(stderr, "fixcputemp: fopen() called with mode other than 'r'\n");
            return NULL;
        }
        return fopencookie(NULL, "r", cputemp_funcs);
    }
    return NULL;
}
