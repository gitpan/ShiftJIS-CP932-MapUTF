# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..8\n"; }
END {print "not ok 1\n" unless $loaded;}

use ShiftJIS::CP932::MapUTF;
$loaded = 1;
print "ok 1\n";

sub normalize_cp932 {
  utf16_to_cp932(cp932_to_utf16(shift));
}

######################### End of black magic.

print "" eq cp932_to_utf16("")
  && "A\x00B\x00C\x00" eq cp932_to_utf16("ABC")
  && "A\x00B\x00C\x00\n\x00" eq cp932_to_utf16("ABC\n")
  ? "ok" : "not ok", " 2\n";

print "" eq utf16_to_cp932("") 
  && "\n\n" eq utf16_to_cp932("\n\x00\n\x00")
  && "\x82\xa0\x82\xa2\x82\xa4\x81\xe0\x82\xa6\x82\xa8"
  eq utf16_to_cp932("\xff\xfe\x42\x30\x44\x30\x46\x30\x52\x22\x48\x30\x4a\x30")
  ? "ok" : "not ok", " 3\n";

print "\x42\x30\x44\x30\x46\x30\x48\x30\x4a\x30"
  eq cp932_to_utf16("\x82\xa0\x82\xa2\x82\xa4\x82\xa6\x82\xa8")
  ? "ok" : "not ok", " 4\n";

my $utf8 = 
      "\xe6\xbc\xa2\xe5\xad\x97\n\x50\x65\x72\x6c\xe2\x89\x92\n"
    . "\xEF\xBE\x8C\xEF\xBE\x9F\xEF\xBE\x9B\xEF\xBD\xB8"
    . "\xEF\xBE\x9E\xEF\xBE\x97\xEF\xBE\x90\xEF\xBE\x9D"
    . "\xEF\xBD\xB8\xEF\xBE\x9E\n";

my $cp932 = "\x8a\xbf\x8e\x9a\n\x50\x65\x72\x6c\x81\xe0\n"
    . "\xcc\xdf\xdb\xb8\xde\xd7\xd0\xdd\xb8\xde\n";

print "" eq utf8_to_cp932("")
  && "\n\n" eq utf8_to_cp932("\n\n")
  && $cp932 eq utf8_to_cp932($utf8)
  && $cp932."\n" eq utf8_to_cp932($utf8."\n")
  ? "ok" : "not ok", " 5\n";

print "" eq cp932_to_utf8("")
  && "\n\n" eq cp932_to_utf8("\n\n")
  && $utf8 eq cp932_to_utf8($cp932)
  && $utf8."\n" eq cp932_to_utf8($cp932."\n")
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

my $vu_sjis = "abc\x82\xf2xyz";
my $vu_utf8 = "abc\xE3\x82\x94xyz";

print $vu_utf8 eq cp932_to_utf8 (
   sub { $_[0] eq "\x82\xf2" ? "\xE3\x82\x94" : "" },
   $vu_sjis)

  && "abc&#x3094;xyz" eq 
    utf8_to_cp932(sub {sprintf "&#x%04x;", shift}, $vu_utf8)
  ? "ok" : "not ok", " 8\n";

