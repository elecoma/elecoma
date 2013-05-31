/* ------------------------------------------------------------------------ */
/* LHa for UNIX                                                             */
/*              util.c -- LHarc Util                                        */
/*                                                                          */
/*      Modified                Nobutaka Watazaki                           */
/*                                                                          */
/*  Ver. 1.14   Source All chagned              1995.01.14  N.Watazaki      */
/*  Ver. 1.14e  Support for sfx archives        1999.05.28  T.Okamoto       */
/*      Modified arton for LhaLib */
/* ------------------------------------------------------------------------ */
#include "lha.h"
/*
 * util.c - part of LHa for UNIX Feb 26 1992 modified by Masaru Oki Mar  4
 * 1992 modified by Masaru Oki #ifndef USESTRCASECMP added. Mar 31 1992
 * modified by Masaru Oki #ifdef NOMEMSET added.
 */
#include <errno.h>

size_t
copyfile(FILE* f1, FILE* f2, size_t size, int text_flg, unsigned int* crcp)  /* return: size of source file */
    /* int text_flg*/             /* 0: binary, 1: read text, 2: write text */
{
    unsigned short  xsize;
    char *buf;
    size_t rsize = 0;

    if (!text_mode)
        text_flg = 0;

    buf = (char *)xmalloc(BUFFERSIZE);
    if (crcp)
        INITIALIZE_CRC(*crcp);
    if (text_flg)
        init_code_cache();
    while (size > 0) {
        /* read */
        if (text_flg & 1) {
            xsize = fread_txt(buf, BUFFERSIZE, f1);
            if (xsize == 0)
                break;
            if (ferror(f1)) {
                fatal_error("file read error");
            }
        }
        else {
            xsize = (size > BUFFERSIZE) ? BUFFERSIZE : size;
            if (fread(buf, 1, xsize, f1) != xsize) {
                fatal_error("file read error");
            }
            if (size < xsize)
                size = 0;
            else
                size -= xsize;
        }

        /* write */
        if (f2) {
            if (text_flg & 2) {
                if (fwrite_txt(buf, xsize, f2)) {
                    fatal_error("file write error");
                }
            }
            else {
                if (fwrite(buf, 1, xsize, f2) != xsize) {
                    fatal_error("file write error");
                }
            }
        }

        /* calculate crc */
        if (crcp) {
            *crcp = calccrc(*crcp, buf, xsize);
#ifdef NEED_INCREMENTAL_INDICATOR
            put_indicator(xsize);
#endif
        }
        rsize += xsize;
    }
    free(buf);
    return rsize;
}

int
encode_stored_crc(ifp, ofp, size, original_size_var, write_size_var)
    FILE *ifp, *ofp;
    size_t size;
    size_t *original_size_var;
    size_t *write_size_var;
{
    unsigned int crc;

    size = copyfile(ifp, ofp, size, 1, &crc);
    *original_size_var = *write_size_var = size;
    return crc;
}

/* If TRUE, archive file name is msdos SFX file name. */
boolean
archive_is_msdos_sfx1(const char* name)
{
    int len = strlen(name);

    if (len >= 4) {
        if (strcasecmp(".COM", name + len - 4) == 0 ||
            strcasecmp(".EXE", name + len - 4) == 0)
            return 1;
    }

    if (len >= 2 && strcasecmp(".x", name + len - 2) == 0)
        return 1;

    return 0;
}

int
#if STDC_HEADERS
xsnprintf(char *dest, size_t size, char *fmt, ...)
#else
xsnprintf(dest, size, fmt, va_alist)
    char *dest, *fmt;
    size_t size;
    va_dcl
#endif
{
    int len;
    va_list v;

    va_init(v, fmt);
    len = vsnprintf(dest, size, fmt, v);
    va_end(v);

    if (len == -1)
        return -1;

    if (len >= size) {
        dest[size-1] = 0;
        return -1;
    }

    return 0;
}

#if !STRCHR_8BIT_CLEAN
/* 8 bit clean strchr()/strrchr()/memchr()/memrchr() */
char *
xstrchr(const char *s, int c)
{
    if (c == 0)
        return (char*)s + strlen(s);

    while (*s) {
        if ((unsigned char)*s == (unsigned char)c)
            return (char*)s;
        s++;
    }

    return 0;
}

char *
xstrrchr(const char *s, int c)
{
    char *p = 0;

    while (*s) {
        if ((unsigned char)*s == (unsigned char)c)
            p = (char*)s;
        s++;
    }

    return p;
}

char *
xmemchr(const char *s, int c, size_t n)
{
    char *end = (char*)s + n;

    while (s != end) {
        if ((unsigned char)*s == (unsigned char)c)
            return (char*)s;
        s++;
    }

    return 0;
}

char *
xmemrchr(const char *s, int c, size_t n)
{
    char *end = (char*)s-1;
    char *p = 0;

    s += n-1;
    while (s != end) {
        if ((unsigned char)*s == (unsigned char)c)
            p = (char*)s;
        s--;
    }

    return p;
}
#endif

/* This function is similar to strncpy() but `dst' is always
   terminated by '\0'. Return the copied string length. */
int
str_safe_copy(char *dst, const char *src, int dstsz)
{
    int i;

    if (dstsz < 1) return 0;

    for (i = 0; i < dstsz; i++) {
	if ((dst[i] = src[i]) == '\0')
	    return i;
    }

    /* here is i == dstsz */
    dst[--i] = '\0';	/* if eliminated this line,
			   this function was same as strncpy(). */

    return i;
}
