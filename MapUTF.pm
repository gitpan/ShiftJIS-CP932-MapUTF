package ShiftJIS::CP932::MapUTF;

require 5.006;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require DynaLoader;
require AutoLoader;

@ISA = qw(Exporter DynaLoader);

@EXPORT = qw(
    cp932_to_unicode cp932_to_utf16le cp932_to_utf16be
    unicode_to_cp932 utf16le_to_cp932 utf16be_to_cp932
);
@EXPORT_OK = ();

$VERSION = '0.13';

bootstrap ShiftJIS::CP932::MapUTF $VERSION;

1;
__END__

=head1 NAME

ShiftJIS::CP932::MapUTF - conversion between Microsoft Windows CP-932 and Unicode

=head1 SYNOPSIS

    use ShiftJIS::CP932::MapUTF;

    $unicode_string  = cp932_to_unicode($cp932_string);

=head1 DESCRIPTION

The Microsoft Windows CodePage 932 (CP-932) table comprises 7915 characters:

    JIS X 0201:1997 single-byte characters (159 characters),
    JIS X 0211:1994 single-byte characters (32 characters),
    JIS X 0208:1997 double-byte characters (6879 characters),
    NEC special characters (83 characters in SJIS row 13),
    NEC-selected IBM extended characters (374 characters in SJIS rows 89..92),
    and IBM extended characters (388 characters in SJIS rows 115..119).

It contains duplicates that do not round trip
map. These duplicates are due to the characters defined
by vendors, NEC and IBM.

For example, there are two characters that are mapped to U+2252;
i.e., 0x81e0 (a JIS X 0208 character) and 0x8790 (an NEC special character).

This module provides some functions to map
from Windows CP-932 to Unicode, and vice versa.

=over 4

=item C<cp932_to_unicode(STRING)>

=item C<cp932_to_unicode(CODEREF, STRING)>

Converts Windows CP-932 to Unicode
(UTF-8/UTF-EBCDIC as a Unicode-oriented perl knows).

For example, converts C<\x81\xe0> or C<\x87\x90> to C<U+2252> in Unicode.

Characters unmapped to Unicode are deleted,
if C<CODEREF> is not specified;
otherwise, converted using the C<CODEREF>
from the Windows CP-932 character string.

For example, converts C<\x82\xf2> to C<U+3094>, C<HIRAGANA LETTER VU>, in Unicode.

   cp932_to_unicode(
       sub { $_[0] eq "\x82\xf2" ? "\x{3094}" : "" },
       $cp932_string
   );

=item C<cp932_to_utf16be(STRING)>

=item C<cp932_to_utf16be(CODEREF, STRING)>

Converts Windows CP-932 to UTF-16BE.

=item C<cp932_to_utf16le(STRING)>

=item C<cp932_to_utf16le(CODEREF, STRING)>

Converts Windows CP-932 to UTF-16LE.

For example, converts C<\x81\xe0> or C<\x87\x90> to C<U+2252>
in the UTF-16LE encoding.

Characters unmapped to Unicode are deleted,
if C<CODEREF> is not specified;
otherwise, converted using the C<CODEREF>
from the Windows CP-932 character string.

For example, converts C<\x82\xf2> to C<U+3094>, C<HIRAGANA LETTER VU>,
in the UTF-16LE encoding.

   cp932_to_utf16le(
      sub { $_[0] eq "\x82\xf2" ? "\x94\x30" : "" },
      $cp932_string
   );

=item C<unicode_to_cp932(STRING)>

=item C<unicode_to_cp932(CODEREF, STRING)>

Converts Unicode (UTF-8/UTF-EBCDIC as a Unicode-oriented perl knows)
to Windows CP-932 (normalized).

For example, C<U+2252> in the Unicode is converted
to C<\x81\xe0>, not to C<\x87\x90>.

Characters unmapped to Windows CP-932 are deleted,
if C<CODEREF> is not specified;
otherwise, converted using the C<CODEREF>
from its Unicode codepoint (integer).

For example, characters unmapped to Windows CP-932 are
converted to numerical character references for HTML 4.01.

    unicode_to_cp932(sub {sprintf "&#x%04x;", shift}, $unicode_string);

=item C<utf16be_to_cp932(STRING)>

=item C<utf16be_to_cp932(CODEREF, STRING)>

Converts UTF-16BE to Windows CP-932 (normalized).

=item C<utf16le_to_cp932(STRING)>

=item C<utf16le_to_cp932(CODEREF, STRING)>

Converts UTF-16LE to Windows CP-932 (normalized).

For example, C<U+2252> in the UTF-16LE encoding is converted
to C<\x81\xe0>, not to C<\x87\x90>.

Characters unmapped to Windows CP-932 are deleted,
if C<CODEREF> is not specified;
otherwise, converted using the C<CODEREF>
from its Unicode codepoint (integer).

For example, characters unmapped to Windows CP-932
are converted to numerical character references for HTML 4.01.

    utf16le_to_cp932(sub {sprintf "&#x%04x;", shift}, $utf16LE_string);

=back

=head1 CAVEAT

This module up to version 0.07 had treated with "encoded UTF-8",
via C<cp932_to_utf8()> and C<utf8_to_cp932()>,
but these functions are obsolete.

=head1 AUTHOR

Tomoyuki SADAHIRO

  bqw10602@nifty.com
  http://homepage1.nifty.com/nomenclator/perl/

  Copyright(C) 2001-2002, SADAHIRO Tomoyuki. Japan. All rights reserved.

This module is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

=over 4

=item Microsoft PRB, Article ID: Q170559

Conversion Problem Between Shift-JIS and Unicode

=item ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP932.TXT

cp932 to Unicode table

=back

=cut
