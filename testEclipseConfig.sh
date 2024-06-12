# https://stackoverflow.com/questions/11633529/installing-plugin-into-eclipse-using-command-line

# Eclipse Groovy Development Tools
# org.codehaus.groovy.eclipse.feature.feature.group
# 5.1.0.v202309291928-e2306
# Pivotal Software, Inc.
LOCATION=/home/hephaestus/bin/BowlerStudioInstall/eclipse-java-2024-03-R-linux-gtk-x86_64/eclipse/
MYECLIPSE=$LOCATION/eclipse    
set -e
#https://download.eclipse.org/tools/orbit/downloads/drops/R20210825222808/repository 
# WHat groovy plugin goes with which eclipse install
#https://github.com/groovy/groovy-eclipse/wiki#how-to-install

GROOVYVERSION=https://groovy.jfrog.io/artifactory/plugins-snapshot/e4.31
ECLIPSEUPDATE=https://download.eclipse.org/releases/2024-03
BOWLER_VM=/home/hephaestus/bin/BowlerStudioInstall/zulu8.78.0.19-ca-fx-jdk8.0.412-linux_x64
WORKSPACE=/home/hephaestus/Documents/bowler-workspace/eclipse-workspace

# org.eclipse.jdt.core.manipulation
#if false; then
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
#fi

#rm -rf importThis
#mkdir -p importThis
#cp jvm.epf  importThis/

#sed -i -e 's/MY_JVM_LOCATION/\/home\/hephaestus\/bin\/BowlerStudioInstall\/zulu8.78.0.19-ca-fx-jdk8.0.412-linux_x64/g' importThis/jvm.epf
#sed -i -e 's/MY_WORKSPACE/\/home\/hephaestus\/Documents\/bowler-workspace\/eclipse-workplace/g' importThis/jvm.epf

#$MYECLIPSE -data /home/hephaestus/Documents/bowler-workspace/eclipse-workspace -vmargs -Dorg.eclipse.equinox.p2.reconciler.dropins.directory=importThis/ 

#$MYECLIPSE -application org.eclipse.equinox.p2.director -nosplash  -data importThis/ -vmargs -Dorg.eclipse.equinox.p2.reconciler.dropins.directory=$LOCATION/dropins/

     
$MYECLIPSE -data /home/hephaestus/Documents/bowler-workspace/eclipse-workspace
