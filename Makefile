# Local podspec repo
REPO=IDZPodspecs
# Library name
NAME=IDZXMLParser

# Remote podspec repo
PODSOURCES="https://github.com/iosdevzone/${REPO}.git,https://github.com/CocoaPods/Specs.git"
# Podspec file name
PODSPEC=${NAME}.podspec
PODFLAGS=--allow-warnings

# push tags to GitHub
push_tags:
	git push origin --tags

# Lint the podspec
lint_pod:
	pod spec lint --verbose ${PODSPEC} --sources=${PODSOURCES} ${PODFLAGS}

# Push pod to private spec repository
push_pod:
	pod repo push ${REPO} ${NAME}.podspec ${PODFLAGS}
