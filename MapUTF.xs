#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "scmuni.h"

#include "fmcp932.h"
#include "tocp932.h"

#define PkgName "ShiftJIS::CP932::MapUTF"

#define Is_CP932SNG(i)   (0x00<=(i) && (i)<=0x7F || 0xA1<=(i) && (i)<=0xDF)
#define Is_CP932LED(i)   (0x81<=(i) && (i)<=0x9F || 0xE0<=(i) && (i)<=0xFC)
#define Is_CP932TRL(i)   (0x40<=(i) && (i)<=0x7E || 0x80<=(i) && (i)<=0xFC)

#define Is_CP932SBC(p)   (Is_CP932SNG(*(p)))
#define Is_CP932DBC(p)   (Is_CP932LED(*(p)) && Is_CP932TRL((p)[1]))
#define Is_CP932MBLEN(p) (Is_CP932DBC(p) ? 2 : 1)

#define STMT_ASSIGN_CVREF_AND_SRC				\
    cvref = NULL;						\
    if (items == 2)						\
	if (SvROK(arg1) && SvTYPE(SvRV(arg1)) == SVt_PVCV)	\
	    cvref = SvRV(arg1);					\
	else							\
	    croak(PkgName " 1st argument is not CODEREF");	\
    src = cvref ? arg2 : arg1;


#define STMT_ASSIGN_LENDST(maxlen)		\
    s = (U8*)SvPV(src,srclen);			\
    e = s + srclen;				\
    dstlen = srclen * maxlen + 1;		\
    dst = sv_2mortal(newSV(dstlen));		\
    (void)SvPOK_only(dst);


#define STMT_GET_UV_FROM_MB			\
    mblen = Is_CP932MBLEN(p);			\
    lb = fmcp932_tbl[*p];			\
    uv = lb.tbl ? lb.tbl[p[1]] : lb.sbc;


/* Perl 5.6.1 ? */
#ifndef uvuni_to_utf8
#define uvuni_to_utf8   uv_to_utf8
#endif /* uvuni_to_utf8 */ 

/* Perl 5.6.1 ? */
#ifndef utf8n_to_uvuni
#define utf8n_to_uvuni  utf8_to_uv
#endif /* utf8n_to_uvuni */ 

static void
sv_cat_retcvref (SV *dst, SV *cv, SV *sv, bool isbyte)
{
    dSP;
    int count;
    ENTER;
    SAVETMPS;
    PUSHMARK(SP);
    if (isbyte)
	XPUSHs(&PL_sv_undef);
    XPUSHs(sv_2mortal(sv));
    PUTBACK;
    count = call_sv(cv, G_SCALAR);
    SPAGAIN;
    if (count != 1)
	croak("Panic in XS, " PkgName "\n");
    sv_catsv(dst,POPs);
    PUTBACK;
    FREETMPS;
    LEAVE;
}

static STRLEN maxlen_fm[] = {
    MaxLenFmU8,
    MaxLenFmU16,
    MaxLenFmU16,
    MaxLenFmU32,
    MaxLenFmU32,
};

static STRLEN maxlen_to[] = {
    MaxLenToU8,
    MaxLenToU16,
    MaxLenToU16,
    MaxLenToU32,
    MaxLenToU32,
};

static STRLEN (*app_uv_in[])(U8 *, UV) = {
    app_in_utf8,
    app_in_utf16le,
    app_in_utf16be,
    app_in_utf32le,
    app_in_utf32be,
};

static STRLEN (*ord_uv_in[])(U8 *, STRLEN, STRLEN *) = {
    ord_in_utf8,
    ord_in_utf16le,
    ord_in_utf16be,
    ord_in_utf32le,
    ord_in_utf32be,
};

MODULE = ShiftJIS::CP932::MapUTF	PACKAGE = ShiftJIS::CP932::MapUTF

