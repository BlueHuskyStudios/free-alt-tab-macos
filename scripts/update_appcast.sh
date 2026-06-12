#!/usr/bin/env bash

# Starting 2026-06-11, Ky forked the original repo to make this one.
# The details of changes to this file (and all other files in this repository), including when the changes were made, can be found in the Git metadata of this repository.
# If you receive a version of this repository that is lacking the Git metadata, you may contact Ky and they will provide that metadata to you free of charge: FreeAltTab@KyNorthstar.me


set -exu

version="$(cat "$VERSION_FILE")"
date="$(date +'%a, %d %b %Y %H:%M:%S %z')"
minimumSystemVersion="$(awk -F ' = ' '/MACOSX_DEPLOYMENT_TARGET/ { print $2; }' < config/base.xcconfig)"
zipName="$APP_NAME-$version.zip"
edSignatureAndLength=$(vendor/Sparkle/bin/sign_update -s $SPARKLE_ED_PRIVATE_KEY "$XCODE_BUILD_PATH/$zipName")

echo "
    <item>
      <title>Version $version</title>
      <pubDate>$date</pubDate>
      <sparkle:minimumSystemVersion>$minimumSystemVersion</sparkle:minimumSystemVersion>
      <sparkle:releaseNotesLink>https://FreeAltTab.BHStudios.org/changelog-bare</sparkle:releaseNotesLink>
      <enclosure
        url=\"https://github.com/lwouis/alt-tab-macos/releases/download/v$version/$zipName\"
        sparkle:version=\"$version\"
        sparkle:shortVersionString=\"$version\"
        $edSignatureAndLength
        type=\"application/octet-stream\"/>
    </item>
" > ITEM.txt

sed -i '' -e "/<\/language>/r ITEM.txt" appcast.xml
