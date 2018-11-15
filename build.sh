#!/bin/bash

# Git tag without v (e.g. 3.0.1)
VERSION=3.0.1
NUM=1

# Installation directory
PREFIX=/usr/local

base=$PWD

# Cleanup
rm *.deb
rm -Rf libwebsockets

# Clone git repository
git clone -b "v${VERSION}" --single-branch --depth 1 https://github.com/warmcat/libwebsockets.git

# Create control file

pushd libwebsockets || exit 2

APP="libwebsockets"
ARCH=$(dpkg --print-architecture)
USER=$(git config user.name)
MAIL=$(git config user.email)

NAME=$APP"_"$VERSION"-"$NUM"_"$ARCH

mkdir -p $base/$NAME/DEBIAN || exit 10
control=$base/$NAME/DEBIAN/control

echo "Package: "$APP                 >  $control
echo "Version: "$VERSION"-"$NUM      >> $control
echo "Section: base"                 >> $control
echo "Priority: optional"            >> $control
echo "Architecture: "$ARCH           >> $control
echo "Depends: "                     >> $control
echo "Maintainer: "$USER" <"$MAIL">" >> $control

cat >> $control << EOF
Description: libwebsockets.org websocket library.
EOF

echo "  git describe: "$(git describe --tags)     >> $control
echo "  git log: "$(git log --oneline | head -n1) >> $control


# Start the build

mkdir -p build || exit 22
cd       build || exit 24

cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX .. || exit 26
make -j || exit 28

make install DESTDIR=$base/$NAME/ || exit 30

popd

# delete all test files
rm -Rf $NAME/usr/local/bin
rm -Rf $NAME/usr/local/share

# Create the package

dpkg-deb --build $NAME || exit 40

# Cleanup
rm -rf $NAME/ || exit 50
rm -Rf libwebsockets

echo "Done..."
exit 0
