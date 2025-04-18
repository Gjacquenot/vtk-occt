build:
	docker build -t vtk-occ-norender .

run:
	docker run -it --rm -v $(shell pwd):/workspace vtk-occ-norender

compile:
	mkdir build
	cd build
	cmake .. -DOpenCASCADE_DIR=$OpenCASCADE_DIR -DVTK_DIR=$VTK_DIR
	make