//
//  main2.cpp
//  WatermarkingMarkImage
//
//  Created by Nicholas Meinhold on 10/10/2016.
//  Copyright © 2016 ENSPYR. All rights reserved.
//

#include <iostream>

#include <opencv2/opencv.hpp>

#include "watermarking-functions/Utilities.hpp"
#include "watermarking-functions/WatermarkDetection.hpp"

int main(int argc, const char * argv[]) {

    // check args have been passed in
    // args are: file path for original image, file path for marked image
    if(argc != 3) {
        std::cout << "incorrect number of arguments" << std::endl;
        return -1;
    }
    
    std::string originalFilePath = argv[argc-1];
    std::string markedFilePath = argv[argc-2];
    
    // read in images and convert to 3 channel BGR
    
    cv::Mat original = cv::imread(originalFilePath, cv::IMREAD_COLOR);
    cv::Mat marked = cv::imread(markedFilePath, cv::IMREAD_COLOR);

    // check original and marked images are of equal size 

    if(original.rows != marked.rows || original.cols != marked.cols) {
        std::cout << "original and marked images are not equal sizes" << std::endl;
        return -2;
    }
    
    // calculate the largest prime for this image
    
    int p = largestPrimeFor(original);
    
    // convert images to HSV
    
    cv::Mat hsvOriginal, hsvMarked;
    cvtColor(original, hsvOriginal, cv::COLOR_BGR2HSV);
    cvtColor(marked, hsvMarked, cv::COLOR_BGR2HSV);
    
    // create 1d array with luma values (and subtract original)
    
    double* lumaArray = new double[hsvOriginal.cols*hsvOriginal.rows];
    
    for(int y = 0; y < hsvOriginal.rows; y++)
    {
        for(int x = 0; x < hsvOriginal.cols; x++)
        {
            lumaArray[y*hsvOriginal.cols + x] = (hsvMarked.at<cv::Vec3b>(y,x).val[2] - hsvOriginal.at<cv::Vec3b>(y,x).val[2]) / 255.0;
        }
    }

    double *extractedMark = new double[p*p];

    extractMark(hsvOriginal.rows, hsvOriginal.cols, p, p, lumaArray, extractedMark);


    ////////////////////////////////////////////////////////////

    
    
    
    k = 1;
    while(1) {
        watermark = [[ENSWatermark alloc] initWithPrime:arraySize andK:k andStrength:1];
        
        fastCorrelation(wm_height, wm_width, extracted_mark, watermark.array, correlation_vals);
        
        // calculate message and peak2rms
        maxVal = 0; maxX = -1; maxY = -1;
        for(y = 0; y < wm_height; y++)
        {
            for(x = 0; x < wm_width; x++)
            {
                if(correlation_vals[y*wm_width+x] > maxVal)
                {
                    maxVal = correlation_vals[y*wm_width+x];
                    maxY = y;
                    maxX = x;
                }
            }
        }
        
        ms = 0;
        for (i = 0; i < wm_size; i++)
            ms += (correlation_vals[i] * correlation_vals[i]) / wm_size;
        
        NSLog(@"luma channel - message: %d, with peak2rms: %f", maxY*wm_width+maxX, maxVal / sqrt(ms));
        
        peak2rms = maxVal / sqrt(ms);
        
        k++;
        
        if(peak2rms > 6) {
            [results addMessage: maxY*wm_width+maxX];
            [results addPeak2rms: peak2rms];
        }
        else {
            // add the last peak as well, so that results include the last rejected peak  
            [results addMessage: maxY*wm_width+maxX];
            [results addPeak2rms: peak2rms];
            break;
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
        imwrite(filePath + "-marked.png", original, compression_params);
    }
    catch (cv::Exception& ex) {
        fprintf(stderr, "Exception writing out image to PNG format: %s\n", ex.what());
        return 1;
    }
    
    // std::cout << "file is " << hsvImage.rows << " x " << hsvImage.cols << " image of type " << ocv_type2str(hsvImage.type()) << std::endl;
    
    return 0;
}
