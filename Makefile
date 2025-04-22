all: docker_build docker_compile

DOCKER_IMAGE=sirehna/base-image-ubuntu24-gcc13-vtk9-occt7:2025-04-22

docker_build:
	docker build -t ${DOCKER_IMAGE} .

docker_compile:
	docker run --rm -v $(shell pwd):/workspace -w /workspace ${DOCKER_IMAGE} bash -c "\
		make compile"

docker_run:
	docker run --rm -v $(shell pwd):/workspace -w /workspace ${DOCKER_IMAGE} bash -c "\
		make compile && ./build/step_to_vtk"

compile:
	mkdir -p build \
	&& cd build \
	&& cmake .. -DOpenCASCADE_DIR=/opt/occt/lib/cmake/opencascade -DVTK_DIR=/opt/vtk/lib/cmake/vtk \
	&& make
