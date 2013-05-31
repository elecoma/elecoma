module TMail

  class Parser < Racc::Parser

module_eval(<<'...end parser.y/module_eval...', 'parser.y', 333)

  include TextUtils

  def Parser.parse(ident, str, comment = nil)
    new().parse(ident, str, comment)
  end

  MAILP_DEBUG = false unless

  def initialize
    self.debug = MAILP_DEBUG
  end

  def debug=(flag)
    @yydebug = flag && Racc_debug_parser
    @scanner_debug = flag
  end

  def debug
    @yydebug
  end

  alias debug? debug

  def parse(ident, str, comments = nil)
    @scanner = Scanner.new(str, ident, comments)
    @scanner.debug = @scanner_debug
    @first = [ident, ident]
    result = yyparse(self, :parse0)
    comments.map! {|c| to_kcode(c) } if comments
    result
  end

  private

  def parse0(&block)
    yield @first
    @scanner.scan(&block)
  end
  
  def on_error(t, val, vstack)
    raise SyntaxError, "parse error on token #{racc_token2str(t)}"
  end
...end parser.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
   -69,    23,    25,   147,   148,    29,    31,   106,   107,    16,
    17,    19,    22,   137,    23,    25,   -69,    32,    29,    31,
   -69,   155,    16,    17,    19,    22,   -69,    27,    76,    76,
    32,    23,    25,   156,   100,    29,    31,   143,   144,    16,
    17,    19,    22,   108,    27,    23,    25,    32,    99,    29,
    31,   115,   116,    16,    17,    19,    22,   110,    27,    97,
    76,    32,    23,    25,   121,    95,    29,    31,   113,    79,
    16,    17,    19,    22,    92,    27,    23,    25,    32,   118,
    29,    31,    89,    82,    16,    17,    19,    22,   124,    23,
    25,   100,    32,    29,    31,   126,   127,    16,    17,    19,
    22,    81,    27,    23,    25,    32,    92,    29,    31,   129,
   130,    16,    17,    19,    22,    76,    52,    23,    25,    32,
    76,    29,    31,   131,    80,    16,    17,    19,    22,    79,
    23,    25,   134,    32,    29,    31,    79,    78,    16,    17,
    19,    22,    76,    23,    25,    65,    32,    29,    31,    62,
   140,    16,    17,    19,    22,    76,    23,    25,    60,    32,
    29,    31,   100,    44,    16,    17,    19,    22,    76,    23,
    25,   121,    32,    29,    31,   149,   150,    16,    17,    19,
    22,   153,    27,    23,    25,    32,    68,    29,    31,   154,
    42,    16,    17,    19,    22,   158,    27,    23,    25,    32,
   160,    29,    31,    74,    40,    16,    17,    19,    22,    15,
    23,    25,   165,    32,    29,    31,    40,   167,    16,    17,
    19,    22,   168,    27,    23,    25,    32,   nil,    29,    31,
   nil,   nil,    16,    17,    19,    22,   nil,    23,    25,   nil,
    32,    29,    31,   nil,   nil,    16,    17,    19,    22,   nil,
    23,    25,   nil,    32,    29,    31,   nil,   nil,    16,    17,
    19,    22,   nil,    27,    23,    25,    32,   nil,    29,    31,
    74,   nil,    16,    17,    19,    22,   nil,   nil,    93,   nil,
    32,    23,    25,   nil,   nil,    29,    31,   nil,   nil,    16,
    17,    19,    22,   nil,    23,    25,   nil,    32,    29,    31,
   nil,   nil,    16,    17,    19,    22,   nil,    85,    25,   nil,
    32,    29,    31,   nil,    88,    16,    17,    19,    22,    85,
    25,   nil,   nil,    29,    31,   nil,    88,    16,    17,    19,
    22,     4,     6,     7,     8,     9,    10,    11,    12,    13,
     1,     2,     3,    85,    25,   nil,   nil,    29,    31,   nil,
    88,    16,    17,    19,    22,    85,    25,   nil,   nil,    29,
    31,   nil,    88,    16,    17,    19,    22,    85,    25,   nil,
   nil,    29,    31,   nil,    88,    16,    17,    19,    22,    85,
    25,   nil,   nil,    29,    31,   nil,    88,    16,    17,    19,
    22,    85,    25,   nil,   nil,    29,    31,   nil,    88,    16,
    17,    19,    22 ]

