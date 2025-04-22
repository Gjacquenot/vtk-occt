all: docker_build docker_run

DOCKER_IMAGE=sirehna/base-image-ubuntu24-gcc13-vtk9-occt7:2025-04-22

docker_build:
	docker build -t ${DOCKER_IMAGE} .

docker_run:
	docker run --rm -v $(shell pwd):/workspace ${DOCKER_IMAGE} bash -c "\
		cd /workspace && make compile && ./build/vtk_occ"

compile:
	mkdir -p build \
	&& cd build \
	&& cmake .. -DOpenCASCADE_DIR=/opt/occt/lib/cmake/opencascade -DVTK_DIR=/opt/vtk/lib/cmake/vtk \
	&& make
