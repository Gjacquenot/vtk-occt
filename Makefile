all: docker_build docker_run

docker_build:
	docker build -t vtk-occ .

docker_run:
	docker run --rm -v $(shell pwd):/workspace vtk-occ bash -c "\
		cd /workspace && make compile && ./build/vtk_occ"

compile:
	mkdir -p build \
	&& cd build \
	&& cmake .. -DOpenCASCADE_DIR=/opt/occt/lib/cmake/opencascade -DVTK_DIR=/opt/vtk/lib/cmake/vtk \
	&& make
