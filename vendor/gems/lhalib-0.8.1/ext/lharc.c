/* ------------------------------------------------------------------------ */
/* LHa for UNIX                                                             */
/*              lharc.c -- append to archive                                */
/*                                                                          */
/*      Copyright (C) MCMLXXXIX Yooichi.Tagawa                              */
/*      Modified                Nobutaka Watazaki                           */
/*                          Thanks to H.Yoshizaki. (MS-DOS LHarc)           */
/*                                                                          */
/*  Ver. 0.00  Original                         1988.05.23  Y.Tagawa        */
/*  Ver. 0.01  Alpha Version (for 4.2BSD)       1989.05.28  Y.Tagawa        */
/*  Ver. 0.02  Alpha Version Rel.2              1989.05.29  Y.Tagawa        */
/*  Ver. 0.03  Release #3  Beta Version         1989.07.02  Y.Tagawa        */
/*  Ver. 0.03a Debug                            1989.07.03  Y.Tagawa        */
/*  Ver. 0.03b Modified                         1989.07.13  Y.Tagawa        */
/*  Ver. 0.03c Debug (Thanks to void@rena.dit.junet)                        */
/*                                              1989.08.09  Y.Tagawa        */
/*  Ver. 0.03d Modified (quiet and verbose)     1989.09.14  Y.Tagawa        */
/*  V1.00  Fixed                                1989.09.22  Y.Tagawa        */
/*  V1.01  Bug Fixed                            1989.12.25  Y.Tagawa        */
/*                                                                          */
/*  DOS-Version Original LHx V C2.01        (C) H.Yohizaki                  */
/*                                                                          */
/*  V2.00  UNIX Lharc + DOS LHx -> OSK LHx      1990.11.01  Momozou         */
/*  V2.01  Minor Modified                       1990.11.24  Momozou         */
/*                                                                          */
/*  Ver. 0.02  LHx for UNIX                     1991.11.18  M.Oki           */
/*  Ver. 0.03  LHa for UNIX                     1991.12.17  M.Oki           */
/*  Ver. 0.04  LHa for UNIX beta version        1992.01.20  M.Oki           */
/*  Ver. 1.00  LHa for UNIX Fixed               1992.03.19  M.Oki           */
/*                                                                          */
/*  Ver. 1.10  for Symbolic Link                1993.06.25  N.Watazaki      */
/*  Ver. 1.11  for Symbolic Link Bug Fixed      1993.08.18  N.Watazaki      */
/*  Ver. 1.12  for File Date Check              1993.10.28  N.Watazaki      */
/*  Ver. 1.13  Bug Fixed (Idicator calcurate)   1994.02.21  N.Watazaki      */
/*  Ver. 1.13a Bug Fixed (Sym. Link delete)     1994.03.11  N.Watazaki      */
/*  Ver. 1.13b Bug Fixed (Sym. Link delete)     1994.07.29  N.Watazaki      */
/*  Ver. 1.14  Source All chagned               1995.01.14  N.Watazaki      */
/*  Ver. 1.14b,c  Bug Fixed                     1996.03.07  t.okamoto       */
/*  Ver. 1.14d Version up                       1997.01.12  t.okamoto       */
/*  Ver. 1.14g Bug Fixed                        2000.05.06  t.okamoto       */
/*  Ver. 1.14i Modified                         2000.10.06  t.okamoto       */
/*   Modified arton for LhaLib */
/* ------------------------------------------------------------------------ */

#include "lha.h"

static int      cmd = CMD_UNKNOWN;
static int error_occurred;

/* ------------------------------------------------------------------------ */
/*                                                                          */
/* ------------------------------------------------------------------------ */
static          boolean
open_old_archive_1(name, v_fp)
    char           *name;
    FILE          **v_fp;
{
    FILE           *fp;
    struct stat     stbuf;

    if (stat(name, &stbuf) >= 0 &&
        is_regularfile(&stbuf) &&
        (fp = fopen(name, READ_BINARY)) != NULL) {
        *v_fp = fp;
        archive_file_gid = stbuf.st_gid;
        archive_file_mode = stbuf.st_mode;
        return TRUE;
    }

    *v_fp = NULL;
    archive_file_gid = -1;
    return FALSE;
}

/* ------------------------------------------------------------------------ */
FILE           *
open_old_archive(const char* archive_name)
{
    FILE           *fp;
    char           *p;
    static char expanded_archive_name[FILENAME_LENGTH];

    if (!strcmp(archive_name, "-")) {
        if (cmd == CMD_EXTRACT || cmd == CMD_LIST) {
#if __MINGW32__
            setmode(fileno(stdin), O_BINARY);
#endif
            return stdin;
        }
        else
            return NULL;
    }
    p = strrchr(archive_name, '.');
    if (p) {
        if (strcasecmp(".LZH", p) == 0
            || strcasecmp(".LZS", p) == 0
            || strcasecmp(".COM", p) == 0  /* DOS SFX */
            || strcasecmp(".EXE", p) == 0
            || strcasecmp(".X", p) == 0    /* HUMAN SFX */
            || strcasecmp(".BAK", p) == 0) {   /* for BackUp */
            open_old_archive_1(archive_name, &fp);
            return fp;
        }
    }

    if (open_old_archive_1(archive_name, &fp))
        return fp;
    xsnprintf(expanded_archive_name, sizeof(expanded_archive_name),
              "%s.lzh", archive_name);
    if (open_old_archive_1(expanded_archive_name, &fp)) {
        archive_name = expanded_archive_name;
        return fp;
    }
    /*
     * if ( (errno&0xffff)!=E_PNNF ) { archive_name =
     * expanded_archive_name; return NULL; }
     */
    xsnprintf(expanded_archive_name, sizeof(expanded_archive_name),
              "%s.lzs", archive_name);
    if (open_old_archive_1(expanded_archive_name, &fp)) {
        archive_name = expanded_archive_name;
        return fp;
    }
    return NULL;
}

boolean
need_file(const char* name)
{
    return TRUE;
}

