# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..17\n"; }
END {print "not ok 1\n" unless $loaded;}

use ShiftJIS::CP932::MapUTF;
$loaded = 1;
print "ok 1\n";

my $repeat = 1000;

sub normalize_cp932 {
  utf16le_to_cp932(cp932_to_utf16le(shift));
}

######################### End of black magic.

print 1
  && "" eq cp932_to_utf16le("")
  && "A\x00B\x00C\x00"		eq cp932_to_utf16le("ABC")
  && "A\x00B\x00C\x00\n\x00"	eq cp932_to_utf16le("ABC\n")
  && "" eq cp932_to_utf16be("")
  && "\x00A\x00B\x00C"		eq cp932_to_utf16be("ABC")
  && "\x00A\x00B\x00C\x00\n"	eq cp932_to_utf16be("ABC\n")
  ? "ok" : "not ok", " 2\n";

print 1
   && "" eq utf16be_to_cp932("")
   && "\n\n" eq utf16be_to_cp932("\x00\n\x00\n")
   && "\x82\xa0\x82\xa2\x82\xa4\x81\xe0\x82\xa6\x82\xa8" eq
 utf16be_to_cp932("\xfe\xff\x30\x42\x30\x44\x30\x46\x22\x52\x30\x48\x30\x4a")
   && "" eq utf16le_to_cp932("")
   && "\n\n" eq utf16le_to_cp932("\n\x00\n\x00")
   && "\x82\xa0\x82\xa2\x82\xa4\x81\xe0\x82\xa6\x82\xa8" eq
 utf16le_to_cp932("\xff\xfe\x42\x30\x44\x30\x46\x30\x52\x22\x48\x30\x4a\x30")
  ? "ok" : "not ok", " 3\n";

print 1
  && "\x42\x30\x44\x30\x46\x30\x48\x30\x4a\x30" eq
     cp932_to_utf16le("\x82\xa0\x82\xa2\x82\xa4\x82\xa6\x82\xa8")
  && "\x30\x42\x30\x44\x30\x46\x30\x48\x30\x4a" eq
     cp932_to_utf16be("\x82\xa0\x82\xa2\x82\xa4\x82\xa6\x82\xa8")
  ? "ok" : "not ok", " 4\n";

my $uni
    = pack('U*', 0x6f22, 0x5b57) . "\n"
    . pack('U*', 0x0050, 0x0065, 0x0072, 0x006c, 0x2252) . "\n"
    . pack('U*', 0xFF8C, 0xFF9F, 0xFF9B, 0xFF78, 0xFF9E)
    . pack('U*', 0xFF97, 0xFF90, 0xFF9D, 0xFF78, 0xFF9E) . "\n";

my $cp932 = "\x8a\xbf\x8e\x9a\n\x50\x65\x72\x6c\x81\xe0\n"
    . "\xcc\xdf\xdb\xb8\xde\xd7\xd0\xdd\xb8\xde\n";

print ""	eq unicode_to_cp932("")
  && "\n\n"	eq unicode_to_cp932("\n\n")
  && $cp932	eq unicode_to_cp932($uni)
  && "$cp932\n" eq unicode_to_cp932("$uni\n")
  ? "ok" : "not ok", " 5\n";

print ""	eq cp932_to_unicode("")
  && "\n\n"	eq cp932_to_unicode("\n\n")
  && $uni	eq cp932_to_unicode($cp932)
  && "$uni\n"	eq cp932_to_unicode("$cp932\n")
  ? "ok" : "not ok", " 6\n";

my($NG);
my %dbl = (
  0x8140=>0x8140, 0x82A0=>0x82A0, 0x889F=>0x889F, 0x989F=>0x989F,
  0x879C=>0x81BE, 0x879B=>0x81BF, 0xEEF9=>0x81CA, 0xFA54=>0x81CA,
  0x8797=>0x81DA, 0x8796=>0x81DB, 0x8791=>0x81DF, 0x8790=>0x81E0,
  0x8795=>0x81E3, 0x879A=>0x81E6, 0xFA5B=>0x81E6, 0x8792=>0x81E7,
);

$NG = 0;
foreach(keys %dbl){
  $NG++ if pack('n',$dbl{$_}) ne normalize_cp932(pack 'n',$_);
}
print !$NG ? "ok" : "not ok", " 7\n";

my $vu_sjis = "abc\x82\xf2pqr\x82\xf2xyz";
my $vu_uni  = "abc".pack('U', 0x3094)."pqr".pack('U', 0x3094)."xyz";
my $vu_16l  = "a\x00b\x00c\x00\x94\x30p\x00q\x00r\x00\x94\x30x\x00y\x00z\x00";
my $vu_16b  = "\x00a\x00b\x00c\x30\x94\x00p\x00q\x00r\x30\x94\x00x\x00y\x00z";
my $vu_ncr  = "abc&#x3094;pqr&#x3094;xyz";