racc_action_check = [
    28,    77,    77,   137,   137,    77,    77,    72,    72,    77,
    77,    77,    77,   127,     2,     2,    28,    77,     2,     2,
    28,   144,     2,     2,     2,     2,    28,     2,    67,    28,
     2,     3,     3,   144,    66,     3,     3,   135,   135,     3,
     3,     3,     3,    73,     3,   153,   153,     3,    62,   153,
   153,    87,    87,   153,   153,   153,   153,    75,   153,    60,
    87,   153,    91,    91,    91,    56,    91,    91,    81,    51,
    91,    91,    91,    91,    50,    91,    71,    71,    91,    90,
    71,    71,    45,    42,    71,    71,    71,    71,    97,     7,
     7,    98,    71,     7,     7,    99,   100,     7,     7,     7,
     7,    41,     7,     8,     8,     7,   103,     8,     8,   105,
   106,     8,     8,     8,     8,   109,     8,     9,     9,     8,
   112,     9,     9,   113,    40,     9,     9,     9,     9,    36,
    10,    10,   118,     9,    10,    10,   122,    33,    10,    10,
    10,    10,    70,   156,   156,    13,    10,   156,   156,    12,
   131,   156,   156,   156,   156,   133,    95,    95,    11,   156,
    95,    95,   136,     6,    95,    95,    95,    95,   139,   128,
   128,   128,    95,   128,   128,   140,   141,   128,   128,   128,
   128,   142,   128,    26,    26,   128,    26,    26,    26,   143,
     5,    26,    26,    26,    26,   149,    26,    27,    27,    26,
   152,    27,    27,    27,     4,    27,    27,    27,    27,     1,
    68,    68,   158,    27,    68,    68,   160,   164,    68,    68,
    68,    68,   165,    68,   123,   123,    68,   nil,   123,   123,
   nil,   nil,   123,   123,   123,   123,   nil,    55,    55,   nil,
   123,    55,    55,   nil,   nil,    55,    55,    55,    55,   nil,
    38,    38,   nil,    55,    38,    38,   nil,   nil,    38,    38,
    38,    38,   nil,    38,    52,    52,    38,   nil,    52,    52,
    52,   nil,    52,    52,    52,    52,   nil,   nil,    52,   nil,
    52,   102,   102,   nil,   nil,   102,   102,   nil,   nil,   102,
   102,   102,   102,   nil,    59,    59,   nil,   102,    59,    59,
   nil,   nil,    59,    59,    59,    59,   nil,   115,   115,   nil,
    59,   115,   115,   nil,   115,   115,   115,   115,   115,    89,
    89,   nil,   nil,    89,    89,   nil,    89,    89,    89,    89,
    89,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,   114,   114,   nil,   nil,   114,   114,   nil,
   114,   114,   114,   114,   114,    44,    44,   nil,   nil,    44,
    44,   nil,    44,    44,    44,    44,    44,    78,    78,   nil,
   nil,    78,    78,   nil,    78,    78,    78,    78,    78,    74,
    74,   nil,   nil,    74,    74,   nil,    74,    74,    74,    74,
    74,   130,   130,   nil,   nil,   130,   130,   nil,   130,   130,
   130,   130,   130 ]

