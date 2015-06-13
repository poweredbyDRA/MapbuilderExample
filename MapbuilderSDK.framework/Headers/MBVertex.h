//  Created by Alejandro Isaza on 2013-03-31.
//  Copyright (c) 2013 Synergy Media. All rights reserved.

#ifndef __MapbuilderSDK__MBVertex__
#define __MapbuilderSDK__MBVertex__

#include <gsim/se_mesh_import.h>

class MBVertex;
class MBEdge;
class MBFace;

typedef Se < MBVertex, MBEdge, MBFace > MBSymEdge;
typedef SeMesh < MBVertex, MBEdge, MBFace > MBMesh;

SE_DEFINE_DEFAULT_ELEMENT(MBEdge,MBSymEdge);
SE_DEFINE_DEFAULT_ELEMENT(MBFace,MBSymEdge);


class MBVertex : public SeElement {
public:
    float x, y;
    
public :
    SE_ELEMENT_CASTED_METHODS(MBVertex,MBSymEdge);
    
    MBVertex() : x(), y() {}
    
    MBVertex(const MBVertex& v) : SeElement(), x(v.x), y(v.y) {}
    
    void set(float x, float y) { this->x = x; this->y = y; }
    
    friend GsOutput& operator<<(GsOutput& out, const MBVertex& v) {
        return out << v.x << ',' << v.y;
    }
        
    friend GsInput& operator>>(GsInput& inp, MBVertex& v) {
        inp >> v.x;
        inp.skip();
        inp >> v.y;
        return inp;
    }
        
    static inline int compare (const MBVertex* v1, const MBVertex* v2) { return 0; } // not used
};

#endif
