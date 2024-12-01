% Class to define Materials as an Object
classdef MATERIAL
   properties
        mat = "";
        mod_of_elasticity;
        yield_strength;
        mod_of_shear;
        shear_strength;
        poisson_ratio;
   end
end