racc_action_pointer = [
   329,   178,     0,    17,   189,   190,   145,    75,    89,   103,
   116,   144,   118,   114,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   169,   183,     0,   nil,
   nil,   nil,   nil,   117,   nil,   nil,   103,   nil,   236,   nil,
   108,    87,    83,   nil,   341,    63,   nil,   nil,   nil,   nil,
    58,    43,   250,   nil,   nil,   223,    49,   nil,   nil,   280,
    30,   nil,    16,   nil,   nil,   nil,     8,    -1,   196,   nil,
   113,    62,    -9,    15,   365,    28,   nil,   -13,   353,   nil,
   nil,    53,   nil,   nil,   nil,   nil,   nil,    31,   nil,   305,
    57,    48,   nil,   nil,   nil,   142,   nil,    74,    65,    64,
    65,   nil,   267,    90,   nil,    81,    90,   nil,   nil,    86,
   nil,   nil,    91,   109,   329,   293,   nil,   nil,   117,   nil,
   nil,   nil,   110,   210,   nil,   nil,   nil,   -20,   155,   nil,
   377,   136,   nil,   126,   nil,    14,   136,   -27,   nil,   139,
   158,   161,   156,   174,     6,   nil,   nil,   nil,   nil,   181,
   nil,   nil,   174,    31,   nil,   nil,   129,   nil,   195,   nil,
   201,   nil,   nil,   nil,   189,   208,   nil,   nil,   nil ]

racc_action_default = [
  -111,  -111,  -111,  -111,   -14,  -111,   -20,  -111,  -111,  -111,
  -111,  -111,  -111,  -111,   -10,   -96,  -107,  -108,   -44,  -109,
   -78,   -11,  -110,   -80,   -43,  -104,  -111,  -111,   -60,  -105,
   -55,  -106,   -79,   -68,   -54,   -71,   -45,   -12,  -111,    -1,
  -111,  -111,  -111,    -2,  -111,   -22,   -51,   -48,   -50,    -3,
   -40,   -41,  -111,   -46,    -4,   -87,    -5,   -89,    -6,   -91,
  -111,    -7,   -96,    -8,    -9,  -100,  -102,   -61,   -59,   -56,
   -69,  -111,  -111,  -111,  -111,   -77,   -75,   -70,  -111,   -57,
   -15,  -111,   169,   -73,   -81,   -83,   -21,   -24,   -82,  -111,
   -27,  -111,   -84,   -47,   -90,  -111,   -92,  -111,  -102,  -111,
  -103,  -101,  -111,   -58,   -52,  -111,  -111,   -64,   -63,   -65,
   -76,   -72,   -67,  -111,  -111,  -111,   -26,   -23,  -111,   -29,
   -49,   -85,   -42,   -88,   -93,   -95,   -96,  -111,  -111,   -62,
  -111,  -111,   -74,   -25,   -28,   -31,  -102,  -111,   -53,   -66,
  -111,  -111,   -34,  -111,  -111,   -94,   -97,   -99,   -98,  -111,
   -18,   -13,   -38,  -111,   -30,   -33,  -111,   -32,   -16,   -19,
   -14,   -35,   -36,   -37,  -111,  -111,   -39,   -86,   -17 ]

racc_goto_table = [
    39,    67,    70,    73,    24,    37,    69,    57,    59,    38,
    36,    66,    55,    67,    91,    84,   159,    86,    69,   101,
   109,    49,    53,   135,   112,   142,    77,    70,    73,   152,
   119,    90,    45,   157,   161,   151,   141,    21,    14,    18,
   120,   103,    64,    63,    61,    84,    70,   105,    58,    84,
   132,   125,    56,    94,    54,    43,     5,    96,    98,   146,
    84,   133,   117,   nil,   nil,   102,   nil,   128,    77,   nil,
   104,   nil,   nil,   nil,    38,   111,   139,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,    84,    84,   nil,   nil,   145,
   nil,   nil,   nil,    57,   nil,   nil,   nil,   nil,   123,   122,
   111,    84,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,    94,   136,   nil,   nil,   nil,   nil,   nil,    70,   163,
   138,    70,   164,   162,    38,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   166 ]

racc_goto_check = [
     2,    37,    37,    29,    13,    13,    28,    42,    42,    36,
    31,    47,    46,    37,    32,    45,    23,    24,    28,    48,
    25,     4,     4,    20,    25,    21,    41,    37,    29,    22,
    19,    18,    17,    26,    27,    16,    15,    12,    11,    33,
    34,    35,    10,     9,     8,    45,    37,    29,     7,    45,
    43,    48,     6,    42,     5,     3,     1,    42,    47,    49,
    45,    25,    24,   nil,   nil,    41,   nil,    32,    41,   nil,
    13,   nil,   nil,   nil,    36,    42,    25,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,    45,    45,   nil,   nil,    48,
   nil,   nil,   nil,    42,   nil,   nil,   nil,   nil,    46,    31,
    42,    45,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,    42,    47,   nil,   nil,   nil,   nil,   nil,    37,    29,
    13,    37,    29,    28,    36,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,     2 ]

