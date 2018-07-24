#!/usr/bin/env bash
if [ "$TRAVIS_PULL_REQUEST" = false ]; then
	if [ "$TRAVIS_TAG" ]; then
		cd $TRAVIS_BUILD_DIR/app/build/outputs/apk/release/
		
		printf "\nGetting tag information\n"
		tagInfo="$(curl https://api.github.com/repos/${TRAVIS_REPO_SLUG}/releases/tags/${TRAVIS_TAG})"
		releaseId="$(echo "$tagInfo" | jq ".id")"
		releaseNameOrg="$(echo "$tagInfo" | jq --raw-output ".tag_name")"
		releaseName=$(echo $releaseNameOrg | cut -d "\"" -f 2)
		changesOrg="$(echo "$tagInfo" | jq --raw-output ".body")"
		changes=$(echo $changesOrg | cut -d "\"" -f 2)
		repoName=$(echo $TRAVIS_REPO_SLUG | cut -d / -f 2)
		
		printf "\n\n"
		for apk in $(find *.apk -type f); do
			apkName="${apk::-4}"
			printf "Uploading: $apkName.apk ...\n"
			upload=`curl "https://uploads.github.com/repos/jahirfiquitiva/Blueprint/releases/12081257/assets?access_token=1dd2977505fc5a67106c96022f0e207bbb55bdbb&name=file.zip" --header 'Content-Type: application/zip' --upload-file file.zip  -X POST`
			printf "\nResult: $upload\n"
			urlText="$(echo "$upload" | jq --raw-output ".browser_download_url")"
			if [ "$urlText" ]; then
				url=$(echo $urlText | cut -d "\"" -f 2)
				printf "\nAPK url: $url"
				teleMess="*New $repoName version available now!*\nVersion: $releaseName\nChanges:\n$changes\n\n"
				printf "Sending message: $teleMess"
				curl "https://api.telegram.org/bot${TEL_BOT_KEY}/sendMessage?chat_id=@JFsDashSupport&text=${teleMess}&parse_mode=Markdown"
			fi
		done

		printf "\n\nFinished uploading APK(s)\n"
	else
		printf "\nSkipping APK(s) upload because this commit does not have a tag\n"
	fi
else
	printf "\nSkipping APK(s) upload because this is just a pull request\n"
fi
