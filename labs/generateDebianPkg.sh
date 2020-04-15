#!/bin/bash

# find path to conan_package.tgz
version=`jfrog rt curl -XPOST -T automation/query.aql api/search/aql | grep value | cut -d: -f2| cut -d\" -f2`
the_path=`jfrog rt curl -XPOST -T automation/query.aql api/search/aql | grep path | cut -d: -f2| cut -d\" -f2`
echo $the_path

# download conan_package.tgz
sed "s#PATH#${the_path}#" automation/filespec_tpl.json > filespec.json
jfrog rt download --spec=filespec.json

# generate debian package
rm -rf debian_gen
mkdir -p debian_gen/myapp2_${version}/{DEBIAN,var}
mkdir -p debian_gen/myapp2_${version}/var/myapp2

#extract app
tar -xzf conan_package.tgz -C debian_gen/ 

cat << 'EOL' >> debian_gen/myapp2_${version}/DEBIAN/control
Package: app2 
Architecture: all
Maintainer: Yann Chaysinh
Priority: optional
Version: <VERSION>
Description: My Simple Debian package to deploy my 
EOL

sed -i "s/<VERSION>/${version}/" debian_gen/myapp2_${version}/DEBIAN/control

cp debian_gen/bin/App2 debian_gen/myapp2_${version}/var/myapp2/

dpkg-deb --build debian_gen/myapp2_${version}

dpkg -c debian_gen/myapp2_${version}.deb

# upload debian package
curl -u$1:$2 -XPUT "http://jfrog.local:8081/artifactory/app-debian-sit-local/pool/myapp2_${version}.deb;deb.distribution=stretch;deb.component=main;deb.architecture=x86-64" -T debian_gen/myapp2_${version}.deb 