racc_goto_pointer = [
   nil,    56,    -4,    49,    14,    46,    43,    38,    33,    31,
    29,    37,    35,     2,   nil,   -95,  -106,    26,   -14,   -60,
   -96,  -110,  -113,  -136,   -27,   -54,  -111,  -119,   -20,   -24,
   nil,     8,   -36,    37,   -51,   -27,     6,   -25,   nil,   nil,
   nil,    -2,    -2,   -64,   nil,   -29,     3,    -4,   -47,   -78 ]

racc_goto_default = [
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,    48,    41,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,    87,   nil,   nil,    30,    34,
    50,    51,   nil,    46,    47,   nil,    26,    28,    71,    72,
    33,   114,    35,    83,    75,    20,   nil,   nil,   nil,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  2, 35, :_reduce_1,
  2, 35, :_reduce_2,
  2, 35, :_reduce_3,
  2, 35, :_reduce_4,
  2, 35, :_reduce_5,
  2, 35, :_reduce_6,
  2, 35, :_reduce_7,
  2, 35, :_reduce_8,
  2, 35, :_reduce_9,
  2, 35, :_reduce_10,
  2, 35, :_reduce_11,
  2, 35, :_reduce_12,
  6, 36, :_reduce_13,
  0, 48, :_reduce_none,
  2, 48, :_reduce_none,
  3, 49, :_reduce_16,
  5, 49, :_reduce_17,
  1, 50, :_reduce_18,
  7, 37, :_reduce_19,
  0, 51, :_reduce_none,
  2, 51, :_reduce_21,
  0, 52, :_reduce_none,
  2, 52, :_reduce_23,
  1, 58, :_reduce_24,
  3, 58, :_reduce_25,
  2, 58, :_reduce_26,
  0, 53, :_reduce_none,
  2, 53, :_reduce_28,
  0, 54, :_reduce_29,
  3, 54, :_reduce_30,
  0, 55, :_reduce_none,
  2, 55, :_reduce_32,
  2, 55, :_reduce_33,
  0, 56, :_reduce_none,
  2, 56, :_reduce_35,
  1, 61, :_reduce_36,
  1, 61, :_reduce_37,
  0, 57, :_reduce_none,
  2, 57, :_reduce_39,
  1, 38, :_reduce_none,
  1, 38, :_reduce_none,
  3, 38, :_reduce_none,
  1, 46, :_reduce_none,
  1, 46, :_reduce_none,
  1, 46, :_reduce_none,
  1, 39, :_reduce_none,
  2, 39, :_reduce_47,
  1, 64, :_reduce_48,
  3, 64, :_reduce_49,
  1, 68, :_reduce_none,
  1, 68, :_reduce_none,
  1, 69, :_reduce_52,
  3, 69, :_reduce_53,
  1, 47, :_reduce_none,
  1, 47, :_reduce_none,
  2, 47, :_reduce_56,
  2, 67, :_reduce_none,
  3, 65, :_reduce_58,
  2, 65, :_reduce_59,
  1, 70, :_reduce_60,
  2, 70, :_reduce_61,
  4, 62, :_reduce_62,
  3, 62, :_reduce_63,
  2, 72, :_reduce_none,
  2, 73, :_reduce_65,
  4, 73, :_reduce_66,
  3, 63, :_reduce_67,
  1, 63, :_reduce_68,
  1, 74, :_reduce_none,
  2, 74, :_reduce_70,
  1, 71, :_reduce_71,
  3, 71, :_reduce_72,
  1, 59, :_reduce_73,
  3, 59, :_reduce_74,
  1, 78, :_reduce_none,
  2, 78, :_reduce_76,
  1, 75, :_reduce_77,
  1, 76, :_reduce_none,
  1, 76, :_reduce_none,
  1, 76, :_reduce_none,
  1, 77, :_reduce_none,
  1, 77, :_reduce_none,
  1, 77, :_reduce_none,
  1, 66, :_reduce_none,
  2, 66, :_reduce_none,
  3, 60, :_reduce_86,
  1, 40, :_reduce_87,
  3, 40, :_reduce_88,
  1, 80, :_reduce_none,
  2, 80, :_reduce_90,
  1, 41, :_reduce_91,
  2, 41, :_reduce_92,
  3, 42, :_reduce_93,
  5, 43, :_reduce_94,
  3, 43, :_reduce_95,
  0, 81, :_reduce_96,
  5, 81, :_reduce_97,
  1, 83, :_reduce_none,
  1, 83, :_reduce_none,
  1, 44, :_reduce_100,
  3, 45, :_reduce_101,
  0, 82, :_reduce_none,
  1, 82, :_reduce_none,
  1, 79, :_reduce_none,
  1, 79, :_reduce_none,
  1, 79, :_reduce_none,
  1, 79, :_reduce_none,
  1, 79, :_reduce_none,
  1, 79, :_reduce_none,
  1, 79, :_reduce_none ]

