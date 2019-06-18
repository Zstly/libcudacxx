#! /bin/bash

SCRIPT_PATH=$(cd $(dirname ${0}); pwd -P)
source ${SCRIPT_PATH}/configuration.bash

# Arguments are a list of SM architectures to target; if there are no arguments,
# all known SM architectures are targeted.

# Copy the .dockerignore file from //sw/gpgpu/libcudacxx to //sw/gpgpu.
cp ${SW_PATH}/gpgpu/libcudacxx/docker/.dockerignore ${SW_PATH}/gpgpu

LIBCUDACXX_COMPUTE_ARCHS="${@}" docker -D build \
  --build-arg LIBCUDACXX_SKIP_BASE_TESTS_BUILD \
  --build-arg LIBCUDACXX_COMPUTE_ARCHS \
  -t ${BASE_IMAGE} \
  -f ${BASE_DOCKERFILE} \
  ${SW_PATH}/gpgpu
if [ "${?}" != "0" ]; then exit 1; fi

# Create a temporary container so we can extract the log files.
TMP_CONTAINER=$(docker create ${BASE_IMAGE})
if [ "${?}" != "0" ]; then exit 1; fi

docker cp ${TMP_CONTAINER}:/sw/gpgpu/libcudacxx/libcxx/build/libcxx_lit.log .
docker cp ${TMP_CONTAINER}:/sw/gpgpu/libcudacxx/libcxx/build/libcxx_cmake.log .
docker cp ${TMP_CONTAINER}:/sw/gpgpu/libcudacxx/build/libcudacxx_lit.log .
docker cp ${TMP_CONTAINER}:/sw/gpgpu/libcudacxx/build/libcudacxx_cmake.log .

docker container rm ${TMP_CONTAINER}

# Remove the .dockerignore from //sw/gpgpu.
rm ${SW_PATH}/gpgpu/.dockerignore

