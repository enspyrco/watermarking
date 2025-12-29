/* Header for ObjectDetection */

#ifndef ObjectDetection_hpp
#define ObjectDetection_hpp

#include <opencv2/opencv.hpp>

int detectObject(cv::Mat& img_object, cv::Mat& img_scene, cv::Mat& detected_img);

void detectKeypoints(cv::Ptr<cv::Feature2D> f2d, cv::Mat& img, std::vector<cv::KeyPoint>& keypoints);
void computeDescriptors(cv::Ptr<cv::Feature2D> f2d, cv::Mat& img, std::vector<cv::KeyPoint> keypoints, cv::Mat& descriptors);
void calculateGoodMatches(cv::Mat& img_object, cv::Mat& img_scene, cv::Mat& descriptors_object, cv::Mat& descriptors_scene, std::vector<cv::DMatch>& good_matches);
void calculateGoodMatchesWithBF(cv::Mat& img_object, cv::Mat& img_scene, cv::Mat& descriptors_object, cv::Mat& descriptors_scene, std::vector<cv::DMatch>& good_matches);
void calculateHomography(std::vector<cv::KeyPoint> keypoints_object, std::vector<cv::KeyPoint> keypoints_scene, std::vector<cv::DMatch> good_matches, cv::Mat& H);
void drawLinesAroundDetectedObject(cv::Mat& img_scene, cv::Mat& img_object, cv::Mat& H);
void transformObject(cv::Mat& img_scene, cv::Mat& img_object, cv::Mat& H, cv::Mat& detected_obj);

void detectWatermark(double pixelsArray[], int pixelsHeight, int pixelsWidth, double watermarkArray[], int watermarkHeight, int watermarkWidth, double correlationVals[]);

#endif /* ObjectDetection_hpp */