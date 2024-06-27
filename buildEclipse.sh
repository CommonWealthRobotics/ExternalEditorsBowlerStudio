# https://stackoverflow.com/questions/11633529/installing-plugin-into-eclipse-using-command-line

# Eclipse Groovy Development Tools
# org.codehaus.groovy.eclipse.feature.feature.group
# 5.1.0.v202309291928-e2306
# Pivotal Software, Inc.
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

BASEURL="https://mirror.umd.edu/eclipse/technology/epp/downloads/release/2024-03/R/"
GROOVYVERSION=https://groovy.jfrog.io/artifactory/plugins-snapshot/e4.31
ECLIPSEUPDATE=https://download.eclipse.org/releases/2024-03

case "${TYPE}" in
    Linux-x86_64*)       BASEFILE="eclipse-java-2024-03-R-linux-gtk-x86_64";EXTENTION="tar.gz";;
    Mac-x86_64*)         BASEFILE="eclipse-java-2024-03-R-macosx-cocoa-x86_64";EXTENTION="tar.gz";;
    Mac-arm64*)          BASEFILE="eclipse-java-2024-03-R-macosx-cocoa-aarch64";EXTENTION="tar.gz";;
    Windows-x86_64*)     BASEFILE="eclipse-java-2024-03-R-win32-x86_64";EXTENTION="zip";;
esac
URL=$BASEURL""$BASEFILE"."$EXTENTION
echo Downloading $URL
DOWNDIR=$HOME/bin/BowlerStudioInstall/
mkdir -p "$DOWNDIR"
PACKAGE=$DOWNDIR""$BASEFILE"."$EXTENTION
LOCATION=$DOWNDIR""$BASEFILE
case "${TYPE}" in
    Linux-x86_64*)       MYECLIPSE=$LOCATION/eclipse;;
    Mac*)                MYECLIPSE=$LOCATION/Eclipse.app/Contents/MacOS/eclipse;;
    Windows-x86_64*)     MYECLIPSE="$LOCATION/eclipsec.exe";;
esac
if ! test -f "$PACKAGE"; then
  echo "$PACKAGE File does not exist."
  case "${TYPE}" in
    Linux-x86_64*)       DOWNLOAD="wget $URL -O $PACKAGE";;
    Mac-x86_64*)         DOWNLOAD="wget $URL -O $PACKAGE";;
    Mac-arm64*)          DOWNLOAD="wget $URL -O $PACKAGE";;
    Windows-x86_64*)     DOWNLOAD="curl $URL -o \"$PACKAGE\"";;
  esac
  echo "$DOWNLOAD"
  eval "$DOWNLOAD"
else
	echo "$PACKAGE exists"
fi
set -e

if ! test -d "$LOCATION"; then
  echo "LOCATION $LOCATION File does not exist."
  case "${TYPE}" in
    Windows*)       EXTRACT="7z x \"$PACKAGE\" -y -o\"$LOCATION\";mv \"$LOCATION/eclipse/\"* \"$LOCATION/\"";;
    Linux*)         EXTRACT="tar -xvzf $PACKAGE -C $LOCATION --strip-components=1;";;
    Mac*)           EXTRACT="tar -xvzf $PACKAGE -C $LOCATION;";;
    
  esac
  mkdir -p "$LOCATION"
  echo "$EXTRACT"
  eval "$EXTRACT"
  ls -al "$LOCATION"
  echo "Extraction Completed, now configuration..."

  "$MYECLIPSE"  -nosplash -application org.eclipse.equinox.p2.director -repository $ECLIPSEUPDATE -installIU org.eclipse.platform.feature.group 
  "$MYECLIPSE"  -nosplash -application org.eclipse.equinox.p2.director -repository $ECLIPSEUPDATE -installIU org.eclipse.jdt.core.manipulation 
  "$MYECLIPSE"  -nosplash -application org.eclipse.equinox.p2.director -repository $ECLIPSEUPDATE -installIU org.eclipse.jdt.ui 
  "$MYECLIPSE"  -nosplash -application org.eclipse.equinox.p2.director -repository $ECLIPSEUPDATE -installIU org.eclipse.jdt.debug.ui 
  "$MYECLIPSE"  -nosplash -application org.eclipse.equinox.p2.director -repository $ECLIPSEUPDATE -installIU org.eclipse.jdt.junit 
  "$MYECLIPSE"  -nosplash -application org.eclipse.equinox.p2.director -repository $ECLIPSEUPDATE -installIU org.eclipse.ui.browser 
  "$MYECLIPSE"  -nosplash -application org.eclipse.equinox.p2.director -repository $ECLIPSEUPDATE -installIU org.eclipse.ant.core 
  "$MYECLIPSE"  -nosplash -application org.eclipse.equinox.p2.director -repository $ECLIPSEUPDATE -installIU org.eclipse.jdt.feature.group 
  "$MYECLIPSE"  -nosplash -application org.eclipse.equinox.p2.director -repository $ECLIPSEUPDATE -installIU org.eclipse.pde.feature.group

  "$MYECLIPSE"  -nosplash -application org.eclipse.equinox.p2.director -repository $GROOVYVERSION -installIU org.codehaus.groovy.eclipse.astviews 
  "$MYECLIPSE"  -nosplash -application org.eclipse.equinox.p2.director -repository $GROOVYVERSION -installIU org.codehaus.groovy.jdt.patch.feature.group 
  "$MYECLIPSE"  -nosplash -application org.eclipse.equinox.p2.director -repository $GROOVYVERSION -installIU org.codehaus.groovy.compilerless.feature.feature.group 
  "$MYECLIPSE"  -nosplash -application org.eclipse.equinox.p2.director -repository $GROOVYVERSION -installIU org.codehaus.groovy.headless.feature.feature.group 
  "$MYECLIPSE"  -nosplash -application org.eclipse.equinox.p2.director -repository $GROOVYVERSION -installIU org.codehaus.groovy.eclipse.feature.feature.group 
  "$MYECLIPSE"  -nosplash -application org.eclipse.equinox.p2.director -repository $GROOVYVERSION -installIU org.codehaus.groovy.eclipse 
  "$MYECLIPSE"  -nosplash -application org.eclipse.equinox.p2.director -repository $GROOVYVERSION -installIU org.codehaus.groovy 
  "$MYECLIPSE"  -nosplash -application org.eclipse.equinox.p2.director -repository $GROOVYVERSION -installIU org.codehaus.groovy40.feature.feature.group    
  "$MYECLIPSE"  -nosplash -application org.eclipse.equinox.p2.director -repository $GROOVYVERSION -installIU org.codehaus.groovy30.feature.feature.group 
  
