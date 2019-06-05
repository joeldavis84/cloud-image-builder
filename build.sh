#!/usr/bin/env bash
set -x

echo "Beginning Image Build Process"

  ## Determine target release by branch name so that we have a single and obvious source of truth.
export KUBEVIRT_VERSION=$(git branch | egrep '^\*' | awk '{print $2}' | sed 's/^release-//')

  ## Used by image bootstrap service and GCP image publish
echo $KUBEVIRT_VERSION > image-files/kubevirt-version

  ## Download virtctl if it's not already present
[ -f virtctl ] || curl -L -o image-files/virtctl https://github.com/kubevirt/kubevirt/releases/download/v${KUBEVIRT_VERSION}/virtctl-v${KUBEVIRT_VERSION}-linux-amd64
chmod +x image-files/virtctl

  ## Start the actual image build
echo "Beginning 'packer build' process..
$PACKER_BIN build -debug -machine-readable --force $PACKER_BUILD_TEMPLATE | tee build.log
echo "AWS_TEST_AMI=`egrep -m1 -oe 'ami-.{8}' build.log`" >> job.props
