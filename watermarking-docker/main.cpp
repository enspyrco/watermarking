//
//  main.cpp
//  WatermarkingMarkImage
//
//  Created by Nicholas Meinhold on 9/09/2016.
//  Copyright © 2016 ENSPYR. All rights reserved.
//

#include <iostream>

#include <opencv2/opencv.hpp>

#include "watermarking-functions/Utilities.hpp"
#include "watermarking-functions/WatermarkDetection.hpp"

int main(int argc, const char * argv[]) {
    
    // check args have been passed in
    // args are: file path, image name, strength
    if(argc != 4) {
        std::cout << "incorrect number of arguments" << std::endl;
        return -1;
    }
    
    // std::cout << "image name: " << argv[argc-3] << ", message = " << argv[argc-2] << std::endl;
    
    int strength = atoi(argv[argc-1]);
    std::string message = argv[argc-2];
    std::string img_name = argv[argc-3]; 
    
    // read in image and convert to 3 channel BGR
    
    cv::Mat original = cv::imread(argv[argc-3], cv::IMREAD_COLOR);
    
    // calculate the largest prime for this image
    
    int p = largestPrimeFor(original);
    
    // convert image to HSV
    
    cv::Mat hsvImage;
    cvtColor(original, hsvImage, cv::COLOR_BGR2HSV);
    
    // create a 1d array with luma values
    
    double* lumaArray = new double[hsvImage.cols*hsvImage.rows];
    
    for(int y = 0; y < hsvImage.rows; y++)
    {
        for(int x = 0; x < hsvImage.cols; x++)
        {
            lumaArray[y*hsvImage.cols + x] = hsvImage.at<cv::Vec3b>(y,x).val[2] / 255.0;
        }
    }
    
    // create the watermark array
    
    double* wmArray = new double[p*p];
    
    // generate each array and mark the image
    
    std::vector<int> messageShifts = getShifts(message, p*p);
    for(int k = 1; k <= messageShifts.size(); k++) {
        
        generateArray(p, k, wmArray);
        
        // multiply the watermark array by the strength
        
        for(int i = 0; i < p*p; i++) {
            wmArray[i] = wmArray[i]*strength;
        }
        
        // mark the luma data
        
        insertMark(hsvImage.rows, hsvImage.cols, p, p, lumaArray, wmArray, messageShifts[k-1]);
        
    }
    
    // put the marked luma data back into the original image
    
    for(int y = 0; y < hsvImage.rows; y++)
    {
        for(int x = 0; x < hsvImage.cols; x++)
        {
            float lumaValue = lumaArray[y*hsvImage.cols + x] * 255.0;
            
            if(lumaValue > 255.0) hsvImage.at<cv::Vec3b>(y,x).val[2] = 255;
            else if (lumaValue < 0.0) hsvImage.at<cv::Vec3b>(y,x).val[2] = 0;
            else {
                hsvImage.at<cv::Vec3b>(y,x).val[2] = (int)(round(lumaValue));
            }
            
        }
    }
    
    // convert back to BGR (required by imwrite)
    
    cvtColor(hsvImage, original, cv::COLOR_HSV2BGR);
    
    // IMWRITE_PNG_COMPRESSION
    // compression level from 0 to 9. A higher value means a smaller size and longer compression time
    
    std::vector<int> compression_params;
    compression_params.push_back(cv::IMWRITE_PNG_COMPRESSION);
    compression_params.push_back(9);
    
    try {
        imwrite(img_name+".png", original, compression_params);
    }
    catch (cv::Exception& ex) {
        fprintf(stderr, "Exception writing out image to PNG format: %s\n", ex.what());
        return 1;
    }
    
    // std::cout << "file is " << hsvImage.rows << " x " << hsvImage.cols << " image of type " << ocv_type2str(hsvImage.type()) << std::endl;
    
    return 0;
}
