
#include <opencv2/core/core.hpp>

using namespace std;
using namespace cv;

// p is any prime, k is a constant that defines the family of arrays produced by shifts
// array is assumed to be packed into 1d, in row major order
void generateArray(int p, int k, double* array)
{
    int i, j, shift;
    int* legendre = new int[p];
    
    // set all values to -1
    for(i = 0; i < p; i++)
    {
        legendre[i] = -1;
    }
    // set all values where index is a square (mod p) to 1
    for(i = 0; i < p; i++)
    {
        j = (i*i) % p;
        legendre[j] = 1;
    }
    // shift the legendre sequence to make up each column
    for(i = 0; i < p; i++)
    {
        shift = (i*i*k) % p;
        for(j = 0; j < p; j++) {
            array[j*p+i] = legendre[(j+shift)%p];
        }
    }
    
}

// takes 2d array in the form of a 1d array in row major order
// applies right shift, then downward shift
//  - right shift = message % array_width, down shift = message / array_width
void shiftIntoNewArray(double* array, double* shifted_array, int array_height, int array_width, int message_num)
{
	int v_shift, h_shift;
	v_shift = (message_num / array_width) % array_height;
	h_shift = message_num % array_width;

	int i, j, k, l;
	for (i = 0; i < array_height; i++)
	{
		k = (i + v_shift) % array_height;
		for (j = 0; j < array_width; j++)
		{
			l = (j + h_shift) % array_width;
			shifted_array[k*array_width + l] = array[i*array_width + j];
		}
	}

}

int fastCorrelation(int height, int width, double *matrix1, double *matrix2, double* correlation_vals)
{

    // TODO - need to check array sizes are the same, return -1 if not 
    // TODO - this function could be sped up using the packed format for the complex output
    //      - (see http://docs.opencv.org/modules/core/doc/operations_on_arrays.html#dft)
    //      - this would require coding the complex multiplication and complex conjugate
    
    int i,j;
    Mat mat1 = Mat(height, width, DataType<double>::type, matrix1);
    Mat mat2 = Mat(height, width, DataType<double>::type, matrix2);

    mat1.convertTo(mat1, CV_32F);
    mat2.convertTo(mat2, CV_32F);

    cv::Mat mat3;

    // Note: the matrix is not padded in this case, as padding to increase speed alters the result of the cross-correlation

    Mat planes1[] = {Mat_<float>(mat1), Mat::zeros(mat1.size(), CV_32F)};
    Mat planes2[] = {Mat_<float>(mat2), Mat::zeros(mat2.size(), CV_32F)};
    Mat complexI1, complexI2;

    merge(planes1, 2, complexI1);         // Add to the expanded another plane with zeros
    merge(planes2, 2, complexI2);           // this way the result may fit in the source matrix

    dft(mat1, complexI1, DFT_COMPLEX_OUTPUT, mat1.rows);
    dft(mat2, complexI2, DFT_COMPLEX_OUTPUT, mat2.rows);

    split(complexI1, planes1);                   // planes[0] = Re(DFT(I), planes[1] = Im(DFT(I))
    split(complexI2, planes2);

    complex<float> z1, z2, z3;

    for(i = 0; i < mat1.rows; i++)
    {
        for(j = 0; j < mat1.cols; j++)
        {
            z1 = complex<float>(planes1[0].at<float>(i,j), planes1[1].at<float>(i,j));
            z2 = complex<float>(planes2[0].at<float>(i,j), planes2[1].at<float>(i,j));
            z3 = z1 * std::conj(z2);

            // put the result back in
            planes1[0].at<float>(i,j) = z3.real();
            planes1[1].at<float>(i,j) = z3.imag();
        }
    }

    merge(planes1, 2, complexI1);

    //calculating the idft
    Mat inverseTransform;
    dft(complexI1, inverseTransform, DFT_INVERSE|DFT_REAL_OUTPUT|DFT_SCALE);

    for(i = 0; i < height; i++)
    {
        for(j = 0; j < width; j++)
        {
            correlation_vals[i*width+j] = inverseTransform.at<float>(i,j);
        }
    }

	return 1;

}

int extractMark(int pixelsHeight, int pixelsWidth, int watermarkHeight, int watermarkWidth, double* pixelsArray, double* extracted_mark)
{
	int i,j;
    Mat mat = Mat(pixelsHeight, pixelsWidth, cv::DataType<double>::type, pixelsArray);

    cv::dft(mat, mat, cv::DFT_REAL_OUTPUT, mat.rows);

    for(i = 0; i < watermarkHeight; i++)
        for(j = 0; j < watermarkWidth; j++)
            extracted_mark[i*watermarkWidth+j] = mat.at<double>(i+1,j+1);

    return 1;

}

int insertMark(int pixelsHeight, int pixelsWidth, int watermarkHeight, int watermarkWidth, double* pixelsArray, double* watermarkArray)
{

	int i,j;
    Mat mat = cv::Mat(pixelsHeight, pixelsWidth, cv::DataType<double>::type, pixelsArray);

    cv::dft(mat, mat, cv::DFT_REAL_OUTPUT, mat.rows);

    for(i = 0; i < watermarkHeight; i++)
        for(j = 0; j < watermarkWidth; j++)
            mat.at<double>(i+1,j+1) += watermarkArray[i*watermarkWidth+j];

    cv::dft(mat, mat, cv::DFT_INVERSE|cv::DFT_REAL_OUTPUT|cv::DFT_SCALE);

    for(i = 0; i < mat.rows; i++)
        for(j = 0; j < mat.cols; j++)
        	pixelsArray[i*mat.cols+j] = mat.at<double>(i,j);

    return 1;

}

// Note: original watermark remains unshifted, ie. no side effects 
int insertMark(int pixelsHeight, int pixelsWidth, int watermarkHeight, int watermarkWidth, double* pixelsArray, double* watermarkArray, int message_num)
{

	int i, j;

	double* shifted_mark = new double[watermarkHeight*watermarkWidth];
	shiftIntoNewArray(watermarkArray, shifted_mark, watermarkHeight, watermarkWidth, message_num);

	Mat mat = cv::Mat(pixelsHeight, pixelsWidth, cv::DataType<double>::type, pixelsArray);

	cv::dft(mat, mat, cv::DFT_REAL_OUTPUT, mat.rows);

	for (i = 0; i < watermarkHeight; i++)
		for (j = 0; j < watermarkWidth; j++)
			mat.at<double>(i + 1, j + 1) += shifted_mark[i*watermarkWidth + j];

	cv::dft(mat, mat, cv::DFT_INVERSE | cv::DFT_REAL_OUTPUT | cv::DFT_SCALE);

	for (i = 0; i < mat.rows; i++)
		for (j = 0; j < mat.cols; j++)
			pixelsArray[i*mat.cols + j] = mat.at<double>(i, j);

	delete[] shifted_mark; 

	return 1;

}


