% Import_Materials.m        
% - Import Material Library
function [mat1, mat2] = Import_Materials(mat_index, mat_lib_external)

    if (mat_lib_external) % Import materials if gui toggle is used
        mat_lib = ImportExportExcel('r', 0, 'Select Material Library');
    else
        filename =  "Material_Lib.xlsx";
        mat_lib = ImportExcel(filename);
    end

    mat1 = mat_lib{mat_index(1),2:6};
    mat2 = mat_lib{mat_index(2),2:6};

end