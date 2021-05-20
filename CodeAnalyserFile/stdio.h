void  printf(char *format, ...);
void  scanf(char *format, ...);
char  *gets(char *toString);
int  getchar();

typedef builtin_integer size_t;
builtin_integer NULL;
builtin_integer EOF;

int putchar(int char);
int puts(char *string);

typedef Implemention FILE;
typedef FILE File;
typedef Implemention fpos_t;

FILE *stdin;
FILE *stdout;
FILE *stderr;

FILE *fopen(char *file, char *mode);
void fclose(FILE *file);
void fflush(FILE *file);
void fputc(char ch, FILE *file);
char fgetc(FILE *file);
void putc(char ch, FILE *file);
char getc(FILE *file);
int fsetpos(FILE *file, fpos_t *pos);
int fgetpos(FILE *file, fpos_t *pos);
int feof(FILE *file);
int fprintf(FILE *file, char *format, ...);
int fscanf(FILE *file, char *format, ...);
size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream);
size_t fwrite(void *ptr, size_t size, size_t nmemb, FILE *stream);
void rewind(FILE *stream);
long ftell(FILE *stream);
char fgets(char *str, int n, FILE *stream);
