#!/bin/bash

MULE_BINARY_DOWNLOAD_URL=$1
MULE_VERSION=$2

# get release version
RELEASE=$(cat /etc/redhat-release)
YUM_ARGS="--setopt=tsflags=nodocs"

# shared packages
PACKAGES="wget java-1.8.0-openjdk-devel maven zip"

# if the release is a red hat version then we need to set additional arguments for yum repositories
RED_HAT_MATCH='^Red Hat.*$'
if [[ $RELEASE =~ $RED_HAT_MATCH && -z "$USE_SYSTEM_REPOS" ]]; then
  YUM_ARGS="--disablerepo=\* --enablerepo=rhel-7-server-rpms --enablerepo=rhel-server-rhscl-7-rpms --enablerepo=rhel-7-server-optional-rpms ${YUM_ARGS} "
fi

# enable epel when on CentOS
CENTOS_MATCH='^CentOS.*'
if [[ $RELEASE =~ $CENTOS_MATCH && -z "$USE_SYSTEM_REPOS" ]]; then
  rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
  yum install -y epel-release centos-release-scl-rh
fi

# ensure latest versions
yum update -y $YUM_ARGS

# install all required packages
yum install -y ${YUM_ARGS}  ${PACKAGES}

# clean up yum to make sure image isn't larger because of installations/updates
yum clean all
rm -rf /var/cache/yum/*
rm -rf /var/lib/yum/*

cd /opt
wget ${MULE_BINARY_DOWNLOAD_URL}
tar -xf mule-standalone-${MULE_VERSION}.tar.gz
mv mule-standalone-${MULE_VERSION}  mule
rm -rf mule-standalone-${MULE_VERSION}.tar.gz*
