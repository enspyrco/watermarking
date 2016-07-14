
#include <vector>
#include <string>

void generateArray(int p, int k, double* array);
void generateArray2(int p, int k, double* array);
int insertMark(int pixelsHeight, int pixelsWidth, int watermarkHeight, int watermarkWidth, double* pixelsArray, double* watermarkArray);
int insertMark(int pixelsHeight, int pixelsWidth, int watermarkHeight, int watermarkWidth, double* pixelsArray, double* watermarkArray, int message_num); 
int extractMark(int pixelsHeight, int pixelsWidth, int watermarkHeight, int watermarkWidth, double* pixelsArray, double* extracted_mark);
int fastCorrelation(int height, int width, double *matrix1, double *matrix2, double* correlation_vals);
void shiftIntoNewArray(double* array, double* shifted_array, int array_height, int array_width, int message_num);
double peak2rms(double* array, int array_len); 
std::vector<int> getShifts(std::string ascii, int arraySize);
std::string getASCII(std::vector<int> shifts, int arraySize);