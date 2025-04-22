#include <vtkSmartPointer.h>
#include <vtkPolyData.h>
#include <vtkPoints.h>
#include <vtkCellArray.h>
#include <vtkTriangle.h>

// OCCT includes
#include <STEPControl_Reader.hxx>
#include <TopoDS_Shape.hxx>
#include <BRepMesh_IncrementalMesh.hxx>
#include <TopExp_Explorer.hxx>
#include <TopoDS.hxx>
#include <TopoDS_Face.hxx>
#include <Poly_Triangulation.hxx>
#include <BRep_Tool.hxx>
#include <gp_Pnt.hxx>

// Function to convert a STEP file to vtkPolyData
vtkSmartPointer<vtkPolyData> ConvertSTEPToPolyData(const std::string& stepFile)
{
    vtkSmartPointer<vtkPolyData> polyData = vtkSmartPointer<vtkPolyData>::New();
    vtkSmartPointer<vtkPoints> points = vtkSmartPointer<vtkPoints>::New();
    vtkSmartPointer<vtkCellArray> triangles = vtkSmartPointer<vtkCellArray>::New();

    STEPControl_Reader reader;
    IFSelect_ReturnStatus status = reader.ReadFile(stepFile.c_str());

    if (status != IFSelect_RetDone) {
        std::cerr << "Failed to read STEP file." << std::endl;
        return nullptr;
    }

    reader.TransferRoots();
    TopoDS_Shape shape = reader.OneShape();

    // Generate mesh with desired deflection
    BRepMesh_IncrementalMesh mesh(shape, 0.5); // 0.5 = deflection (mesh fineness)

    // Map to store already inserted points
    auto comp = [](const gp_Pnt& a, const gp_Pnt& b) {
        constexpr double eps = 1e-6;
        if (fabs(a.X() - b.X()) > eps) return a.X() < b.X();
        if (fabs(a.Y() - b.Y()) > eps) return a.Y() < b.Y();
        return a.Z() < b.Z();
    };

    std::map<gp_Pnt, vtkIdType, decltype(comp)> pointMap(comp);


    for (TopExp_Explorer faceExplorer(shape, TopAbs_FACE); faceExplorer.More(); faceExplorer.Next()) {
        TopoDS_Face face = TopoDS::Face(faceExplorer.Current());
        TopLoc_Location loc;
        Handle(Poly_Triangulation) tri = BRep_Tool::Triangulation(face, loc);

        if (tri.IsNull()) continue;

        const TColgp_Array1OfPnt& nodes = tri->Nodes();
        const Poly_Array1OfTriangle& trianglesArray = tri->Triangles();

        Standard_Integer nbNodes = tri->NbNodes();
        Standard_Integer nbTriangles = tri->NbTriangles();

        std::vector<vtkIdType> vtkPointIds(nbNodes + 1); // 1-based indexing in OCCT

        for (Standard_Integer i = 1; i <= nbNodes; ++i) {
            gp_Pnt p = tri->Node(i).Transformed(loc.Transformation());

            auto it = pointMap.find(p);
            if (it == pointMap.end()) {
                vtkIdType id = points->InsertNextPoint(p.X(), p.Y(), p.Z());
                pointMap[p] = id;
                vtkPointIds[i] = id;
            } else {
                vtkPointIds[i] = it->second;
            }
        }

        for (Standard_Integer i = 1; i <= nbTriangles; ++i) {
            int n1, n2, n3;
            tri->Triangle(i).Get(n1, n2, n3);
            vtkSmartPointer<vtkTriangle> triangle = vtkSmartPointer<vtkTriangle>::New();
            triangle->GetPointIds()->SetId(0, vtkPointIds[n1]);
            triangle->GetPointIds()->SetId(1, vtkPointIds[n2]);
            triangle->GetPointIds()->SetId(2, vtkPointIds[n3]);
            triangles->InsertNextCell(triangle);
        }
    }

    polyData->SetPoints(points);
    polyData->SetPolys(triangles);
    return polyData;
}


int main(int argc, char** argv)
{
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " model.step" << std::endl;
        return 1;
    }

    std::string stepFile = argv[1];
    vtkSmartPointer<vtkPolyData> polyData = ConvertSTEPToPolyData(stepFile);

    if (!polyData) {
        std::cerr << "Conversion failed." << std::endl;
        return 1;
    }

    std::cout << "Mesh created with " << polyData->GetNumberOfPoints() << " points and "
              << polyData->GetNumberOfCells() << " triangles." << std::endl;

    // Optionally: Save or render the polyData
    return 0;
}
