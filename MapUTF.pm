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

$VERSION = '0.10';

bootstrap ShiftJIS::CP932::MapUTF $VERSION;

1;
__END__


=head1 NAME

ShiftJIS::CP932::MapUTF - Conversion between Microsoft CP-932 and Unicode

=head1 SYNOPSIS

  use ShiftJIS::CP932::MapUTF;

  $unicode_string  = cp932_to_unicode($cp932_string);

=head1 DESCRIPTION

The Microsoft CodePage 932 (CP-932) table comprises 7915 characters:

  JIS X 0201-1976 single-byte characters (191 characters),
  JIS X 0208-1990 double-byte characters (6879 characters),
  NEC special characters (83 characters from SJIS row 13),
  NEC-selected IBM extended characters (374 characters from SJIS row 89 to 92),
  and IBM extended characters (388 characters from SJIS row 115 to 119).

It contains duplicates that do not round trip
map. These duplicates are due to the characters defined
by vendors, NEC and IBM.

For example, there are two characters that are mapped to U+2252,
namely, 0x81e0 (JIS X 0208) and 0x8790 (NEC special character).

This module provides some functions to maps
from CP-932 to Unicode, and vice versa. 

=over 4

=item C<cp932_to_unicode(STRING)>

=item C<cp932_to_unicode(CODEREF, STRING)>

Converts CP-932 to Unicode (UTF-8/UTF-EBCDIC as a Unicode-oriented perl knows).

For example, converts C<\x81\xe0> or C<\x87\x90> to C<U+2252>
in the Unicode.

Characters unmapped to Unicode, if C<CODEREF> is not specified, are deleted;
if C<CODEREF> is specified, 
converted using C<CODEREF> from the CP-932 character string.

For example, converts C<\x82\xf2> to C<U+3094>, C<HIRAGANA LETTER VU>,
in the Unicode.

   cp932_to_unicode(
       sub { $_[0] eq "\x82\xf2" ? "\x{3094}" : "" },
       $cp932_string
   );

=item C<cp932_to_utf16be(STRING)>

=item C<cp932_to_utf16be(CODEREF, STRING)>

Converts CP-932 to UTF-16BE.

=item C<cp932_to_utf16le(STRING)>

=item C<cp932_to_utf16le(CODEREF, STRING)>

Converts CP-932 to UTF-16LE.

For example, converts C<\x81\xe0> or C<\x87\x90> to C<U+2252>
in the UTF-16LE encoding.

Characters unmapped to Unicode, if C<CODEREF> is not specified, are deleted;
if C<CODEREF> is specified,
converted using C<CODEREF> from the CP-932 character string.

For example, converts C<\x82\xf2> to C<U+3094>, C<HIRAGANA LETTER VU>,
in the UTF-16LE encoding.

   cp932_to_utf16le(
      sub { $_[0] eq "\x82\xf2" ? "\x94\x30" : "" },
      $cp932_string
   );

=item C<unicode_to_cp932(STRING)>

=item C<unicode_to_cp932(CODEREF, STRING)>

Converts Unicode (UTF-8/UTF-EBCDIC as a Unicode-oriented perl knows) 
to CP-932 (normalized).

For example, C<U+2252> in the Unicode is converted
to C<\x81\xe0>, not to C<\x87\x90>.

Characters unmapped to CP-932, if C<CODEREF> is not specified, are deleted;
if C<CODEREF> is specified, 
converted using C<CODEREF> from its Unicode codepoint (integer).

For example, characters unmapped to CP-932 are 
converted to numerical character references for HTML 4.01.

    unicode_to_cp932(sub {sprintf "&#x%04x;", shift}, $unicode_string);

=item C<utf16be_to_cp932(STRING)>

=item C<utf16be_to_cp932(CODEREF, STRING)>

Converts C<UTF-16BE> to C<CP-932> (normalized).

=item C<utf16le_to_cp932(STRING)>

=item C<utf16le_to_cp932(CODEREF, STRING)>

Converts C<UTF-16LE> to C<CP-932> (normalized).

For example, C<U+2252> in the C<UTF-16LE> encoding is converted
to C<\x81\xe0>, not to C<\x87\x90>.

Characters unmapped to CP-932, if C<CODEREF> is not specified, are deleted;
if C<CODEREF> is specified,
converted using C<CODEREF> from its Unicode codepoint (integer).

For example, characters unmapped to CP-932 are 
converted to numerical character references for HTML 4.01.

    utf16le_to_cp932(sub {sprintf "&#x%04x;", shift}, $utf16LE_string);

=back

=head1 CAVEAT

This module up to version 0.07 treats with "encoded UTF-8",
by C<cp932_to_utf8()> and C<utf8_to_cp932()>,
but these functions are obsolete.

=head1 AUTHOR

Tomoyuki SADAHIRO

  bqw10602@nifty.com
  http://homepage1.nifty.com/nomenclator/perl/

  Copyright(C) 2001, SADAHIRO Tomoyuki. Japan. All rights reserved.

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

=head1 SEE ALSO

=over 4

=item Microsoft PRB: Conversion Problem Between Shift-JIS and Unicode (Article ID: Q170559)

=item ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP932.TXT

=item L<perlunicode>

=item L<utf8>

=item L<ShiftJIS::CP932::Correct>

=back

=cut

