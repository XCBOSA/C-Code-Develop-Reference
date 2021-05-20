void  exit(int exitCode);
void  *malloc(size_t size);
void  *calloc(int numOfArray, size_t arrayElemSize);
void  *realloc(void *oldBuffer, int newBufferSize);
void  *free(void *memory);
char *itoa(int number, char *toString, int base);
int atoi(char *fromString);
float atof(char *fromString);
long atol(char *fromString);
long atoll(char *fromString);

int RAND_MAX;
int rand();
void srand(unsigned int);
int system(char *command);
