#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "fmcp932.h"
#include "tocp932.h"

#define PkgName "ShiftJIS::CP932::MapUTF"

#define Is_CP932SNG(i)   (0x00<=(i) && (i)<=0x7F || 0xA1<=(i) && (i)<=0xDF)
#define Is_CP932LED(i)   (0x81<=(i) && (i)<=0x9F || 0xE0<=(i) && (i)<=0xFC)
#define Is_CP932TRL(i)   (0x40<=(i) && (i)<=0x7E || 0x80<=(i) && (i)<=0xFC)

#define Is_CP932SBC(p)   (Is_CP932SNG(*(p)))
#define Is_CP932DBC(p)   (Is_CP932LED(*(p)) && Is_CP932TRL((p)[1]))
#define Is_CP932MBLEN(p) (Is_CP932DBC(p) ? 2 : 1)

#define MaxLenToUni UNISKIP(0xff71)
#define MaxLenToU16 (2)
#define MaxLenFmUni (1)
#define MaxLenFmU16 (1)

/* Perl 5.6.1 ? */
#ifndef uvuni_to_utf8
#define uvuni_to_utf8   uv_to_utf8
#endif /* uvuni_to_utf8 */ 

/* Perl 5.6.1 ? */
#ifndef utf8n_to_uvuni
#define utf8n_to_uvuni  utf8_to_uv
#endif /* utf8n_to_uvuni */ 

static void
sv_cat_retcvref (SV *dst, SV *cv, SV *sv)
{
    dSP;
    int count;
    SV* retsv;
    ENTER;
    SAVETMPS;
    PUSHMARK(SP);
    XPUSHs(sv_2mortal(sv));
    PUTBACK;
    count = call_sv(cv, G_SCALAR);
    SPAGAIN;
    if (count != 1)
	croak("Panic in XS, " PkgName "\n");
    retsv = newSVsv(POPs);
    PUTBACK;
    FREETMPS;
    LEAVE;
    sv_catsv(dst,retsv);
    sv_2mortal(retsv);
}

MODULE = ShiftJIS::CP932::MapUTF	PACKAGE = ShiftJIS::CP932::MapUTF

void
cp932_to_unicode (arg1, arg2=0)
    SV* arg1
    SV* arg2
  PROTOTYPE: $;$
  PREINIT:
    SV *src, *dst, *cvref;
    STRLEN srclen, dstlen, mblen;
    U8 *s, *e, *p, *d, uni[UTF8_MAXLEN + 1];
    UV uv;
    struct leading lb;
  PPCODE:
    cvref = NULL;
    if (items == 2)
	if (SvROK(arg1) && SvTYPE(SvRV(arg1)) == SVt_PVCV)
	    cvref = SvRV(arg1);
	else
	    croak(PkgName " 1st argument is not CODEREF");

    src = cvref ? arg2 : arg1;
    s = (U8*)SvPV(src,srclen);
    e = s + srclen;
    dstlen = srclen * MaxLenToUni + 1;

    dst = newSV(dstlen);
    (void)SvPOK_only(dst);
    SvUTF8_on(dst);

    if (cvref) {
	for (p = s; p < e; p += mblen) {
	    mblen = Is_CP932MBLEN(p);
	    lb = fmcp932_tbl[*p];
	    uv = (lb.tbl != NULL) ? lb.tbl[p[1]] : lb.sbc;
	    if (uv || !*p) {
		(void)uvuni_to_utf8(uni, uv);
		sv_catpvn(dst, (char*)uni, (STRLEN)UNISKIP(uv));
	    }
	    else
		sv_cat_retcvref(dst, cvref, newSVpvn((char*)p, mblen));
	}
    }
    else {
	d = (U8*)SvPVX(dst);
	for (p = s; p < e; p += mblen) {
	    mblen = Is_CP932MBLEN(p);
	    lb = fmcp932_tbl[*p];
	    uv = (lb.tbl != NULL) ? lb.tbl[p[1]] : lb.sbc;
	    if (uv || !*p)
		d = uvuni_to_utf8(d, (UV)uv);
	}
	*d = '\0';
	SvCUR_set(dst, d - (U8*)SvPVX(dst));
    }
    XPUSHs(sv_2mortal(dst));


