#!/bin/bash
# Copyright (C) 2016 Intel Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,

# Install test runner into  /tmp
cd /tmp
if [[ -d "rcptt-test-runner" ]]; then
  rm -rf rcptt-test-runner
fi
mkdir rcptt-test-runner
cd rcptt-test-runner
unzip -q /tmp/rcptt.runner*.zip

# Install Eclipse IDE for C/C++ Developers into the workspace
# as the Application under test
cd /tmp
if [[ -d "eclipse-cdt" ]]; then
  rm -rf eclipse-cdt
fi
mkdir eclipse-cdt
cd eclipse-cdt
tar xzf /tmp/eclipse-cpp*.tar.gz

# Establish the workspace and project
workspace=$1
cd $workspace

# Set properties below
runnerPath=/tmp/rcptt-test-runner/eclipse
autPath=/tmp/eclipse-cdt/eclipse
#project=installYoctoPlugins
if [[ -d $2 ]]; then
  cp -R $2 $workspace/temp-project
else
  cp -R /usr/share/rcptt/project $workspace/temp-project
fi
project=$workspace/temp-project

# Set the host display (you did xhost + right?)
# pass -e DISPLAY=$DISPLAY to docker run
#export DISPLAY=$3
xeyes

# properties below configure all intermediate and result files
# to be put in "results" folder next to a project folder. If
# that's ok, you can leave them as is

testResults=$workspace/results
runnerWorkspace=$testResults/runner-workspace
autWorkspace=$testResults/aut-workspace-
autOut=$testResults/aut-out-
junitReport=$testResults/results.xml
htmlReport=$testResults/results.html

rm -rf $testResults
mkdir $testResults

java -version
java -jar $runnerPath/plugins/org.eclipse.equinox.launcher_*.jar \
     -application org.eclipse.rcptt.runner.headless \
     -data $runnerWorkspace \
     -aut $autPath \
     -autWsPrefix $autWorkspace \
     -autConsolePrefix $autOut \
     -htmlReport $htmlReport \
     -junitReport $junitReport \
     -import $project

