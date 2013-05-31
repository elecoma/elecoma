/* ------------------------------------------------------------------------ */
/* LHa for UNIX                                                             */
/*              extract.c -- extrcat from archive                           */
/*                                                                          */
/*      Modified                Nobutaka Watazaki                           */
/*                                                                          */
/*  Ver. 1.14   Source All chagned              1995.01.14  N.Watazaki      */
/* ------------------------------------------------------------------------ */
#include "lha.h"

int
decode_lzhuf(infp, outfp, original_size, packed_size, name, method, read_sizep)
    FILE           *infp;
    FILE           *outfp;
    size_t          original_size;
    size_t          packed_size;
    char           *name;
    int             method;
    size_t         *read_sizep;
{
    unsigned int crc;
    struct interfacing intf;

    intf.method = method;
    intf.infile = infp;
    intf.outfile = outfp;
    intf.original = original_size;
    intf.packed = packed_size;
    intf.read_size = 0;

    switch (method) {
    case LZHUFF0_METHOD_NUM:    /* -lh0- */
        intf.dicbit = LZHUFF0_DICBIT;
        break;
    case LZHUFF1_METHOD_NUM:    /* -lh1- */
        intf.dicbit = LZHUFF1_DICBIT;
        break;
    case LZHUFF2_METHOD_NUM:    /* -lh2- */
        intf.dicbit = LZHUFF2_DICBIT;
        break;
    case LZHUFF3_METHOD_NUM:    /* -lh2- */
        intf.dicbit = LZHUFF3_DICBIT;
        break;
    case LZHUFF4_METHOD_NUM:    /* -lh4- */
        intf.dicbit = LZHUFF4_DICBIT;
        break;
    case LZHUFF5_METHOD_NUM:    /* -lh5- */
        intf.dicbit = LZHUFF5_DICBIT;
        break;
    case LZHUFF6_METHOD_NUM:    /* -lh6- */
        intf.dicbit = LZHUFF6_DICBIT;
        break;
    case LZHUFF7_METHOD_NUM:    /* -lh7- */
        intf.dicbit = LZHUFF7_DICBIT;
        break;
    case LARC_METHOD_NUM:       /* -lzs- */
        intf.dicbit = LARC_DICBIT;
        break;
    case LARC5_METHOD_NUM:      /* -lz5- */
        intf.dicbit = LARC5_DICBIT;
        break;
    case LARC4_METHOD_NUM:      /* -lz4- */
        intf.dicbit = LARC4_DICBIT;
        break;
    default:
        warning("unknown method %d", method);
        intf.dicbit = LZHUFF5_DICBIT; /* for backward compatibility */
        break;
    }

    if (intf.dicbit == 0) { /* LZHUFF0_DICBIT or LARC4_DICBIT */
        start_indicator(name,
                        original_size, "Melting ",
                        2048);
        *read_sizep = copyfile(infp, outfp,
                               original_size, 2, &crc);
    }
    else {
        start_indicator(name,
                        original_size, "Melting ",
                        1 << intf.dicbit);
        crc = decode(&intf);
        *read_sizep = intf.read_size;
    }

    finish_indicator(name, "Melted  ");

    return crc;
}
