#!/bin/bash
# Updated for Eclipse 2026-06 (platform 4.40) / Groovy-Eclipse 6.2.0
#
# Eclipse Groovy Development Tools
# org.codehaus.groovy.eclipse.feature.feature.group
# 6.2.0 (targets e4.40 / Eclipse 2026-06)
# https://github.com/groovy/groovy-eclipse/wiki
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    *)          machine="Windows";;
esac
ARCH="x86_64"
if [[ $(uname -m) == 'arm64' ]]; then
  ARCH="arm64"
fi
TYPE=${machine}"-"$ARCH
echo ${TYPE}

RELEASETRAIN="2026-06"
BASEURL="https://mirror.umd.edu/eclipse/technology/epp/downloads/release/${RELEASETRAIN}/R/"

# Groovy-Eclipse: "plugins-release/e4.40" is the composite update site that
# always resolves to the latest 6.x Groovy-Eclipse release built for the
# Eclipse 2026-06 (4.40) target platform. To pin an exact version instead
# (e.g. for reproducible builds), use:
#   https://groovy.jfrog.io/artifactory/plugins-release/org/codehaus/groovy/groovy-eclipse-integration/6.2.0/e4.40
GROOVYVERSION=https://groovy.jfrog.io/artifactory/plugins-release/e4.40
ECLIPSEUPDATE=https://download.eclipse.org/releases/${RELEASETRAIN}

# NOTE: as of the 2026-06 packaging, macOS ships as a .dmg disk image
# instead of a .tar.gz archive. Windows/Linux extensions are unchanged.
case "${TYPE}" in
    Linux-x86_64*)       BASEFILE="eclipse-java-${RELEASETRAIN}-R-linux-gtk-x86_64";EXTENTION="tar.gz";;
    Linux-arm64*)        BASEFILE="eclipse-java-${RELEASETRAIN}-R-linux-gtk-aarch64";EXTENTION="tar.gz";;
    Mac-x86_64*)         BASEFILE="eclipse-java-${RELEASETRAIN}-R-macosx-cocoa-x86_64";EXTENTION="dmg";;
    Mac-arm64*)          BASEFILE="eclipse-java-${RELEASETRAIN}-R-macosx-cocoa-aarch64";EXTENTION="dmg";;
    Windows-x86_64*)     BASEFILE="eclipse-java-${RELEASETRAIN}-R-win32-x86_64";EXTENTION="zip";;
    Windows-arm64*)      BASEFILE="eclipse-java-${RELEASETRAIN}-R-win32-aarch64";EXTENTION="zip";;
esac
URL=$BASEURL""$BASEFILE"."$EXTENTION
echo Downloading $URL
DOWNDIR=$HOME/bin/BowlerStudioInstall/
mkdir -p "$DOWNDIR"
PACKAGE=$DOWNDIR""$BASEFILE"."$EXTENTION
LOCATION=$DOWNDIR""$BASEFILE
case "${TYPE}" in
    Linux-x86_64*)       MYECLIPSE=$LOCATION/eclipse;;
    Linux-arm64*)        MYECLIPSE=$LOCATION/eclipse;;
    Mac*)                MYECLIPSE=$LOCATION/Eclipse.app/Contents/MacOS/eclipse;;
    Windows-x86_64*)     MYECLIPSE="$LOCATION/eclipsec.exe";;
    Windows-arm64*)      MYECLIPSE="$LOCATION/eclipsec.exe";;
esac
if ! test -f "$PACKAGE"; then
  echo "$PACKAGE File does not exist."
  case "${TYPE}" in
    Linux*)               DOWNLOAD="wget $URL -O $PACKAGE";;
    Mac*)                 DOWNLOAD="wget $URL -O $PACKAGE";;
    Windows*)             DOWNLOAD="curl $URL -o \"$PACKAGE\"";;
  esac
  echo "$DOWNLOAD"
  eval "$DOWNLOAD"
else
    echo "$PACKAGE exists"
fi
set -e

if ! test -d "$LOCATION"; then
  echo "LOCATION $LOCATION File does not exist."
  mkdir -p "$LOCATION"
  case "${TYPE}" in
    Windows*)
      EXTRACT="7z x \"$PACKAGE\" -y -o\"$LOCATION\";mv \"$LOCATION/eclipse/\"* \"$LOCATION/\""
      echo "$EXTRACT"
      eval "$EXTRACT"
      ;;
    Linux*)
      EXTRACT="tar -xvzf $PACKAGE -C $LOCATION --strip-components=1;"
      echo "$EXTRACT"
      eval "$EXTRACT"
      ;;
    Mac*)
      # macOS packages are distributed as .dmg disk images (as of 2026-06),
      # not .tar.gz. Mount the image, copy Eclipse.app out, then detach.
      MOUNTPOINT="/tmp/eclipse_dmg_mount_$$"
      mkdir -p "$MOUNTPOINT"
      echo "Mounting $PACKAGE at $MOUNTPOINT"
      hdiutil attach "$PACKAGE" -mountpoint "$MOUNTPOINT" -nobrowse -quiet
      APPSRC=$(find "$MOUNTPOINT" -maxdepth 1 -iname "Eclipse.app" | head -n 1)
      if [ -z "$APPSRC" ]; then
        echo "ERROR: could not find Eclipse.app inside mounted image $PACKAGE"
        hdiutil detach "$MOUNTPOINT" -quiet || true
        exit 1
      fi
      cp -R "$APPSRC" "$LOCATION/Eclipse.app"
      hdiutil detach "$MOUNTPOINT" -quiet
      rmdir "$MOUNTPOINT"
      ;;
  esac
  ls -al "$LOCATION"
