//  Created by Alejandro Isaza on 2013-03-31.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#ifndef __MapbuilderSDK__MBImporter__
#define __MapbuilderSDK__MBImporter__

#include <iostream>
#include <vector>

#include <gsim/se_mesh.h>
#include <gsim/se_mesh_import.h>

#include "MBVertex.h"


class MBImport : public SeMeshImport {
private:
    std::vector<MBVertex> _vertices;
    std::vector<int> _triangles;
    
public:
    MBImport(std::istream& is);
    MBMesh* import();
    
    const std::vector<MBVertex>& vertices() const { return _vertices; }
    const std::vector<int>& triangles() const { return _triangles; }
    
    virtual SeMeshBase* get_new_shell();
    virtual void attach_vtx_info(SeVertex* v, int vi);
    
};

#endif
