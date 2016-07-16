/* Header for ObjectDetection */

#include <opencv2/opencv.hpp>

int detectObject(cv::Mat& img_object, cv::Mat& img_scene, cv::Mat& detected_img);

void detectWatermark(double pixelsArray[], int pixelsHeight, int pixelsWidth, double watermarkArray[], int watermarkHeight, int watermarkWidth, double correlationVals[]);