void
cp932_to_utf16le (arg1, arg2=0)
    SV* arg1
    SV* arg2
  PROTOTYPE: $;$
  ALIAS:
    cp932_to_utf16be = 1
  PREINIT:
    SV *src, *dst, *cvref;
    STRLEN srclen, dstlen, mblen;
    U8 *s, *e, *p, *d, ucs[3];
    UV uv;
    struct leading lb;
  PPCODE:
    cvref = NULL;
    if (items == 2)
	if (SvROK(arg1) && SvTYPE(SvRV(arg1)) == SVt_PVCV)
	    cvref = SvRV(arg1);
	else
	    croak(PkgName " 1st argument is not CODEREF");

    src = cvref ? arg2 : arg1;
    s = (U8*)SvPV(src,srclen);
    e = s + srclen;
    dstlen = srclen * MaxLenToU16 + 1;

    dst = newSV(dstlen);
    (void)SvPOK_only(dst);

    if (cvref) {
	for (p = s; p < e; p += mblen) {
	    mblen = Is_CP932MBLEN(p);
	    lb = fmcp932_tbl[*p];
	    uv = (lb.tbl != NULL) ? lb.tbl[p[1]] : lb.sbc;
	    if (uv || !*p) {
		ucs[1-ix] = (U8)(uv >> 8);
		ucs[ix]   = (U8)(uv & 0xff);
		sv_catpvn(dst, (char*)ucs, 2);
	    }
	    else 
		sv_cat_retcvref(dst, cvref, newSVpvn((char*)p, mblen));
	}
    }
    else {
	d = (U8*)SvPVX(dst);
	for (p = s; p < e; p += mblen) {
	    mblen = Is_CP932MBLEN(p);
	    lb = fmcp932_tbl[*p];
	    uv = (lb.tbl != NULL) ? lb.tbl[p[1]] : lb.sbc;
	    if (uv || !*p) {
		if (ix)
		    *d++ = (U8)(uv >> 8); /* BE */
		*d++ = (U8)(uv & 0xff);
		if (!ix)
		    *d++ = (U8)(uv >> 8); /* LE */
	    }
	}
	*d = '\0';
	SvCUR_set(dst, d - (U8*)SvPVX(dst));
    }
    XPUSHs(sv_2mortal(dst));


void
unicode_to_cp932 (arg1, arg2=0)
    SV* arg1
    SV* arg2
  PROTOTYPE: $;$
  PREINIT:
    SV *src, *dst, *cvref;
    STRLEN srclen, dstlen, retlen;
    U8 *s, *e, *p, *d, mbc[3];
    U16 j, *t;
    UV uv;
  PPCODE:
    cvref = NULL;
    if (items == 2)
	if (SvROK(arg1) && SvTYPE(SvRV(arg1)) == SVt_PVCV)
	    cvref = SvRV(arg1);
	else
	    croak(PkgName " 1st argument is not CODEREF");

    src = cvref ? arg2 : arg1;
    if (!SvUTF8(src)) {
	src = sv_mortalcopy(src);
	sv_utf8_upgrade(src);
    }

    s = (U8*)SvPV(src,srclen);
    e = s + srclen;
    dstlen = srclen * MaxLenFmUni + 1;

    dst = newSV(dstlen);
    (void)SvPOK_only(dst);

    if (cvref) {
	for (p = s; p < e;) {
	    uv = utf8n_to_uvuni(p, e - p, &retlen, 0);
	    p += retlen;
	    t = uv < 0x10000 ? tocp932_tbl[uv >> 8] : NULL;
	    j = t ? t[uv & 0xff] : 0;

	    if (j || !uv) {
		if (j >= 256) {
		    mbc[0] = (U8)(j >> 8);
		    mbc[1] = (U8)(j & 0xff);
		    sv_catpvn(dst, (char*)mbc, 2);
		}
		else {
		    mbc[0] = (U8)(j & 0xff);
		    sv_catpvn(dst, (char*)mbc, 1);
		}
	    }
	    else
		sv_cat_retcvref(dst, cvref, newSVuv(uv));
	}
    }
    else {
	d = (U8*)SvPVX(dst);
	for (p = s; p < e;) {
	    uv = utf8n_to_uvuni(p, e - p, &retlen, 0);
	    p += retlen;
	    t = uv < 0x10000 ? tocp932_tbl[uv >> 8] : NULL;
	    j = t ? t[uv & 0xff] : 0;
	    if (j || !uv) {
		if (j >= 256)
		    *d++ = (U8)(j >> 8);
		*d++ = (U8)(j & 0xff);
	    }
	}
	*d = '\0';
	SvCUR_set(dst, d - (U8*)SvPVX(dst));
    }
    XPUSHs(sv_2mortal(dst));


