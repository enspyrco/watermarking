
int insertMark(int pixelsHeight, int pixelsWidth, int watermarkHeight, int watermarkWidth, double* pixelsArray, double* watermarkArray);
int insertMark(int pixelsHeight, int pixelsWidth, int watermarkHeight, int watermarkWidth, double* pixelsArray, double* watermarkArray, int message_num); 
int extractMark(int pixelsHeight, int pixelsWidth, int watermarkHeight, int watermarkWidth, double* pixelsArray, double* extracted_mark);
int fastCorrelation(int height, int width, double *matrix1, double *matrix2, double* correlation_vals);