racc_reduce_n = 111

racc_shift_n = 169

racc_token_table = {
  false => 0,
  :error => 1,
  :DATETIME => 2,
  :RECEIVED => 3,
  :MADDRESS => 4,
  :RETPATH => 5,
  :KEYWORDS => 6,
  :ENCRYPTED => 7,
  :MIMEVERSION => 8,
  :CTYPE => 9,
  :CENCODING => 10,
  :CDISPOSITION => 11,
  :ADDRESS => 12,
  :MAILBOX => 13,
  :DIGIT => 14,
  :ATOM => 15,
  "," => 16,
  ":" => 17,
  :FROM => 18,
  :BY => 19,
  "@" => 20,
  :DOMLIT => 21,
  :VIA => 22,
  :WITH => 23,
  :ID => 24,
  :FOR => 25,
  ";" => 26,
  "<" => 27,
  ">" => 28,
  "." => 29,
  :QUOTED => 30,
  :TOKEN => 31,
  "/" => 32,
  "=" => 33 }

racc_nt_base = 34

racc_use_result_var = false

Racc_arg = [
  racc_action_table,
  racc_action_check,
  racc_action_default,
  racc_action_pointer,
  racc_goto_table,
  racc_goto_check,
  racc_goto_default,
  racc_goto_pointer,
  racc_nt_base,
  racc_reduce_table,
  racc_token_table,
  racc_shift_n,
  racc_reduce_n,
  racc_use_result_var ]

Racc_token_to_s_table = [
  "$end",
  "error",
  "DATETIME",
  "RECEIVED",
  "MADDRESS",
  "RETPATH",
  "KEYWORDS",
  "ENCRYPTED",
  "MIMEVERSION",
  "CTYPE",
  "CENCODING",
  "CDISPOSITION",
  "ADDRESS",
  "MAILBOX",
  "DIGIT",
  "ATOM",
  "\",\"",
  "\":\"",
  "FROM",
  "BY",
  "\"@\"",
  "DOMLIT",
  "VIA",
  "WITH",
  "ID",
  "FOR",
  "\";\"",
  "\"<\"",
  "\">\"",
  "\".\"",
  "QUOTED",
  "TOKEN",
  "\"/\"",
  "\"=\"",
  "$start",
  "content",
  "datetime",
  "received",
  "addrs_TOP",
  "retpath",
  "keys",
  "enc",
  "version",
  "ctype",
  "cencode",
  "cdisp",
  "addr_TOP",
  "mbox",
  "day",
  "hour",
  "zone",
  "from",
  "by",
  "via",
  "with",
  "id",
  "for",
  "received_datetime",
  "received_domain",
  "domain",
  "msgid",
  "received_addrspec",
  "routeaddr",
  "spec",
  "addrs",
  "group_bare",
  "commas",
  "group",
  "addr",
  "mboxes",
  "addr_phrase",
  "local_head",
  "routes",
  "at_domains",
  "local",
  "dots",
  "word",
  "domword",
  "dot_repeat",
  "atom",
  "phrase",
  "params",
  "opt_semicolon",
  "value" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

module_eval(<<'.,.,', 'parser.y', 16)
  def _reduce_1(val, _values)
     val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 17)
  def _reduce_2(val, _values)
     val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 18)
  def _reduce_3(val, _values)
     val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 19)
  def _reduce_4(val, _values)
     val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 20)
  def _reduce_5(val, _values)
     val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 21)
  def _reduce_6(val, _values)
     val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 22)
  def _reduce_7(val, _values)
     val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 23)
  def _reduce_8(val, _values)
     val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 24)
  def _reduce_9(val, _values)
     val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 25)
  def _reduce_10(val, _values)
     val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 26)
  def _reduce_11(val, _values)
     val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 27)
  def _reduce_12(val, _values)
     val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 33)
  def _reduce_13(val, _values)
                      t = Time.gm(val[3].to_i, val[2][0,3], val[1].to_i, 0, 0, 0)
                  (t + val[4] - val[5]).localtime
                
  end
