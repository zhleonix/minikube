#!/bin/bash

# Copyright 2016 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script builds the minikube binary for all 3 platforms and uploads them.
# This is to done as part of the CI tests for Github PRs

# The script expects the following env variables:
# ghprbPullId: The pull request ID, injected from the ghpbr plugin.
# ghprbActualCommit: The commit hash, injected from the ghpbr plugin.

set -e

gsutil cp gs://minikube-builds/logs/index.html gs://minikube-builds/logs/${ghprbPullId}/index.html

# If there are ISO changes, build and upload the ISO
# then set the default to the newly built ISO for testing
if out="$(git diff ${ghprbActualCommit} --name-only $(git merge-base origin/master ${ghprbActualCommit}) | grep deploy/iso/minikube)" &> /dev/null; then
	echo "ISO changes detected ... rebuilding ISO"
	export ISO_BUCKET="minikube-builds/${ghprbPullId}"
	export ISO_VERSION="testing"

	make release-iso
fi

export GOPATH=~/go

# Build all platforms (Windows, Linux, OSX)
BUILD_IN_DOCKER=y make cross

# Build the e2e test target for Darwin and Linux. We don't run tests on Windows yet.
# We build these on Linux, but run the tests on different platforms.
# This makes it easier to provision slaves, since they don't need to have a go toolchain.'
GOOS=darwin GOARCH=amd64 go test -c k8s.io/minikube/test/integration --tags=integration -o out/e2e-darwin-amd64
GOOS=linux GOARCH=amd64 go test -c k8s.io/minikube/test/integration --tags=integration -o out/e2e-linux-amd64
GOOS=windows GOARCH=amd64 go test -c k8s.io/minikube/test/integration --tags=integration -o out/e2e-windows-amd64.exe
cp -r test/integration/testdata out/

# Don't upload the buildroot artifacts if they exist
rm -r out/buildroot || true

# Upload everything we built to Cloud Storage.
gsutil -m cp -r out/* gs://minikube-builds/${ghprbPullId}/
