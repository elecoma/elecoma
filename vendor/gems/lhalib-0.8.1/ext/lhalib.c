/*
 * LhaLib for Ruby
 * Copyright(c) 2006 arton
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * $Id:$
 */

#define LHALIB_VERSION "0.8.1"

#include "lha.h"
#include "st.h"

static VALUE lhalib;

boolean lha_force = FALSE;
boolean lha_verbose = FALSE;
boolean lha_ignore_directory = FALSE;
boolean extract_broken_archive = FALSE;
boolean lha_noconvertcase = FALSE;
boolean lha_generic_format = FALSE;
boolean lha_text_mode = FALSE;
int overwrite = 1;
int lha_n_max;
unsigned short lha_maxmatch;
unsigned short bitbuf;
size_t lha_decode_count;
int lha_unpackable;
unsigned long lha_loc;
unsigned char* lha_text;
FILE* infile;
FILE* outfile;
int archive_file_gid;
int archive_file_mode;

static VALUE proc;
static VALUE id_name;
static VALUE id_permission;
static VALUE id_original_size;
static VALUE id_packed_size;
static VALUE id_stamp;
static int file_count;

void lha_exit(int n)
{
    rb_raise(rb_eRuntimeError, "LhaLib invalid operation %d", n);
}

void add_file(const LzHeader* hdr)
{
  file_count++;
  if (!NIL_P(proc))
  {
      VALUE hash = rb_hash_new();
      rb_hash_aset(hash, ID2SYM(id_name), rb_str_new2(hdr->name));
      rb_hash_aset(hash, ID2SYM(id_permission), INT2FIX(hdr->unix_mode));
      rb_hash_aset(hash, ID2SYM(id_original_size), INT2FIX(hdr->original_size));
      rb_hash_aset(hash, ID2SYM(id_packed_size), INT2FIX(hdr->packed_size));
      rb_hash_aset(hash, ID2SYM(id_stamp), rb_time_new(hdr->unix_last_modified_stamp, 0));
      rb_yield(hash);
  }
}

static VALUE s_ex(int argc, VALUE* argv, VALUE self)
{
  VALUE file;
  proc = Qnil;
  rb_scan_args(argc, argv, "1&", &file, &proc);
  rb_check_safe_str(file);
  rb_secure(4);

  file_count = 0;
  make_crctable();
  cmd_extract(StringValueCStr(file), add_file);
  return INT2FIX(file_count);
}


/*
 * Class initializer called by Ruby while requiring this library
 */
void Init_lhalib()
{
    header_level = 2;
    id_name = rb_intern("name");
    id_permission = rb_intern("permission");
    id_original_size = rb_intern("original_size");
    id_packed_size = rb_intern("packed_size");
    id_stamp = rb_intern("stamp");

    lhalib = rb_define_module("LhaLib");
    rb_define_module_function(lhalib, "x", s_ex, -1);
    rb_define_const(lhalib, "VERSION", rb_str_new2(LHALIB_VERSION));

}