.,.,

# reduce 14 omitted

# reduce 15 omitted

module_eval(<<'.,.,', 'parser.y', 42)
  def _reduce_16(val, _values)
                      (val[0].to_i * 60 * 60) +
                  (val[2].to_i * 60)
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 47)
  def _reduce_17(val, _values)
                      (val[0].to_i * 60 * 60) +
                  (val[2].to_i * 60) +
                  (val[4].to_i)
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 54)
  def _reduce_18(val, _values)
                      timezone_string_to_unixtime(val[0])
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 59)
  def _reduce_19(val, _values)
                      val
                
  end
.,.,

# reduce 20 omitted

module_eval(<<'.,.,', 'parser.y', 65)
  def _reduce_21(val, _values)
                      val[1]
                
  end
.,.,

# reduce 22 omitted

module_eval(<<'.,.,', 'parser.y', 71)
  def _reduce_23(val, _values)
                      val[1]
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 77)
  def _reduce_24(val, _values)
                      join_domain(val[0])
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 81)
  def _reduce_25(val, _values)
                      join_domain(val[2])
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 85)
  def _reduce_26(val, _values)
                      join_domain(val[0])
                
  end
.,.,

# reduce 27 omitted

module_eval(<<'.,.,', 'parser.y', 91)
  def _reduce_28(val, _values)
                      val[1]
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 96)
  def _reduce_29(val, _values)
                      []
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 100)
  def _reduce_30(val, _values)
                      val[0].push val[2]
                  val[0]
                
  end
.,.,

# reduce 31 omitted

module_eval(<<'.,.,', 'parser.y', 107)
  def _reduce_32(val, _values)
                      val[1]
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 111)
  def _reduce_33(val, _values)
                      val[1]
                
  end
.,.,

# reduce 34 omitted

module_eval(<<'.,.,', 'parser.y', 117)
  def _reduce_35(val, _values)
                      val[1]
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 123)
  def _reduce_36(val, _values)
                      val[0].spec
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 127)
  def _reduce_37(val, _values)
                      val[0].spec
                
  end
.,.,

# reduce 38 omitted

module_eval(<<'.,.,', 'parser.y', 134)
  def _reduce_39(val, _values)
                      val[1]
                
  end
.,.,

# reduce 40 omitted

# reduce 41 omitted

# reduce 42 omitted

# reduce 43 omitted

# reduce 44 omitted

# reduce 45 omitted

# reduce 46 omitted

module_eval(<<'.,.,', 'parser.y', 146)
  def _reduce_47(val, _values)
     [ Address.new(nil, nil) ] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 148)
  def _reduce_48(val, _values)
     val 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 149)
  def _reduce_49(val, _values)
     val[0].push val[2]; val[0] 
  end
.,.,

# reduce 50 omitted

# reduce 51 omitted

module_eval(<<'.,.,', 'parser.y', 156)
  def _reduce_52(val, _values)
                      val
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 160)
  def _reduce_53(val, _values)
                      val[0].push val[2]
                  val[0]
                
  end
.,.,

# reduce 54 omitted

# reduce 55 omitted

module_eval(<<'.,.,', 'parser.y', 168)
  def _reduce_56(val, _values)
                      val[1].phrase = Decoder.decode(val[0])
                  val[1]
                
  end