void
utf16le_to_cp932 (arg1, arg2=0)
    SV* arg1
    SV* arg2
  PROTOTYPE: $;$
  ALIAS:
    utf16be_to_cp932 = 1
  PREINIT:
    SV *src, *dst, *cvref;
    STRLEN srclen, dstlen;
    U8 *s, *e, *p, *d, row, cell, mbc[3];
    U16 j, *t;
    UV uv, luv;
  PPCODE:
    cvref = NULL;
    if (items == 2)
	if (SvROK(arg1) && SvTYPE(SvRV(arg1)) == SVt_PVCV)
	    cvref = SvRV(arg1);
	else
	    croak(PkgName " 1st argument is not CODEREF");

    src = cvref ? arg2 : arg1;
    s = (U8*)SvPV(src,srclen);
    e = s + srclen;
    dstlen = srclen * MaxLenFmU16 + 1;

    dst = newSV(dstlen);
    (void)SvPOK_only(dst);

    if (cvref) {
	for (p = s; p < e; p += 2) {
	    row  = ix ? p[0] : p[1];
	    cell = ix ? p[1] : p[0];
	    if (p + 1 == e) /* odd byte */
		break;
	    t = tocp932_tbl[row];
	    j = t ? t[cell] : 0;
	    if (j || (!row && !cell)) {
		if (j >= 256) {
		    mbc[0] = (U8)(j >> 8);
		    mbc[1] = (U8)(j & 0xff);
		    sv_catpvn(dst, (char*)mbc, 2);
		}
		else {
		    mbc[0] = (U8)(j & 0xff);
		    sv_catpvn(dst, (char*)mbc, 1);
		}
	    }
	    else {
		uv = (UV)((row << 8) | cell);
		if (0xD800 <= uv && uv <= 0xDBFF && p + 4 <= e) {
		    row  = ix ? p[2] : p[3];
		    cell = ix ? p[3] : p[2];
		    luv = (row << 8) | cell;
		    if (0xDC00 <= luv && luv <= 0xDFFF) {
			uv = 0x10000 + ((uv-0xD800) * 0x400) + (luv-0xDC00);
			p += 2;
		    }
		}
		sv_cat_retcvref(dst, cvref, newSVuv(uv));
	    }
	}
    } else {
	d = (U8*)SvPVX(dst);
	for (p = s; p < e; p += 2) {
	    row  = ix ? p[0] : p[1];
	    cell = ix ? p[1] : p[0];
	    if (p + 1 == e) /* odd byte */
		break;
	    t = tocp932_tbl[row];
	    j = t ? t[cell] : 0;
	    if (j || (!row && !cell)) {
		if (j >= 256)
		    *d++ = (U8)(j >> 8);
		*d++ = (U8)(j & 0xff);
	    }
	}
	*d = '\0';
	SvCUR_set(dst, d - (U8*)SvPVX(dst));
    }
    XPUSHs(sv_2mortal(dst));