else
	echo "$LOCATION exists"
fi

echo "Build Plugin..."
TEMP_WORKSPACE="/tmp/eclipse_workspace_$$"
mkdir -p "$TEMP_WORKSPACE"
ECLIPSE_HOME=$LOCATION
PROJECT_DIR=$SCRIPT_DIR"/"
OUTPUT_DIR="$PROJECT_DIR/build_output"
# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

RELEASEDIR=output
rm -rf "$SCRIPT_DIR/$RELEASEDIR"
mkdir -p "$SCRIPT_DIR/$RELEASEDIR"


# Create a temporary build properties file
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

#MAKEPLUGIN="\"$MYECLIPSE\" -nosplash  -application org.eclipse.ant.core.antRunner -data \"$TEMP_WORKSPACE\" -debug  -buildfile build.xml   -Declipse.home=\"$LOCATION\"   -Declipse.pdebuild.scripts=\"$LOCATION\"/plugins/org.eclipse.pde.build_3.12.300.v20240212-0530/scripts   -Declipse.launcher=\"$LOCATION\"/plugins/org.eclipse.equinox.launcher_1.6.700.v20240213-1244.jar"
#echo $MAKEPLUGIN
#eval "$MAKEPLUGIN"

#mkdir -p "$PROJECT_DIR/plugins/com.commonwealthrobotics"

# Run PDE Build and capture output
# Run PDE Build and capture output
#	BUILD_OUTPUT=$("$ECLIPSE_HOME/eclipsec" -nosplash -application org.eclipse.pde.build.Build \
#	  -data "$TEMP_WORKSPACE" \
#	  -configuration "$TEMP_WORKSPACE/configuration" \
#	  -buildfile "$ECLIPSE_HOME/plugins/org.eclipse.pde.build_3.12.300.v20240212-0530/scripts/build.xml" \
#	  -Dbuilder="$PROJECT_DIR" \
#	  -DbaseLocation="$ECLIPSE_HOME" \
#	  -DbuildDirectory="$PROJECT_DIR" \
#	  -Dbase="$ECLIPSE_HOME" \
#	  -DpluginPath="$ECLIPSE_HOME/plugins" \
#	  -DoutputDirectory="$OUTPUT_DIR" \
#	  -DskipBase=true \
#	  -DskipMaps=true \
#	  -DskipFetch=true \
#	  -DbuildProperties="$TEMP_BUILD_PROPS" \
#	  -Dgenerate.p2.metadata=true \
#	  -Dp2.metadata.repo="file:$OUTPUT_DIR/repository" \
#	  -Dp2.artifact.repo="file:$OUTPUT_DIR/repository" \
#	  -Dp2.compress=true \
#	  -Dp2.gathering=true \
#	  -debug \
#	  -verbose)
	
	
#	echo "Build completed. Checking output directory..."
	
	# Check for files in the output directory
#	echo "Contents of $OUTPUT_DIR:"
#	find "$OUTPUT_DIR" -type f
#	echo "Searching for recently created JAR files in the project directory..."
#	find "$PROJECT_DIR" -name "*.jar" -mmin -10 -type f
#	
	# Print build output
#	echo "Build Output:"
#	echo "$BUILD_OUTPUT"
	
#	echo "Searching for clues in build output..."
#	echo "$BUILD_OUTPUT" | grep -i "jar"
#	echo "$BUILD_OUTPUT" | grep -i "output"
#	echo "$BUILD_OUTPUT" | grep -i "created"
#	echo "$BUILD_OUTPUT" | grep -i "generating"
case "${TYPE}" in
    Windows*)       MKPKG="cp -r ./plugin-out/dropins/* \"$LOCATION/dropins/\" ";;
    Mac*)          MKPKG="cp -r ./plugin-out/dropins/* \"$LOCATION/Eclipse.app/Contents/Eclipse/dropins/\"";;
    Linux*)         MKPKG="cp -r ./plugin-out/dropins/* $LOCATION/dropins/";;
esac
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
