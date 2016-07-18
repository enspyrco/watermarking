//
//  Utilities.cpp
//  WatermarkingFunctionsTests
//
//  Created by Nicholas Meinhold on 17/07/2016.
//  Copyright © 2016 ENSPYR. All rights reserved.
//

#include "Utilities.hpp"

// convert opencv type to a human readable string
// Note: code taken from Stack Overflow answer, don't assume it is correct
// http://stackoverflow.com/a/17820615/1992736 
std::string ocv_type2str(int type) {
    std::string r;
    
    uchar depth = type & CV_MAT_DEPTH_MASK;
    uchar chans = 1 + (type >> CV_CN_SHIFT);
    
    switch ( depth ) {
        case CV_8U:  r = "8U"; break;
        case CV_8S:  r = "8S"; break;
        case CV_16U: r = "16U"; break;
        case CV_16S: r = "16S"; break;
        case CV_32S: r = "32S"; break;
        case CV_32F: r = "32F"; break;
        case CV_64F: r = "64F"; break;
        default:     r = "User"; break;
    }
    
    r += "C";
    r += (chans+'0');
    
    return r;
}

// Used in test project to save output  
void saveImageToFile(std::string file_name, cv::Mat& imageMat) {
    
    std::vector<int> compression_params;
    compression_params.push_back(CV_IMWRITE_PNG_COMPRESSION);
    compression_params.push_back(9);
    
    try {
        imwrite(file_name, imageMat, compression_params);
    }
    catch (std::runtime_error& ex) {
        std::cerr << "Exception converting " << file_name << " image to PNG format: " << ex.what() << std::endl;
    }
    
}

// find the shift of the array that was used for the watermark (ie. the peak) and the PSNR of the correlations
void findShiftAndPSNR(double* correlation_vals, int array_len, double& peak2rms, int& peak_pos) {
    
    // find the peak value and it's position
    double maxVal = 0.0;
    int i, maxI = -1;
    for(i = 0; i < array_len; i++)
    {
        if(correlation_vals[i] > maxVal)
        {
            maxVal = correlation_vals[i];
            maxI = i;
        }
    }
    
    // use the peak value to find the PSNR
    double ms = 0;
    for (i = 0; i < array_len; i++)
        ms += (correlation_vals[i] * correlation_vals[i]) / array_len;
    
    // assign the shift and peak2rms to the passed in variables
    peak_pos = maxI;
    peak2rms = maxVal / sqrt(ms);
    
}
