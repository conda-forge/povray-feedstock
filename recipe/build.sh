#!/bin/bash
(cd unix && ./prebuild.sh)

if [[ "$OSTYPE" == "darwin"* ]]; then
  # libc++ provides no std::char_traits<unsigned short>, so build the
  # UCS2/UCS4 string types on char16_t/char32_t instead (see patches)
  export CPPFLAGS="$CPPFLAGS -DPOVMSUCS2=char16_t -DUCS2=char16_t -DUCS4=char32_t"
  # std::auto_ptr (source/backend/render/trace.cpp) was removed in C++17
  export CXXFLAGS="$CXXFLAGS -std=c++11"
fi

# --disable-optimiz: povray's configure adds -O3 -ffast-math, which breaks
# the HUGE_VAL sentinels used in camera parsing under -ffinite-math-only
# ("Viewing angle has to be smaller than 180 degrees") and is known to
# produce wrong renders (POV-Ray issue #460). Same fix as Debian/Homebrew.
./configure \
    --prefix="$PREFIX" \
    --with-boost="$PREFIX" \
    --with-boost-thread=boost_thread \
    --without-x \
    --without-openexr \
    --without-libsdl \
    --disable-optimiz \
    COMPILED_BY="conda"

make -j${CPU_COUNT}
make install
