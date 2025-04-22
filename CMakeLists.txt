cmake_minimum_required(VERSION 3.15)
project(STEPtoVTK)

set(CMAKE_CXX_STANDARD 17)

# Find VTK
find_package(VTK REQUIRED)

# Find OpenCASCADE
find_package(OpenCASCADE REQUIRED)

add_executable(step_to_vtk main.cpp)

# Include OCCT headers
target_include_directories(step_to_vtk PRIVATE
    ${OpenCASCADE_INCLUDE_DIR}
)

# Link OCCT and VTK libraries
target_link_libraries(step_to_vtk
    ${OpenCASCADE_LIBRARIES}
    ${VTK_LIBRARIES}
)

# Optional: Enable folder organization in IDEs
set_target_properties(step_to_vtk PROPERTIES FOLDER "STEP Tools")
