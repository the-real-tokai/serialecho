#
#   SerialEcho
#   Dumps a line to serial debug output.
#
#   Copyright © 2005-2014 Christian Rosentreter
#   All rights reserved.
#
#   This software is released under a three-clause BSD-style
#   license, see the LICENCE document for details.
#
#
#   $Id: Makefile 18 2014-02-09 00:27:18Z tokai $
#

EXE     = SerialEcho
CC 		= ppc-morphos-gcc -pipe
VERSION = 50

CWARN   = -Wall -W 
CFLAGS  = $(CWARN) -noixemul -Os -mcpu=750 -mstring -mmultiple -fexpensive-optimizations -fomit-frame-pointer -fstrict-aliasing -finline
LDFLAGS = -noixemul -nostartfiles

OBJPPC  = serialecho.oPPC


all: $(EXE)

.PHONY: clean bump install

$(EXE): $(OBJPPC)
	$(CC) $(LDFLAGS) -o $@ $(OBJPPC)
	ppc-morphos-strip --strip-unneeded --strip-all --remove-section .comment $@

%.oPPC: %.c
	$(CC) -pipe $(CWARNS) $(CDEFS) $(CFLAGS) -c $< -o $@ 

# let's be lazy... SCOPTIONS does the rest :)
#
$(EXE).68k: serialecho.c version.h
	sc serialecho.c

clean:
	rm -f $(EXE) $(EXE).68k $(EXE).os4 *.o *.oPPC *.lnk

bump:
	bumprev2 VERSION $(VERSION) FILE version TAG $(EXE) ADD "© 2005-$(shell date "+%Y") Christian Rosentreter"
	rm -f version.i version.trev

install: all
	cp $(EXE) /SYS/C/
	protect /SYS/C/$(EXE) +RWEDP


#  dependencies
#
serialecho.oPPC: serialecho.c version.h




#  release
#
ARCHIVE = $(shell echo $(EXE) | sed -r "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/")-$(VERSION).$(shell cat version.rev)

.PHONY: archives
archives: all $(EXE).68k
	mkdir -p archives
	rm -fr /t/$(ARCHIVE)*
	rm -f archives/$(ARCHIVE)*.*
########
	@echo "====> $(ARCHIVE)-morphos.lha"
	mkdir -p /t/$(ARCHIVE)-morphos
	cp $(EXE)        /t/$(ARCHIVE)-morphos
	cp $(EXE).readme /t/$(ARCHIVE)-morphos/ReadMe.txt
	cp $(EXE).notes  /t/$(ARCHIVE)-morphos/History.txt
	cp LICENSE       /t/$(ARCHIVE)-morphos/License.txt
	protect t:$(ARCHIVE)-morphos/SerialEcho +RWEDP
	lha a -a -r archives/$(ARCHIVE)-morphos.lha t:$(ARCHIVE)-morphos
########
	@echo "====> $(ARCHIVE)-amigaos.lha"
	mkdir -p /t/$(ARCHIVE)-amigaos
	cp $(EXE).68k    /t/$(ARCHIVE)-amigaos/SerialEcho
	cp $(EXE).readme /t/$(ARCHIVE)-amigaos/ReadMe.txt
	cp $(EXE).notes  /t/$(ARCHIVE)-amigaos/History.txt
	cp LICENSE       /t/$(ARCHIVE)-amigaos/License.txt
	protect t:$(ARCHIVE)-amigaos/SerialEcho +RWEDP
	lha a -a -r archives/$(ARCHIVE)-amigaos.lha t:$(ARCHIVE)-amigaos
########
	@echo "====> $(ARCHIVE)-source.tar.#?"
	mkdir -p /t/$(ARCHIVE)-source
	cp $(EXE).readme /t/$(ARCHIVE)-source
	cp $(EXE).notes  /t/$(ARCHIVE)-source
	cp *.c           /t/$(ARCHIVE)-source
	cp version.h     /t/$(ARCHIVE)-source
	cp version.rev   /t/$(ARCHIVE)-source
	cp Makefile      /t/$(ARCHIVE)-source
	cp Makefile.os4  /t/$(ARCHIVE)-source
	cp mmakefile.src /t/$(ARCHIVE)-source
	cp LICENSE       /t/$(ARCHIVE)-source
	cp SCOPTIONS     /t/$(ARCHIVE)-source
	tar -C /t/ -cvf archives/$(ARCHIVE)-source.tar $(ARCHIVE)-source
	bzip2 -f -9 -k archives/$(ARCHIVE)-source.tar
	gzip  -f -9 archives/$(ARCHIVE)-source.tar
