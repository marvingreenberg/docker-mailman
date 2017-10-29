#!/bin/sh

# If this was a cron build for dev image, do not push other image tags.

function login_dockerhub () {
		docker login -e $DOCKER_EMAIL -u $DOCKER_USER -p $DOCKER_PASS
}


function push_dockerhub () {
		if [ -z "$1" ]
		then
				echo "Define the tag for core."
				return 1
		fi
		core_tag="$1"

		if [-z "$2" ]
		then
				echo "Define the tag for web."
				return 1
		fi
		web_tag="$2"

		docker push docker.io/maxking/mailman-web:$web_tag
		docker push docker.io/maxking/mailman-core:$core_tag
}


function push_rolling_rellease () {
		push_dockerhub "rolling" "rolling"
}


function push_latest_release () {
		push_dockerhub "latest" "latest"
}


if [[ "$TRAVIS_BRANCH" == "master" ]]
then
		login_dockerhub
		# If this was a cron job, rolling release was built. Only push that release
		# to the DockerHub.
		if [[ "$TRAVIS_EVENT_TYPE" = "cron" ]]
		then
				push_rolling_release()
		else
				push_latest_release()
		fi
else
		# Do not push anything for non-master builds.
		echo "Non-master branch aren't pushed to DockerHub..."
fi
