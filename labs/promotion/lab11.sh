#!/bin/bash

cd /home/conan/conan_ci_cd/labs/promotion

## lab11: 

jfrog rt c --interactive=false  --url=http://jfrog.local:8081/artifactory --user=conan --password=conan2020 art7 

# show current art7 profile
jfrog rt c show

# test connection by listing the repo content
jfrog rt search conan-metadata/
