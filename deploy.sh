#!/bin/bash

project_name=${PWD##*/}

local_maven_repo=$1

mvn -DaltDeploymentRepository=snapshot::default::file://${local_maven_repo}/snapshots clean deploy

cd ${local_maven_repo}
git status
git add .
git status
git commit -m "Release New Version of ${project_name}"
git push origin main

