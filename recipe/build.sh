#!/bin/bash
set -xeo pipefail

rm -f subprojects/gtest.wrap
EXTRA_MESON_ARGS=""
EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dgstreamer=enabled"
EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dtest=false"
EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dcam=enabled"
EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dqcam=enabled"
EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dpycamera=enabled"
EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dv4l2=true"
EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dwerror=false"
# New in 0.7.x: GPU SoftISP is an `auto` feature. Pin it off so an
# incidentally-discoverable egl/glesv2 in host can't silently enable it and
# link runtime deps we don't declare. (Flip to =enabled + add egl/glesv2 to
# host & run if you ever want it.)
EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dsoftisp-gpu=disabled"
if [[ ${variant} == "rpi_fork" ]]; then
  # Make sure we build the standard pipeline and ipas contained in the upstream build
  # in ADDITION to the rpi/pisp ones
  EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dpipelines=imx8-isi,mali-c55,rkisp1,rpi/vc4,simple,uvcvideo,rpi/pisp"
  EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dipas=mali-c55,rkisp1,rpi/vc4,simple,rpi/pisp"
  # New in 0.7.x rpi fork: the NN AWB algorithm needs tensorflow-lite, which
  # we don't package here. Pin it off (also an `auto` feature otherwise).
  EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Drpi-awb-nn=disabled"
fi

meson setup build ${MESON_ARGS} \
     -Ddocumentation=disabled \
     ${EXTRA_MESON_ARGS}

ninja -C build install