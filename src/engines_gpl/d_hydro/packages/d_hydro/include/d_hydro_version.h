#ifndef D_HYDRO_VERSION
#define D_HYDRO_VERSION

#define CAT(a, b) a ## b
#define FUNC_CAT(a, b) CAT(a, b)

#define MOD_NAME         D_HYDRO
#define modname_program  "D_HYDRO"
#if HAVE_CONFIG_H
#   define F90_MOD_NAME   FC_FUNC(d_hydro, D_HYDRO)
#else
#   define F90_MOD_NAME   MOD_NAME
#endif

#define modname_major "3"
#define modname_minor "01"
#define modname_revision "00"
#define modname_build "000000"

#define modname_company "Deltares"
#define modname_company_url "http://www.deltares.nl"

/*=================================================== DO NOT MAKE CHANGES BELOW THIS LINE ===================================================================== */

static char modname_version       [] = {modname_major"."modname_minor"."modname_revision"."modname_build};
static char modname_version_short [] = {modname_major"."modname_minor};
static char modname_version_full  [] = {modname_company", "modname_program" Version "modname_major"."modname_minor"."modname_revision"."modname_build", "__DATE__", "__TIME__""};
static char modname_url           [] = {modname_company_url};

#if HAVE_CONFIG_H
#   include "config.h"
#   define STDCALL  /* nothing */
#   define GETSHORTVERSIONSTRING FUNC_CAT( FC_FUNC(getshortversionstring,GETSHORTVERSIONSTRING), F90_MOD_NAME)
#   define GETFULLVERSIONSTRING FUNC_CAT( FC_FUNC(getfullversionstring,GETFULLVERSIONSTRING), F90_MOD_NAME)
#   define GETURLSTRING FUNC_CAT( FC_FUNC(geturlstring,GETURLSTRING), F90_MOD_NAME)
#else
// WIN32
#   define STDCALL  /* nothing */
#   define GETSHORTVERSIONSTRING FUNC_CAT( GETSHORTVERSIONSTRING_, F90_MOD_NAME)
#   define GETFULLVERSIONSTRING FUNC_CAT( GETFULLVERSIONSTRING_, F90_MOD_NAME)
#   define GETURLSTRING FUNC_CAT( GETURLSTRING_, F90_MOD_NAME)
#endif


#if (defined(__cplusplus)||defined(_cplusplus))
extern "C" {
#endif

void   STDCALL GETSHORTVERSIONSTRING( char *, int );
void   STDCALL GETFULLVERSIONSTRING( char *, int );
void   STDCALL GETURLSTRING( char *, int );

#if (defined(__cplusplus)||defined(_cplusplus))
}
#endif

#endif /* D_HYDRO_VERSION */

