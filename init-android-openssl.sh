#! /usr/bin/env bash
#
# Copyright (C) 2013-2015 Bilibili
# Copyright (C) 2013-2015 Zhang Rui <bbcallen@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

CURRENT_DIR=$(dirname "$(readlink -f "$0")")
IJK_OPENSSL_UPSTREAM=https://github.com/openssl/openssl.git
IJK_OPENSSL_FORK=https://github.com/openssl/openssl.git
IJK_OPENSSL_COMMIT=openssl-3.2
IJK_OPENSSL_LOCAL_REPO=$CURRENT_DIR/extra/openssl

set -e
TOOLS=$CURRENT_DIR/tools

echo "== pull openssl base =="
sh $TOOLS/pull-repo-base.sh $IJK_OPENSSL_UPSTREAM $IJK_OPENSSL_LOCAL_REPO
cd ${IJK_OPENSSL_LOCAL_REPO}
git checkout ${IJK_OPENSSL_COMMIT}
sed -i 's|which("clang") =~ m|which("clang") !=~ m|' ./Configurations/15-android.conf
cd -
