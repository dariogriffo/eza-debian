EZA_VERSION=$1
BUILD_VERSION=$2
wget https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz && tar -xf eza_x86_64-unknown-linux-gnu.tar.gz && rm -f eza_x86_64-unknown-linux-gnu.tar.gz
declare -a arr=("jammy" "noble")
for i in "${arr[@]}"
do
  UBUNTU_DIST=$i
  FULL_VERSION=$EZA_VERSION-${BUILD_VERSION}+${UBUNTU_DIST}_amd64_ubu
  docker build . -f Dockerfile.ubu -t eza-ubuntu-$UBUNTU_DIST --build-arg UBUNTU_DIST=$UBUNTU_DIST --build-arg EZA_VERSION=$EZA_VERSION --build-arg BUILD_VERSION=$BUILD_VERSION --build-arg FULL_VERSION=$FULL_VERSION
  id="$(docker create eza-ubuntu-$UBUNTU_DIST)"
  docker cp $id:/eza_$FULL_VERSION.deb - > ./eza_$FULL_VERSION.deb
  tar -xf ./eza_$FULL_VERSION.deb
done
rm eza
