#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/core/core.hpp>

#include <stdio.h>
#include <iostream>
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/calib3d/calib3d.hpp"
#include "opencv2/xfeatures2d/nonfree.hpp"

#include <string>
#include <vector>

#include "watermarking-functions/WatermarkDetection.hpp"

// see http://docs.opencv.org/doc/tutorials/features2d/feature_homography/feature_homography.html
// also: http://stackoverflow.com/a/27533437/1992736 (for recent changes to using SURF)

using namespace std;
using namespace cv;

int detectObject(Mat& img_object, Mat& img_scene, Mat& detected_img)
{

    try
	{

		//-- Step 1: Detect the keypoints using SURF Detector
		
        cv::Ptr<Feature2D> f2d = xfeatures2d::SURF::create();

		std::vector<KeyPoint> keypoints_object, keypoints_scene;

		f2d->detect( img_object, keypoints_object );
  		f2d->detect( img_scene, keypoints_scene );

		//-- Step 2: Calculate descriptors (feature vectors)
		
        Mat descriptors_object, descriptors_scene;

		f2d->compute( img_object, keypoints_object, descriptors_object );
  		f2d->compute( img_scene, keypoints_scene, descriptors_scene );

		//-- Step 3: Matching descriptor vectors using FLANN matcher
		
        FlannBasedMatcher matcher;
		std::vector< DMatch > matches;
		matcher.match( descriptors_object, descriptors_scene, matches );

		double max_dist = 0; double min_dist = 100;

		//-- Quick calculation of max and min distances between keypoints
		for( int i = 0; i < descriptors_object.rows; i++ )
		{
			double dist = matches[i].distance;
		    if( dist < min_dist ) min_dist = dist;
		    if( dist > max_dist ) max_dist = dist;
		}

		//-- Draw only "good" matches (i.e. whose distance is less than 3*min_dist )
		std::vector< DMatch > good_matches;

		for( int i = 0; i < descriptors_object.rows; i++ )
		{
			if( matches[i].distance < 3*min_dist )
			{ good_matches.push_back( matches[i]); }
		}

		//-- Localize the object
		std::vector<Point2f> obj;
		std::vector<Point2f> scene;

		for( int i = 0; i < good_matches.size(); i++ )
		{
			//-- Get the keypoints from the good matches
			obj.push_back( keypoints_object[ good_matches[i].queryIdx ].pt );
			scene.push_back( keypoints_scene[ good_matches[i].trainIdx ].pt );
		}

		Mat H = findHomography( obj, scene, CV_RANSAC );
		Mat Hinverse = H.inv();

		//-- Get the corners from the image_1 ( the object to be "detected" )
		std::vector<Point2f> obj_corners(4);
		obj_corners[0] = cvPoint(0,0); obj_corners[1] = cvPoint( img_object.cols, 0 );
		obj_corners[2] = cvPoint( img_object.cols, img_object.rows ); obj_corners[3] = cvPoint( 0, img_object.rows );
		std::vector<Point2f> scene_corners(4);

		perspectiveTransform( obj_corners, scene_corners, H);

		// use the inverse perspective transform to extract the object image from the scene
		warpPerspective(img_scene, detected_img, Hinverse, img_object.size());

		//-- Draw lines between the corners (the mapped object in the scene - image_2 )
		line( img_scene, scene_corners[0], scene_corners[1], Scalar( 0, 255, 0), 12 );
		line( img_scene, scene_corners[1], scene_corners[2], Scalar( 0, 255, 0), 12 );
		line( img_scene, scene_corners[2], scene_corners[3], Scalar( 0, 255, 0), 12 );
		line( img_scene, scene_corners[3], scene_corners[0], Scalar( 0, 255, 0), 12 );

		return good_matches.size();

	}
	catch(cv::Exception& e)
	{
//		LOGD("nativeCreateObject caught cv::Exception: %s", e.what());
        return 0;
        
	}
	catch (...)
	{
//		LOGD("nativeDetect caught unknown exception");
        return 0;
	}

}

void detectWatermark(double pixelsArray[], int pixelsHeight, int pixelsWidth, double watermarkArray[], int watermarkHeight, int watermarkWidth, double correlationVals[])
{
	double *extracted_mark = new double[watermarkHeight*watermarkWidth];

	extractMark(pixelsHeight, pixelsWidth, watermarkHeight, watermarkWidth, pixelsArray, extracted_mark);

    fastCorrelation(watermarkHeight, watermarkWidth, extracted_mark, watermarkArray, correlationVals);

	delete[] extracted_mark;

}

