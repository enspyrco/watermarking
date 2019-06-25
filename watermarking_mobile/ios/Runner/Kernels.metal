//
//  Kernels.metal
//  Runner
//
//  Created by Nicholas Meinhold on 24/6/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include <CoreImage/CoreImage.h> // includes CIKernelMetalLib.h

extern "C" { namespace coreimage {
    
    float4 weightColor(sample_t s, float weight) {
        return weight*s;
    }
    
    float4 blendWeighted(sample_t foreground, sample_t background) {
        return foreground + background;
    }
    
}}

