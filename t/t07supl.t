
BEGIN { $| = 1; print "1..19\n"; }
END {print "not ok 1\n" unless $loaded;}

use ShiftJIS::CP932::MapUTF qw(:all);
use ShiftJIS::CP932::MapUTF::Supplements;

my $hasUnicode = defined &cp932_to_unicode;

$loaded = 1;
print "ok 1\n";

my $uniStr = $hasUnicode ? "ABC".pack('U*', 0xA3, 0x3042) : "";

print !$hasUnicode || "ABC\x82\xA0" eq unicode_to_cp932($uniStr)
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print !$hasUnicode || "ABC\x81\x92\x82\xA0" eq
	unicode_to_cp932(\&to_cp932_supplements, $uniStr)
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print "ABC\x82\xA0" eq utf8_to_cp932("ABC\xC2\xA3\xE3\x81\x82")
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print "ABC\x81\x92\x82\xA0" eq
	utf8_to_cp932(\&to_cp932_supplements, "ABC\xC2\xA3\xE3\x81\x82")
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print "ABC\x82\xA0" eq utf16le_to_cp932("A\0B\0C\0\xA3\0\x42\x30")
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print "ABC\x81\x92\x82\xA0" eq
	utf16le_to_cp932(\&to_cp932_supplements, "A\0B\0C\0\xA3\0\x42\x30")
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print "ABC\x81\x92\x82\xA0" eq
	utf16le_to_cp932(\&to_cp932_supplements, "A\0B\0C\0\xA3\0\x42\x30\x00")
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print "ABC\x82\xA0" eq utf16be_to_cp932("\0A\0B\0C\0\xA3\x30\x42")
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print "ABC\x81\x92\x82\xA0" eq
	utf16be_to_cp932(\&to_cp932_supplements, "\0A\0B\0C\0\xA3\x30\x42")
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print "ABC\x81\x92\x82\xA0" eq
	utf16be_to_cp932(\&to_cp932_supplements, "\0A\0B\0C\0\xA3\x30\x42\x00")
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print "ABC\x82\xA0" eq
	utf32le_to_cp932("A\0\0\0B\0\0\0C\0\0\0\xA3\0\0\0\x42\x30\0\0")
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print "ABC\x81\x92\x82\xA0" eq utf32le_to_cp932(\&to_cp932_supplements,
	"A\0\0\0B\0\0\0C\0\0\0\xA3\0\0\0\x42\x30\0\0")
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print "ABC\x81\x92\x82\xA0" eq utf32le_to_cp932(\&to_cp932_supplements,
	"A\0\0\0B\0\0\0C\0\0\0\xA3\0\0\0\x42\x30\0\0\x00")
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print "ABC\x81\x92\x82\xA0" eq utf32le_to_cp932(\&to_cp932_supplements,
	"A\0\0\0B\0\0\0C\0\0\0\xA3\0\0\0\x42\x30\0\0\x00\x01")
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print "ABC\x82\xA0" eq
	utf32be_to_cp932("\0\0\0A\0\0\0B\0\0\0C\0\0\0\xA3\0\0\x30\x42")
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print "ABC\x81\x92\x82\xA0" eq utf32be_to_cp932(\&to_cp932_supplements,
	"\0\0\0A\0\0\0B\0\0\0C\0\0\0\xA3\0\0\x30\x42")
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print "ABC\x81\x92\x82\xA0" eq utf32be_to_cp932(\&to_cp932_supplements,
	"\0\0\0A\0\0\0B\0\0\0C\0\0\0\xA3\0\0\x30\x42\x00")
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print "ABC\x81\x92\x82\xA0" eq utf32be_to_cp932(\&to_cp932_supplements,
	"\0\0\0A\0\0\0B\0\0\0C\0\0\0\xA3\0\0\x30\x42\x00\x01")
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