.,.,

# reduce 57 omitted

module_eval(<<'.,.,', 'parser.y', 176)
  def _reduce_58(val, _values)
                      AddressGroup.new(val[0], val[2])
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 178)
  def _reduce_59(val, _values)
     AddressGroup.new(val[0], []) 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 181)
  def _reduce_60(val, _values)
     val[0].join('.') 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 182)
  def _reduce_61(val, _values)
     val[0] << ' ' << val[1].join('.') 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 186)
  def _reduce_62(val, _values)
                      val[2].routes.replace val[1]
                  val[2]
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 191)
  def _reduce_63(val, _values)
                      val[1]
                
  end
.,.,

# reduce 64 omitted

module_eval(<<'.,.,', 'parser.y', 196)
  def _reduce_65(val, _values)
     [ val[1].join('.') ] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 197)
  def _reduce_66(val, _values)
     val[0].push val[3].join('.'); val[0] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 199)
  def _reduce_67(val, _values)
     Address.new( val[0], val[2] ) 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 200)
  def _reduce_68(val, _values)
     Address.new( val[0], nil ) 
  end
.,.,

# reduce 69 omitted

module_eval(<<'.,.,', 'parser.y', 203)
  def _reduce_70(val, _values)
     (val[1] + 1).times { val[0].push '' }; val[0] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 206)
  def _reduce_71(val, _values)
     val 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 209)
  def _reduce_72(val, _values)
                      val[1].times do
                    val[0].push ''
                  end
                  val[0].push val[2]
                  val[0]
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 217)
  def _reduce_73(val, _values)
     val 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 220)
  def _reduce_74(val, _values)
                      val[1].times do
                    val[0].push ''
                  end
                  val[0].push val[2]
                  val[0]
                
  end
.,.,

# reduce 75 omitted

module_eval(<<'.,.,', 'parser.y', 228)
  def _reduce_76(val, _values)
     val[0] + val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 230)
  def _reduce_77(val, _values)
     val[0].size - 1 
  end
.,.,

# reduce 78 omitted

# reduce 79 omitted

# reduce 80 omitted

# reduce 81 omitted

# reduce 82 omitted

# reduce 83 omitted

# reduce 84 omitted

# reduce 85 omitted

module_eval(<<'.,.,', 'parser.y', 245)
  def _reduce_86(val, _values)
                      val[1] = val[1].spec
                  val.join('')
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 249)
  def _reduce_87(val, _values)
     val 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 250)
  def _reduce_88(val, _values)
     val[0].push val[2]; val[0] 
  end
.,.,

# reduce 89 omitted

module_eval(<<'.,.,', 'parser.y', 253)
  def _reduce_90(val, _values)
     val[0] << ' ' << val[1] 
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 257)
  def _reduce_91(val, _values)
                      val.push nil
                  val
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 262)
  def _reduce_92(val, _values)
                      val
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 267)
  def _reduce_93(val, _values)
                      [ val[0].to_i, val[2].to_i ]
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 272)
  def _reduce_94(val, _values)
                      [ val[0].downcase, val[2].downcase, decode_params(val[3]) ]
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 276)
  def _reduce_95(val, _values)
                      [ val[0].downcase, nil, decode_params(val[1]) ]
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 281)
  def _reduce_96(val, _values)
                      {}
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 285)
  def _reduce_97(val, _values)
                      val[0][ val[2].downcase ] = val[4]
                  val[0]
                
  end
.,.,

# reduce 98 omitted

# reduce 99 omitted

module_eval(<<'.,.,', 'parser.y', 294)
  def _reduce_100(val, _values)
                      val[0].downcase
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 299)
  def _reduce_101(val, _values)
                      [ val[0].downcase, decode_params(val[1]) ]
                
  end
.,.,

# reduce 102 omitted

# reduce 103 omitted

# reduce 104 omitted

# reduce 105 omitted

# reduce 106 omitted

# reduce 107 omitted

# reduce 108 omitted

# reduce 109 omitted

# reduce 110 omitted

def _reduce_none(val, _values)
  val[0]
end

  end   # class Parser
end   # module TMail