my $code_uni = sub { $_[0] eq "\x82\xf2" ? pack('U', 0x3094) : "" };
my $code_16l = sub { $_[0] eq "\x82\xf2" ? pack('v', 0x3094) : "" };
my $code_16b = sub { $_[0] eq "\x82\xf2" ? pack('n', 0x3094) : "" };
my $code_vn  = sub { $_[0] eq "\x82\xf2" ? "HIRAGANA LETTER VU" : "" };
my $code_ncr = sub { sprintf "&#x%04x;", shift };
my $code_vu  = sub { $_[0] == 0x3094 ? "\x82\xf2" : "" };

sub hexNCR { sprintf "&#x%04x;", shift }

print $vu_uni  eq cp932_to_unicode($code_uni,  $vu_sjis)
   && $vu_16l  eq cp932_to_utf16le($code_16l,  $vu_sjis)
   && $vu_16b  eq cp932_to_utf16be($code_16b,  $vu_sjis)
   && $vu_ncr  eq unicode_to_cp932($code_ncr,  $vu_uni)
   && $vu_ncr  eq utf16le_to_cp932($code_ncr,  $vu_16l)
   && $vu_ncr  eq utf16be_to_cp932($code_ncr,  $vu_16b)
   && $vu_sjis eq unicode_to_cp932($code_vu,   $vu_uni)
   && $vu_sjis eq utf16le_to_cp932($code_vu,   $vu_16l)
   && $vu_sjis eq utf16be_to_cp932($code_vu,   $vu_16b)
  ? "ok" : "not ok", " 8\n";

print 1
  && "&#x10000;abc&#x12345;xyz&#x10ffff;" eq
     utf16le_to_cp932(\&hexNCR,
        "\x00\xd8\x00\xdc\x61\x00\x62\x00\x63\x00\x08\xD8\x45\xDF"
      . "\x78\x00\x79\x00\x7a\x00\xff\xdb\xff\xdf")
  && "&#x10000;abc&#x12345;xyz&#x10ffff;" eq
     utf16be_to_cp932(\&hexNCR,
        "\xd8\x00\xdc\x00\x00\x61\x00\x62\x00\x63\xD8\x08\xDF\x45"
      . "\x00\x78\x00\x79\x00\x7a\xdb\xff\xdf\xff")
  ? "ok" : "not ok", " 9\n";


print "&#x00ff;\x81\x93\x83\xbf&#xacde;" x $repeat eq
  utf16le_to_cp932(\&hexNCR, "\xff\x00\x05\xff\xB1\x03\xde\xAC" x $repeat)
  ? "ok" : "not ok", " 10\n";

print "&#x00ff;\x81\x93\x83\xbf&#xacde;" x $repeat eq
  unicode_to_cp932(\&hexNCR, "\x{ff}\x{ff05}\x{03B1}\x{acde}" x $repeat)
  ? "ok" : "not ok", " 11\n";

print "\x81\x7E\x00\x81\x80\0\x41" eq unicode_to_cp932("\xd7\x00\xf7\0\x41")
  ? "ok" : "not ok", " 12\n";

print "\x{ff71}\x{ff72}\x{ff73}\x{ff74}\x{ff75}" x $repeat eq
  cp932_to_unicode("\xb1\xb2\xb3\xb4\xb5" x $repeat) # han-kana
  ? "ok" : "not ok", " 13\n";

print "&#x00ff;\x81\x93\x83\xbf&#xacde;" x $repeat eq
  unicode_to_cp932(\&hexNCR, "\x{ff}\x{ff05}\x{03B1}\x{acde}" x $repeat)
  ? "ok" : "not ok", " 14\n";

print "\x81\x4c\x81\x4e\x81\x7d\x81\x7e\x81\x80" x $repeat eq
  unicode_to_cp932("\xb4\xa8\xb1\xd7\xf7" x $repeat) # latin 1
  ? "ok" : "not ok", " 15\n";

print "HIRAGANA LETTER VU" x $repeat eq
  cp932_to_unicode($code_vn, "\x82\xf2" x $repeat)
  ? "ok" : "not ok", " 16\n";

# "HI" is not ASCII 'H' and 'I'; This is UTF-16.
print "HIRAGANA LETTER VU" x $repeat eq
  cp932_to_utf16be($code_vn, "\x82\xf2" x $repeat)
  ? "ok" : "not ok", " 17\n";

