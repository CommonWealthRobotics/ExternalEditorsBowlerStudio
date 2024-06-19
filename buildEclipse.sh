# https://stackoverflow.com/questions/11633529/installing-plugin-into-eclipse-using-command-line

# Eclipse Groovy Development Tools
# org.codehaus.groovy.eclipse.feature.feature.group
# 5.1.0.v202309291928-e2306
# Pivotal Software, Inc.

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
mkdir -p $DOWNDIR
PACKAGE=$DOWNDIR""$BASEFILE"."$EXTENTION
LOCATION=$DOWNDIR""$BASEFILE

if ! test -f $PACKAGE; then
  echo "$PACKAGE File does not exist."
  case "${TYPE}" in
    Linux-x86_64*)       DOWNLOAD="wget $URL -O $PACKAGE";;
    Mac-x86_64*)         DOWNLOAD="wget $URL -O $PACKAGE";;
    Mac-arm64*)          DOWNLOAD="wget $URL -O $PACKAGE";;
    Windows-x86_64*)     DOWNLOAD="curl $URL -o $PACKAGE";;
  esac
  echo $DOWNLOAD
  eval $DOWNLOAD
else
	echo "$PACKAGE exists"
fi
if ! test -d $LOCATION; then
  echo "$LOCATION File does not exist."
  case "${TYPE}" in
    Windows*)       EXTRACT="7z x $PACKAGE -y -o$LOCATION;mv $LOCATION/eclipse/* $LOCATION/";;
    Linux*)         EXTRACT="tar -xvzf $PACKAGE -C $LOCATION --strip-components=1;";;
    Mac*)           EXTRACT="tar -xvzf $PACKAGE -C $LOCATION;";;
    
  esac
  mkdir -p $LOCATION
  echo $EXTRACT
  eval $EXTRACT
  ls -al $LOCATION
      
  case "${TYPE}" in
    Linux-x86_64*)       MYECLIPSE=$LOCATION/eclipse;;
    Mac*)                MYECLIPSE=$LOCATION/Eclipse.app/Contents/MacOS/eclipse;;
    Windows-x86_64*)     MYECLIPSE=$LOCATION/eclipsec.exe;;
  esac
  set -e
  $MYECLIPSE  -nosplash -application org.eclipse.equinox.p2.director -repository $ECLIPSEUPDATE -installIU org.eclipse.platform.feature.group 
  $MYECLIPSE  -nosplash -application org.eclipse.equinox.p2.director -repository $ECLIPSEUPDATE -installIU org.eclipse.jdt.core.manipulation 
  $MYECLIPSE  -nosplash -application org.eclipse.equinox.p2.director -repository $ECLIPSEUPDATE -installIU org.eclipse.jdt.ui 
  $MYECLIPSE  -nosplash -application org.eclipse.equinox.p2.director -repository $ECLIPSEUPDATE -installIU org.eclipse.jdt.debug.ui 
  $MYECLIPSE  -nosplash -application org.eclipse.equinox.p2.director -repository $ECLIPSEUPDATE -installIU org.eclipse.jdt.junit 
  $MYECLIPSE  -nosplash -application org.eclipse.equinox.p2.director -repository $ECLIPSEUPDATE -installIU org.eclipse.ui.browser 
  $MYECLIPSE  -nosplash -application org.eclipse.equinox.p2.director -repository $ECLIPSEUPDATE -installIU org.eclipse.ant.core 
  $MYECLIPSE  -nosplash -application org.eclipse.equinox.p2.director -repository $ECLIPSEUPDATE -installIU org.eclipse.jdt.feature.group 
  $MYECLIPSE  -nosplash -application org.eclipse.equinox.p2.director -repository $GROOVYVERSION -installIU org.codehaus.groovy.eclipse.astviews 
  $MYECLIPSE  -nosplash -application org.eclipse.equinox.p2.director -repository $GROOVYVERSION -installIU org.codehaus.groovy.jdt.patch.feature.group 
  $MYECLIPSE  -nosplash -application org.eclipse.equinox.p2.director -repository $GROOVYVERSION -installIU org.codehaus.groovy.compilerless.feature.feature.group 
  $MYECLIPSE  -nosplash -application org.eclipse.equinox.p2.director -repository $GROOVYVERSION -installIU org.codehaus.groovy.headless.feature.feature.group 
  $MYECLIPSE  -nosplash -application org.eclipse.equinox.p2.director -repository $GROOVYVERSION -installIU org.codehaus.groovy.eclipse.feature.feature.group 
  $MYECLIPSE  -nosplash -application org.eclipse.equinox.p2.director -repository $GROOVYVERSION -installIU org.codehaus.groovy.eclipse 
  $MYECLIPSE  -nosplash -application org.eclipse.equinox.p2.director -repository $GROOVYVERSION -installIU org.codehaus.groovy 
  $MYECLIPSE  -nosplash -application org.eclipse.equinox.p2.director -repository $GROOVYVERSION -installIU org.codehaus.groovy40.feature.feature.group    
  $MYECLIPSE  -nosplash -application org.eclipse.equinox.p2.director -repository $GROOVYVERSION -installIU org.codehaus.groovy30.feature.feature.group 
  
else
	echo "$LOCATION exists"
fi
rm -rf release
mkdir -p release
NAME=Eclipse-Groovy
case "${TYPE}" in
    Windows*)       MKPKG="7z a ./release/$NAME-$TYPE.zip $LOCATION/ ";;
    *)              MKPKG="tar czf ./release/$NAME-$TYPE.tar.gz $LOCATION/;";;
esac
echo "$MKPKG"
eval "$MKPKG"
ls -al .
ls -al release/

