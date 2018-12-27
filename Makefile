
VER:=0.99
pkg:=$(VER)
pkgSRC1:=$(pkg).tar.gz
pkgSRC2:=../srcDSview/$(pkgSRC1)
XXX1:=$(shell realpath ./)
XXX2:=$(XXX1)/runDSview_$(VER)
XXX3:=$(XXX2)/lib/pkgconfig

#patch11:= sed -i -e 's;ROM command: 0x%02x ;0x%02x ROM command:;g' -e 's;ROM error data: 0x%02x;0x%02x ROM error data:;g'
patch11:= sed -i \
	-e 's;ROM command: 0x%02x ;%02x ROM command:;g' \
	-e 's;ROM: 0x%016x;%016x :ROM;g' \
	-e 's;Data: 0x%02x;%02x :Data;g' \
	-e 's;ROM error data: 0x%02x;%02x ROM error data:;g'

#patch21:= runDSview_/share/libsigrokdecode4DSL/decoders/onewire_network/pd.py
patch21:= runDSview_$(VER)/share/libsigrokdecode4DSL/decoders/onewire_network/pd.py
patch23:=          DSView-$(VER)/libsigrokdecode4DSL/decoders/onewire_network/pd.py

define helpTEXT

	cs  : clean_src
	cr  : clean_run
	c   : clean --> cs cr
	e   : extract
	b : build --> b1 b2 b3
	aaa : $(aaa)

	p   : pathc the ROM command decoder

endef
export helpTEXT

all : ${pkgSRC2} 
	@echo "$${helpTEXT}"

m:
	vim Makefile

aaa := clean extract p0 p1 build
aaa : $(aaa) 

${pkgSRC2} :
	cd `dirname $(pkgSRC2)` \
		&& wget -c https://github.com/DreamSourceLab/DSView/archive/$(pkgSRC1)

dstDIR:=DSView-$(VER)
c clean : clean_src clean_run
cs clean_src :
	rm -fr $(dstDIR)
cr clean_run:
	rm -fr $(XXX2)

e extract :
	[ -d $(dstDIR) ] || tar xfz $(pkgSRC2)

#	cd DSView
b build: b1 b2 b3

b1:
	cd $(dstDIR)/libsigrok4DSL/ && ./autogen.sh 
	cd $(dstDIR)/libsigrok4DSL/ && ./configure --prefix=$(XXX2)
	cd $(dstDIR)/libsigrok4DSL/ && make
	cd $(dstDIR)/libsigrok4DSL/ && make install
b2:
	cd $(dstDIR)/libsigrokdecode4DSL/ && ./autogen.sh 
	cd $(dstDIR)/libsigrokdecode4DSL/ && ./configure --prefix=$(XXX2)
	cd $(dstDIR)/libsigrokdecode4DSL/ && make
	cd $(dstDIR)/libsigrokdecode4DSL/ && make install

b3:
	cd $(dstDIR)/DSView/ && \
		PKG_CONFIG_PATH=$(XXX3) \
		cmake . -DCMAKE_INSTALL_PREFIX=$(XXX2)
	cd $(dstDIR)/DSView/ && make
	cd $(dstDIR)/DSView/ && make install

p : p2

p2: 
	$(patch11) $(patch21)
p0:
	$(patch11) $(patch23)

p1: DSView-$(VER)/DSView/CMakeLists.txt
	sed -i -e 's;^install(FILES DreamSourceLab.rules;#&;g' $<
	sed -i -e 's;^install(FILES DSView.desktop;#&;g'       $<

s strip :
	-find $(XXX2)/ |xargs -n 1 strip 2>/dev/null 
