#!/usr/bin/env bash
set -ex
## x = exit immediately if a pipeline returns a non-zero status.
## e = print a trace of commands and their arguments during execution.
## See: http://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html#The-Set-Builtin

# ----- Variables -------------------------------------------------------------
# Variables in the build.properties file will be available to Jenkins
# build steps. Variables local to this script can be defined below.
. ./build.properties

# fix for jenkins inserting the windows-style path in $WORKSPACE
cd "$WORKSPACE"
export WORKSPACE=`pwd`



# ----- Common ----------------------------------------------------------------
# Common build script creates functions and variables expected by Jenkins.
if [ -d $WORKSPACE/../build-tools ]; then
  ## When script directory already exists, just update when there are changes.
  cd $WORKSPACE/../build-tools
  git fetch && git stash
  if ! git log HEAD..origin/master --oneline --quiet; then
    git pull
  fi
  cd $WORKSPACE
else
  git clone https://github.com/versionone/openAgile-build-tools.git $WORKSPACE/../build-tools
fi
source ../build-tools/common.sh

PKGID="tfsexpress.standard"
NUSPEC="$PKGID.nuspec"
CHOC_SOURCE="http://chocolatey.org/"
NUPKG="$PKGID.$VERSION_NUMBER.$BUILD_NUMBER.nupkg"

cat > "$NUSPEC" <<EOF
<?xml version="1.0"?>
<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
  <metadata>
    <id>$PKGID</id>
    <title>TFS Express 2013 standard type installation</title>
    <version>$VERSION_NUMBER.$BUILD_NUMBER</version>
    <authors>$ORGANIZATION_NAME</authors>
    <owners>$ORGANIZATION_NAME</owners>
    <summary>TFS Express 2013 standard type installation</summary>
    <description>Installs TFS Express using the standard type, and validates that IIS and SQL server are installed.</description>
    <projectUrl>$GITHUB_WEB_URL</projectUrl>
    <tags>TFS Visual Studio  Express Standard</tags>
    <licenseUrl>$GITHUB_WEB_URL/blob/master/LICENSE.md</licenseUrl>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
  </metadata>
  <files>
    <file src="tools\**" target="tools" />
  </files>
</package>
EOF

$WORKSPACE/.nuget/nuget.exe pack "$NUSPEC" 
$WORKSPACE/.nuget/nuget.exe setApiKey "$CHOC_API_KEY" -Source "$CHOC_SOURCE"
$WORKSPACE/.nuget/nuget.exe push "$NUPKG" -Source "$CHOC_SOURCE"