echo "Installing Eclipse components..."

install_iu() {
    local repository="$1"
    local iu="$2"

    echo "  Installing: $iu"

    "$MYECLIPSE" -nosplash \
        -application org.eclipse.equinox.p2.director \
        -repository "$repository" \
        -installIU "$iu" \
        >/dev/null
}

# Eclipse platform/JDT/PDE components
install_iu "$ECLIPSEUPDATE" org.eclipse.platform.feature.group
install_iu "$ECLIPSEUPDATE" org.eclipse.jdt.core.manipulation
install_iu "$ECLIPSEUPDATE" org.eclipse.jdt.ui
install_iu "$ECLIPSEUPDATE" org.eclipse.jdt.debug.ui
install_iu "$ECLIPSEUPDATE" org.eclipse.jdt.junit
install_iu "$ECLIPSEUPDATE" org.eclipse.ui.browser
install_iu "$ECLIPSEUPDATE" org.eclipse.ant.core
install_iu "$ECLIPSEUPDATE" org.eclipse.jdt.feature.group
install_iu "$ECLIPSEUPDATE" org.eclipse.pde.feature.group

echo "Installing Groovy-Eclipse components..."

install_iu "$GROOVYVERSION" org.codehaus.groovy.eclipse.astviews
install_iu "$GROOVYVERSION" org.codehaus.groovy.jdt.patch.feature.group
install_iu "$GROOVYVERSION" org.codehaus.groovy.compilerless.feature.feature.group
install_iu "$GROOVYVERSION" org.codehaus.groovy.headless.feature.feature.group
install_iu "$GROOVYVERSION" org.codehaus.groovy.eclipse.feature.feature.group
install_iu "$GROOVYVERSION" org.codehaus.groovy.eclipse
install_iu "$GROOVYVERSION" org.codehaus.groovy
install_iu "$GROOVYVERSION" org.codehaus.groovy40.feature.feature.group
install_iu "$GROOVYVERSION" org.codehaus.groovy30.feature.feature.group

echo "Eclipse installation completed."
else
    echo "$LOCATION exists"
fi

echo "Build Plugin..."
TEMP_WORKSPACE="/tmp/eclipse_workspace_$$"
mkdir -p "$TEMP_WORKSPACE"
ECLIPSE_HOME=$LOCATION
PROJECT_DIR=$SCRIPT_DIR"/"
OUTPUT_DIR="$PROJECT_DIR/build_output"
mkdir -p "$OUTPUT_DIR"

RELEASEDIR=release
rm -rf "$SCRIPT_DIR/$RELEASEDIR"
mkdir -p "$SCRIPT_DIR/$RELEASEDIR"

TEMP_BUILD_PROPS="$TEMP_WORKSPACE/build.properties"
PLUGIN_ID=com.commonwealthrobotics
echo "BUilding plugin $PLUGIN_ID"
cat << EOF > "$TEMP_BUILD_PROPS"
topLevelElementType = plugin
topLevelElementId = $PLUGIN_ID
javacSource=17
javacTarget=17
buildDirectory=${PROJECT_DIR}
baseLocation=${ECLIPSE_HOME}
pluginPath=${ECLIPSE_HOME}/plugins
outputDirectory=${OUTPUT_DIR}
buildTempFolder=${TEMP_WORKSPACE}/build
buildType=I
buildId=Build
buildLabel=\${buildType}\${buildId}
timestamp=007
collectingFolder=.
archivePrefix=.
zipargs=
tarargs=
plugin.destination=${OUTPUT_DIR}
EOF
cat $TEMP_BUILD_PROPS

case "${TYPE}" in
    Windows*)       MKPKG="cp -r ./plugin-out/dropins/* \"$LOCATION/dropins/\" ";;
    Mac*)          MKPKG="cp -r ./plugin-out/dropins/* \"$LOCATION/Eclipse.app/Contents/Eclipse/dropins/\"";;
    Linux*)         MKPKG="cp -r ./plugin-out/dropins/* $LOCATION/dropins/";;
esac
echo "$MKPKG"
eval "$MKPKG"
NAME=Eclipse-Groovy
case "${TYPE}" in
    Windows*)       MKPKG="7z a \"$SCRIPT_DIR/$RELEASEDIR/$NAME-$TYPE.zip\" \"$LOCATION/\"* ";;
    Mac*)          MKPKG="cd $LOCATION/; xattr -cr Eclipse.app; zip -r $SCRIPT_DIR/$RELEASEDIR/$NAME-$TYPE.zip Eclipse.app; cd $SCRIPT_DIR";;
    Linux*)         MKPKG="cd $DOWNDIR/$BASEFILE;tar czf $SCRIPT_DIR/$RELEASEDIR/$NAME-$TYPE.tar.gz * ;cd $SCRIPT_DIR";;
esac
echo "$MKPKG"
eval "$MKPKG"
ls -al .
ls -al "$SCRIPT_DIR/$RELEASEDIR"

echo "Clean exit after building $NAME-$TYPE"