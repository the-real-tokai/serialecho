/*
 *   SerialEcho
 *   Dumps a line to serial debug output.
 *
 *   Copyright © 2005-2014 Christian Rosentreter
 *   All rights reserved.
 *
 *   This software is released under a three-clause BSD-style 
 *   license, see the LICENCE document for details.
 *
 *
 *   $Id: serialecho.c 18 2014-02-09 00:27:18Z tokai $
 */

#define USE_INLINE_STDARG
#include <exec/exec.h>
#include <proto/exec.h>
#include <proto/dos.h>

#include "version.h"


const UBYTE __vtag__[]   = "$VER: " VERS " (" DATE ") © 2005-2014 Christian Rosentreter";


/*  OS/ compiler specific
 */
#if defined(__MORPHOS__)

	CONST ULONG __abox__     = 1;
	#if 0
	CONST ULONG __amigappc__ = 1; /* MorphOS 0.x compatibility */
	#endif

	#define ENTRYPOINT ULONG serialecho(void)

#elif defined(__amigaos4__)

	#include <clib/debug_protos.h>

	typedef ULONG IPTR;

	#define ENTRYPOINT ULONG serialecho(void)
	#define RawPutChar(x) kputc(x)

	ENTRYPOINT;

	int main(void) 
	{ 
		return serialecho(); 
	}

#elif defined(__AROS__)

	#define ENTRYPOINT ULONG serialecho(struct ExecBase *SysBase)

	ENTRYPOINT;

	AROS_UFH3(__startup static int, Start,
	  AROS_UFHA(char *, argstr, A0),
	  AROS_UFHA(ULONG, argsize, D0),
	  AROS_UFHA(struct ExecBase *, sBase, A6))
	{
		AROS_USERFUNC_INIT
		return serialecho(sBase);
		AROS_USERFUNC_EXIT
	}

#else /* 68k */

	typedef ULONG IPTR;

	#define ENTRYPOINT __saveds ULONG serialecho(void)

	#ifdef __SASC
		/*  undocumented exec.library function
		 */
		#pragma libcall SysBase RawPutChar 204 001
	#else
		#warning Compiler unsupported. Generated executable might not work.
	#endif

	void RawPutChar(UBYTE);

#endif /* __MORPHOS__ */




/*  ReadArg() defines
 */
#define TEMPLATE "/M,NOLINE/S"

enum
{
	ARG_TOECHO = 0,
	ARG_NOLINE,
	NUMARGS,
};



/*  main()
 */
ENTRYPOINT
{
	ULONG rc = RETURN_FAIL;

#ifndef __amigaos4__
#ifndef __AROS__
	struct ExecBase   *SysBase = *(struct ExecBase **)(4UL);
#endif
	struct DosLibrary *DOSBase = (struct DosLibrary *)OpenLibrary("dos.library", 36UL);

	if (DOSBase)
	{
#endif

		struct RDArgs *rda;
		IPTR argv[NUMARGS] = { 0 };	

		if ( (rda = ReadArgs(TEMPLATE,(LONG *)(argv),NULL)) )
		{
			STRPTR *s = (STRPTR *)argv[ARG_TOECHO];

			if (s)
			{
				STRPTR first = *s;
				STRPTR t;
				UBYTE  c;

				while ((t = *s))
				{
					if (t != first)
					{
						RawPutChar(' ');
					}

					while ((c = *t++))
					{
						RawPutChar(c);
					}

					s++;
				}
			}

			if (!argv[ARG_NOLINE])
			{
				RawPutChar('\n');
			}

			rc = RETURN_OK;

			FreeArgs(rda);
		}
		else
		{
			PrintFault(IoErr(), "SerialEcho");
			rc = RETURN_ERROR;
		}

#ifndef __amigaos4__
		CloseLibrary((struct Library *)DOSBase);
	}
#endif

	return rc;
}
