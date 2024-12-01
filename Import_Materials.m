% Import_Materials.m        
% - Import Material Library
function [mat1, mat2, N] = Import_Materials(mat_index, mat_lib_external)

    if (mat_lib_external) % Import materials if gui toggle is used
        mat_lib = ImportExportExcel('r', 0, 'Select Material Library');
    else
        filename =  "Material_Lib.xlsx";
        mat_lib = ImportExcel(filename);
    end
    mat1 = MATERIAL; mat2 = MATERIAL;
    
    [N,~] = size(mat_lib);
    
    if mat_index > N
        return
    end

    mat1.mat = char(mat_lib{mat_index(1),1});           mat2.mat = char(mat_lib{mat_index(2),1});
    mat1.mod_of_elasticity = mat_lib{mat_index(1),2};   mat2.mod_of_elasticity = mat_lib{mat_index(2),2};
    mat1.yield_strength = mat_lib{mat_index(1),3};      mat2.yield_strength = mat_lib{mat_index(2),3};
    mat1.mod_of_shear = mat_lib{mat_index(1),4};        mat2.mod_of_shear = mat_lib{mat_index(2),4};
    mat1.shear_strength = mat_lib{mat_index(1),5};      mat2.shear_strength = mat_lib{mat_index(2),5};
    mat1.poisson_ratio = mat_lib{mat_index(1),6};       mat2.poisson_ratio = mat_lib{mat_index(2),6};
    
end