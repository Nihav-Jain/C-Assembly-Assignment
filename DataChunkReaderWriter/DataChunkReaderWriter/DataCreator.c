#include <stdio.h>
#include <time.h>
#include <stdlib.h>

#define OUTPUT_BIN_FILENAME "datachunk.dat"
#define OUTPUT_STATS_FILENAME "datastats.txt"
#define INPUT_DATA_NUM_RANGE_FILENAME "data_num_ranges.txt"

#define BYTEVAL_MIN 50
#define BYTEVAL_MAX 150

#define SHORTVAL_MIN 1000
#define SHORTVAL_MAX 2000

#define LONGVAL_MIN 3000
#define LONGVAL_MAX 5000

int main()
{
	int N;
	int i, j, k;

	printf("Enter the number of data sections to be generated = ");
	scanf_s("%d", &N);

	FILE* dataRangesFile = fopen(INPUT_DATA_NUM_RANGE_FILENAME, "r");
	
	int dataNumberRanges[6];
	for (int i = 0; i < 6; i += 2)
	{
		fscanf_s(dataRangesFile, "%d %d", &dataNumberRanges[i], &dataNumberRanges[i + 1]);
		dataNumberRanges[i]++;				// incrementing to bring value in closed range (>= instead of >)
		dataNumberRanges[i + 1]--;			// decrementing to being value in closed range (<= instead of <)
	}

	time_t t;
	srand((unsigned)time(&t));

	FILE* outputBinFile = fopen(OUTPUT_BIN_FILENAME, "wb");
	fwrite(&N, sizeof(int), 1, outputBinFile);

	FILE* outputStatsFile = fopen(OUTPUT_STATS_FILENAME, "w");
	fprintf(outputStatsFile, "User chose %d sections\n", N);

	int numData, sum;
	int dataSizeToWrite[] = { sizeof(char), sizeof(short int), sizeof(int) };
	int dataValueRange[] = { BYTEVAL_MIN+1, BYTEVAL_MAX-1, SHORTVAL_MIN+1, SHORTVAL_MAX-1, LONGVAL_MIN+1, LONGVAL_MAX-1 };
	char* sizes[] = { "bytes", "shorts", "longs" };

	for (i = 1; i <= N; i++)
	{
		fprintf(outputStatsFile, "Section %d:\n", i);
		for (j = 0; j < 3; j++)
		{
			numData = dataNumberRanges[2 * j] + rand() % (dataNumberRanges[2 * j + 1] - dataNumberRanges[2 * j]);
			fwrite(&numData, sizeof(int), 1, outputBinFile);
			sum = 0;
			for (k = 0; k < numData; k++)
			{
				int newData = dataValueRange[2 * j] + rand() % (dataValueRange[2 * j + 1] - dataValueRange[2 * j]);
				fwrite(&newData, dataSizeToWrite[j], 1, outputBinFile);
				//fprintf(outputStatsFile, "%d ", newData);
				sum += newData;
			}
			if (j == 0 && numData % 2 == 1)
			{
				char paddingByte = 0;
				fwrite(&paddingByte, sizeof(char), 1, outputBinFile);
			}
			fprintf(outputStatsFile, "%d %s, sum = %d, average value %0.2f\n", numData, sizes[j], sum, (sum + 0.0) / numData);
		}
		fprintf(outputStatsFile, "\n");
	}

	fclose(dataRangesFile);
	fclose(outputBinFile);

	return 0;

}