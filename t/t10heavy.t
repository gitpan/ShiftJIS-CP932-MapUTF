
BEGIN { $| = 1; print "1..11\n"; }
END {print "not ok 1\n" unless $loaded;}

use ShiftJIS::CP932::MapUTF qw(:all);
$^W = 1;
$loaded = 1;
print "ok 1\n";

$hasUnicode = defined &cp932_to_unicode;
$hasPerlUni = $] > 5.006;

sub hexNCR {
    my ($char, $byte) = @_;
    return sprintf("&#x%x;", $char) if defined $char;
    die sprintf "illegal byte 0x%02x was found", $byte;
}

##### 2..7

my @hangul = 0xAC00..0xD7AF;
my $h_u16l = pack 'v*', @hangul;
my $h_u16b = pack 'n*', @hangul;
my $h_u32l = pack 'V*', @hangul;
my $h_u32b = pack 'N*', @hangul;
my $h_uni  = $hasUnicode ? pack 'U*', @hangul : "";
my $h_utf8 = $hasPerlUni ? pack 'a*', pack 'U*', @hangul : "";
my $h_ncr  = join '', map sprintf("&#x%x;", $_), @hangul;

print $h_ncr eq utf16le_to_cp932(\&hexNCR, $h_u16l)
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print $h_ncr eq utf16be_to_cp932(\&hexNCR, $h_u16b)
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print $h_ncr eq utf32le_to_cp932(\&hexNCR, $h_u32l)
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print $h_ncr eq utf32be_to_cp932(\&hexNCR, $h_u32b)
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print !$hasUnicode || $h_ncr eq unicode_to_cp932(\&hexNCR, $h_uni)
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print !$hasPerlUni || $h_ncr eq utf8_to_cp932(\&hexNCR, $h_utf8)
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

##### 8..11

my @overbmp = map $_ * 0x100, 0x100..0x10FF;
my $o_u32l = pack 'V*', @overbmp;
my $o_u32b = pack 'N*', @overbmp;
my $o_uni  = $hasUnicode ? pack 'U*', @overbmp : "";
my $o_utf8 = $hasPerlUni ? pack 'a*', pack 'U*', @overbmp : "";
my $o_ncr  = join '', map sprintf("&#x%x;", $_), @overbmp;

print $o_ncr eq utf32le_to_cp932(\&hexNCR, $o_u32l)
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print $o_ncr eq utf32be_to_cp932(\&hexNCR, $o_u32b)
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print !$hasUnicode || $o_ncr eq unicode_to_cp932(\&hexNCR, $o_uni)
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

print !$hasPerlUni || $o_ncr eq utf8_to_cp932(\&hexNCR, $o_utf8)
    ? "ok" : "not ok" , " ", ++$loaded, "\n";

1;
__END__