void
cp932_to_unicode (arg1, arg2=0)
    SV* arg1
    SV* arg2
  PROTOTYPE: $;$
  PREINIT:
    SV *src, *dst, *cvref;
    STRLEN srclen, dstlen, mblen, ulen;
    U8 *s, *e, *p, *d, uni[UTF8_MAXLEN + 1];
    UV uv;
    struct leading lb;
  PPCODE:
    STMT_ASSIGN_CVREF_AND_SRC
    STMT_ASSIGN_LENDST(MaxLenToUni)
    SvUTF8_on(dst);

    if (cvref) {
	for (p = s; p < e; p += mblen) {
	    STMT_GET_UV_FROM_MB
	    if (uv || !*p) {
		ulen = uvuni_to_utf8(uni, uv) - uni;
		sv_catpvn(dst, (char*)uni, ulen);
	    } else
		sv_cat_retcvref(dst, cvref, newSVpvn((char*)p, mblen), FALSE);
	}
    }
    else {
	d = (U8*)SvPVX(dst);
	for (p = s; p < e; p += mblen) {
	    STMT_GET_UV_FROM_MB
	    if (uv || !*p)
		d = uvuni_to_utf8(d, uv);
	}
	*d = '\0';
	SvCUR_set(dst, d - (U8*)SvPVX(dst));
    }
    XPUSHs(dst);


void
cp932_to_utf8 (arg1, arg2=0)
    SV* arg1
    SV* arg2
  PROTOTYPE: $;$
  ALIAS:
    cp932_to_utf16le = 1
    cp932_to_utf16be = 2
    cp932_to_utf32le = 3
    cp932_to_utf32be = 4
  PREINIT:
    SV *src, *dst, *cvref;
    STRLEN srclen, dstlen, mblen, ulen;
    U8 *s, *e, *p, *d, ucs[5];
    UV uv;
    struct leading lb;
    STRLEN (*app_uv)(U8*, UV);
  PPCODE:
    STMT_ASSIGN_CVREF_AND_SRC
    STMT_ASSIGN_LENDST(maxlen_to[ix])
    app_uv = app_uv_in[ix];

    if (cvref) {
	for (p = s; p < e; p += mblen) {
	    STMT_GET_UV_FROM_MB
	    if (uv || !*p) {
		ulen = app_uv(ucs, uv);
		sv_catpvn(dst, (char*)ucs, ulen);
	    } else
		sv_cat_retcvref(dst, cvref, newSVpvn((char*)p, mblen), FALSE);
	}
    }
    else {
	d = (U8*)SvPVX(dst);
	for (p = s; p < e; p += mblen) {
	    STMT_GET_UV_FROM_MB
	    if (uv || !*p) {
		ulen = app_uv(d, uv);
		d += ulen;
	    }
	}
	*d = '\0';
	SvCUR_set(dst, d - (U8*)SvPVX(dst));
    }
    XPUSHs(dst);


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
    STMT_ASSIGN_CVREF_AND_SRC
    if (!SvUTF8(src)) {
	src = sv_mortalcopy(src);
	sv_utf8_upgrade(src);
    }
    STMT_ASSIGN_LENDST(MaxLenFmUni)

    if (cvref) {
	for (p = s; p < e;) {
	    uv = utf8n_to_uvuni(p, (e - p), &retlen, 0);
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
	    } else
		sv_cat_retcvref(dst, cvref, newSVuv(uv), FALSE);
	}
    }
    else {
	d = (U8*)SvPVX(dst);
	for (p = s; p < e;) {
	    uv = utf8n_to_uvuni(p, (e - p), &retlen, 0);
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
    XPUSHs(dst);



void
utf8_to_cp932 (arg1, arg2=0)
    SV* arg1
    SV* arg2
  PROTOTYPE: $;$
  ALIAS:
    utf16le_to_cp932 = 1
    utf16be_to_cp932 = 2
    utf32le_to_cp932 = 3
    utf32be_to_cp932 = 4
  PREINIT:
    SV *src, *dst, *cvref;
    STRLEN srclen, dstlen, retlen;
    U8 *s, *e, *p, *d, mbc[3];
    U16 j, *t;
    UV uv;
    STRLEN (*ord_uv)(U8 *, STRLEN, STRLEN *);
  PPCODE:
    STMT_ASSIGN_CVREF_AND_SRC
    STMT_ASSIGN_LENDST(maxlen_fm[ix])
    ord_uv = ord_uv_in[ix];

    if (cvref) {
	for (p = s; p < e;) {
	    uv = ord_uv(p, e - p, &retlen);

	    if (retlen)
		p += retlen;
	    else {
		sv_cat_retcvref(dst, cvref, newSVuv((UV)*p), TRUE);
		p++;
		continue;
	    }

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
	    } else
		sv_cat_retcvref(dst, cvref, newSVuv(uv), FALSE);
	}
    } else {
	d = (U8*)SvPVX(dst);
	for (p = s; p < e;) {
	    uv = ord_uv(p, e - p, &retlen);

	    if (retlen)
		p += retlen;
	    else {
		p++;
		continue;
	    }

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
    XPUSHs(dst);


