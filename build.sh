EZA_VERSION=$1
BUILD_VERSION=$2
declare -a arr=("bookworm" "trixie" "forky" "sid")
for i in "${arr[@]}"
do
  DEBIAN_DIST=$i
  FULL_VERSION=$EZA_VERSION-${BUILD_VERSION}+${DEBIAN_DIST}_amd64
docker build . -t eza-$DEBIAN_DIST  --build-arg DEBIAN_DIST=$DEBIAN_DIST --build-arg EZA_VERSION=$EZA_VERSION --build-arg BUILD_VERSION=$BUILD_VERSION --build-arg FULL_VERSION=$FULL_VERSION
  id="$(docker create eza-$DEBIAN_DIST)"
  docker cp $id:/eza_$FULL_VERSION.deb - > ./eza_$FULL_VERSION.deb
  tar -xf ./eza_$FULL_VERSION.deb
done


