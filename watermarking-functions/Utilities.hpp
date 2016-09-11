//
//  Utilities.hpp
//  WatermarkingFunctionsTests
//
//  Created by Nicholas Meinhold on 17/07/2016.
//  Copyright © 2016 ENSPYR. All rights reserved.
//

#ifndef Utilities_hpp
#define Utilities_hpp

#include <opencv2/opencv.hpp>

std::string ocv_type2str(int type);
void saveImageToFile(std::string file_name, cv::Mat& imageMat);
int largestPrimeFor(cv::Mat& imgMat);
void findShiftAndPSNR(double* array, int array_len, double& peak2rms, int& shift);

#endif /* Utilities_hpp */
