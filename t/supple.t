# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..3\n"; }
END {print "not ok 1\n" unless $loaded;}

use ShiftJIS::CP932::MapUTF;
use ShiftJIS::CP932::MapUTF::Supplements;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

print 1
  && "ABC\x82\xA0" eq
	unicode_to_cp932("ABC\x{00A3}\x{3042}")
  && "ABC\x81\x92\x82\xA0" eq
	unicode_to_cp932(\&to_cp932_supplements, "ABC\x{00A3}\x{3042}")
  ? "ok" : "not ok", " 2\n";

print 1
  && "ABC\x82\xA0" eq
	utf16be_to_cp932("\0A\0B\0C\0\xA3\x30\x42")
  && "ABC\x81\x92\x82\xA0" eq
	utf16be_to_cp932(\&to_cp932_supplements, "\0A\0B\0C\0\xA3\x30\x42")
  ? "ok" : "not ok", " 3\n";

