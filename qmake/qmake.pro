# CDDL HEADER START
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
# CDDL HEADER END

# Copyright 2017 Saso Kiselkov. All rights reserved.

# Shared library without any Qt functionality
TEMPLATE = lib
QT -= gui core

CONFIG += warn_on plugin release
CONFIG -= thread exceptions qt rtti debug

VERSION = 1.0.0

INCLUDEPATH += ../SDK/CHeaders/XPLM
# Always just use the shipped OpenAL headers for predictability.
# The ABI is X-Plane-internal and stable anyway.
INCLUDEPATH += ../OpenAL/include
INCLUDEPATH += $$[LIBACFUTILS]/src

QMAKE_CFLAGS += -std=c99 -g -W -Wall -Wextra -Werror -fvisibility=hidden
QMAKE_CFLAGS += -Wunused-result

# _GNU_SOURCE needed on Linux for getline()
# DEBUG - used by our ASSERT macro
# _FILE_OFFSET_BITS=64 to get 64-bit ftell and fseek on 32-bit platforms.
# _USE_MATH_DEFINES - sometimes helps getting M_PI defined from system headers
DEFINES += _GNU_SOURCE DEBUG _FILE_OFFSET_BITS=64 _USE_MATH_DEFINES

# Latest X-Plane APIs. No legacy support needed.
DEFINES += XPLM200 XPLM210

# Just a generally good idea not to depend on shipped libgcc.
!macx {
	LIBS += -static-libgcc
}

win32 {
	CONFIG += dll
	DEFINES += APL=0 IBM=1 LIN=0 _WIN32_WINNT=0x0600
	TARGET = win.xpl
	INCLUDEPATH += /usr/include/GL
	QMAKE_DEL_FILE = rm -f
}

win32:contains(CROSS_COMPILE, x86_64-w64-mingw32-) {
	INCLUDEPATH += ../libpng/libpng-win-64/include

	# This must go first for GCC to properly find dependent symbols
	LIBS += -L$$[LIBACFUTILS]/qmake/win64 -lacfutils
	LIBS += -L../SDK/Libraries/Win -lXPLM_64
	LIBS += -L../OpenAL/libs/Win64 -lOpenAL32
	LIBS += -L../GL_for_Windows/lib -lopengl32
	LIBS += -L../libpng/libpng-win-64/.libs -lpng16
	LIBS += -L../zlib/zlib-win-64 -lz
	LIBS += -ldbghelp
}

win32:contains(CROSS_COMPILE, i686-w64-mingw32-) {
	INCLUDEPATH += ../libpng/libpng-win-32/include

	LIBS += -L$$[LIBACFUTILS]/qmake/win32 -lacfutils
	LIBS += -L../SDK/Libraries/Win -lXPLM
	LIBS += -L../OpenAL/libs/Win32 -lOpenAL32
	LIBS += -L../GL_for_Windows/lib -lopengl32
	LIBS += -L../libpng/libpng-win-32/.libs -lpng16
	LIBS += -L../zlib/zlib-win-32 -lz
	LIBS += -ldbghelp
}

unix:!macx {
	DEFINES += APL=0 IBM=0 LIN=1
	TARGET = lin.xpl
	LIBS += -nodefaultlibs
}

linux-g++-64 {
	INCLUDEPATH += ../libpng/libpng-linux-64/include

	LIBS += -L$$[LIBACFUTILS]/qmake/lin64 -lacfutils
	LIBS += -L../libpng/libpng-linux-64/.libs -lpng16
	LIBS += -L../zlib/zlib-linux-64 -lz
}

linux-g++-32 {
	INCLUDEPATH += ../libpng/libpng-linux-32/include

	# The stack protector forces us to depend on libc,
	# but we'd prefer to be static.
	QMAKE_CFLAGS += -fno-stack-protector
	LIBS += -fno-stack-protector
	LIBS += -L$$[LIBACFUTILS]/qmake/lin32 -lacfutils
	LIBS += -L../libpng/libpng-linux-32/.libs -lpng16
	LIBS += -L../zlib/zlib-linux-32 -lz
	LIBS += -lssp_nonshared
}

macx {
	# Prevent linking via clang++ which makes us depend on libstdc++
	QMAKE_LINK = $$QMAKE_CC
	QMAKE_CFLAGS += -mmacosx-version-min=10.7
	QMAKE_LFLAGS += -mmacosx-version-min=10.7

	DEFINES += APL=1 IBM=0 LIN=0
	TARGET = mac.xpl
	INCLUDEPATH += ../OpenAL/include
	LIBS += -F../SDK/Libraries/Mac
	LIBS += -framework OpenGL -framework OpenAL -framework XPLM
}

macx-clang {
	INCLUDEPATH += ../libpng/libpng-mac-64/include

	LIBS += -L$$[LIBACFUTILS]/qmake/mac64 -lacfutils
	LIBS += -L../libpng/libpng-mac-64/.libs -lpng16
	LIBS += -L../zlib/zlib-mac-64 -lz
}

macx-clang-32 {
	INCLUDEPATH += ../libpng/libpng-mac-32/include

	LIBS += -L$$[LIBACFUTILS]/qmake/mac32 -lacfutils
	LIBS += -L../libpng/libpng-mac-32/.libs -lpng16
	LIBS += -L../zlib/zlib-mac-32 -lz
}

HEADERS += ../src/*.h
SOURCES += ../src/*.c
