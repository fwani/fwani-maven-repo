#!/bin/bash

function usage() {
  echo "$0 [OPTIONS] <local_maven_repo>"
  echo "    -h                    도움말 출력"
  echo "    -v version            빌드 버전 (default: v0.1.0)"
  echo "    -s                    SnapShot 버전을 빌드 (default: false)"
  echo "local_maven_repo          로컬 레파지토리 경로 (required)"
  exit 1
}


function set_options() {
  opts=$(getopt --options "v:s" \
                         --longoptions "version:,snapshot" \
                         --name "$(basename $0)" \
                         -- "$@")

  while [[ $# > 1 ]]; do
    case "$1" in
      -v | --version)
        version=$2
        shift 2
        ;;
      -s | --sanpshot)
        snapshot=true
        shift
        ;;
      --)
        shift
        break
        ;;
      *) usage ;;
    esac
  done

  # 남은 인자
  local_maven_repo=$@

  if [[ -z "$local_maven_repo" ]]; then
    echo "local_maven_repo path is required !!!"
    usage
  fi

  echo "version `printf %49s $version`"
  echo "is snapshot version `printf %37s $snapshot`"
  echo "local_maven_repo `printf %40s $local_maven_repo`"
  echo "--------------- Complete to set Arguments ---------------"
  echo ""
}

version=0.0.1
snapshot=false

set_options "$@"


project_name=${PWD##*/}

if [ $snapshot == true ]; then
  version=`echo "$version-SNAPSHOT"`
  echo "build version `printf %43s $version`"
  ./mvnw -Drevision=$version -DaltDeploymentRepository=snapshot::default::file://${local_maven_repo}/snapshots clean deploy
else
  echo "build version `printf %43s $version`"
  ./mvnw -Drevision=$version -DaltDeploymentRepository=releases::default::file://${local_maven_repo}/releases clean deploy
fi
echo "--------------- Complete to build project ---------------"
echo ""

cd ${local_maven_repo}
git status
git add .
git status
git commit -m "Release New Version of ${project_name}"
git push origin main
echo "---------------- Complete to add package ----------------"

