int CLOCKS_PER_SEC;

struct tm {
    builtin binary code
};

typedef int time_t;
typedef int clock_t;
char   *asctime(struct tm *timeptr);
time_t  clock();
char   *ctime(time_t *timer);
double  difftime(time_t endTime, time_t fromTime);
struct tm *gmtime(time_t *timer);
struct tm *localtime(time_t *timer);
time_t mktime(struct tm *timePtr);
time_t   time(time_t *timer);
int   strftime(char *string, size_t maxSize, char *format, struct tm *timePtr);
char   *strptime(char *string, char *format, struct tm *timePtr);
struct tm *gmtime_r(time_t *timePtr, struct tm *result);
int   timegm(struct tm *timePtr);
