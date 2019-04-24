/*
 * File: timeStamp.h
 * Author: David Ferreira de Sousa Duque (93698) @ IST-UL
 * Description: Holds utilities regarding to date/hour manipulation.
 * 
 * 2019
*/

/*
    ********************
    CONSTANT DEFINITIONS
    ********************
*/

#define DATE_CAP 9 /* We have to keep the null terminator in mind */
#define HOUR_CAP 5

#define BEFORE -1
#define AFTER 1
#define OVERLAP 0
#define T1_BEFORE 1
#define T2_BEFORE 2
#define TST_EQUAL 0
const char CALENDAR_DAYS[12] = {
	31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31,
};

typedef int TimeStampRelation;
typedef int TimePeriodRelation;
typedef struct {
	int year;
	int month;
	int day;
	int hours;
	int minutes;
} TimeStamp;

const TimeStamp EMPTY_INVALID_DATE = {0, 0, 0, 0, 0};
char STD_DATE[DATE_CAP];
char STD_HOUR[HOUR_CAP];

/*
    *******************
    FUNCTION DEFINITION
    *******************
*/ 

/* Creates a valid date timestamp from properly formatted strings (ddmmyyyy and hhmm respectively) */
TimeStamp newTimeStamp(char date[DATE_CAP], char hour[HOUR_CAP]){
	TimeStamp ts;
	ts.day = (date[0] - '0') * 10 + (date[1] - '0');
	ts.month = (date[2] - '0') * 10 + (date[3] - '0');
	ts.year = (date[4] - '0') * 1000 + (date[5] - '0') * 100 + (date[6] - '0') * 10 + (date[7] - '0');

	ts.hours = (hour[0] - '0') * 10 + (hour[1] - '0');
	ts.minutes = (hour[2] - '0') * 10 + (hour[3] - '0');

	/* Validate the timestamp */
	if(ts.minutes > 59 || ts.hours > 23 || ts.month < 1 || ts.month > 12 || (ts.month == 2 && ts.day > ((ts.year % 4 == 0) ? 29 : 28)) || (ts.month != 2 && ts.day > CALENDAR_DAYS[ts.month - 1])){
        return EMPTY_INVALID_DATE;
    }
    
	return ts;
}

/* Returns the date on the timestamp according to the requested format (ddmmyyyy) */
char* getStandardDate(TimeStamp t){
    sprintf(STD_DATE, "%02d%02d%04d", t.day, t.month, t.year);
    return STD_DATE;
}

/* Returns the hour on the timestamp according to the requested format (hhmm) */
char* getStandardHour(TimeStamp t){
    sprintf(STD_HOUR, "%02d%02d", t.hours, t.minutes);
    return STD_HOUR;
}

/* Prints the timeStamp to the stdout according to the requeste format (ddmmyyyy hhmm) */
void printTimeStamp(TimeStamp t){
    printf("%s %s", getStandardDate(t), getStandardHour(t));
}

/* Grabs and compares two timeStamps: returns 1 if t1 is earlier than t2, returns 2 if vice-versa, returns 0 if they're equal */
int getEarlier(TimeStamp t1, TimeStamp t2){
    int dif[5];
    int d;
    int df = 0;
    df = t1.year - t2.year; dif[0] = (df > 0) - (df < 0);
    df = t1.month - t2.month; dif[1] = (df > 0) - (df < 0);
    df = t1.day - t2.day; dif[2] = (df > 0) - (df < 0); 
    df = t1.hours - t2.hours; dif[3] = (df > 0) - (df < 0); 
    df = t1.minutes - t2.minutes; dif[4] = (df > 0) - (df < 0); 
    
    for(d = 0; d < 5; d++){
        switch(dif[d]){
            case -1:
                return T1_BEFORE;
                break;
            case 1:
                return T2_BEFORE;
                break;
        }
    }

    return TST_EQUAL; /* Both timestamps are equal */
}

/* Grabs two timestamp periods (a vector of two timestamps) and determines if they overlap */
TimePeriodRelation relation(TimeStamp t1[2], TimeStamp t2[2]){
    if (getEarlier(t1[1], t2[0]) != T2_BEFORE){
        return BEFORE;
    }
    if (getEarlier(t1[0], t2[1]) != T1_BEFORE){
        return AFTER;
    }
    return OVERLAP;
}

/* Returns a TimeStamp that is x minutes after the provided one */
TimeStamp minutesAfter(TimeStamp t, int mins){
    TimeStamp r = t;
    int m = r.minutes;
    int h;
    m = m + mins;
    h = m / 60;
    m = m % 60;
    r.minutes = m; r.hours += h;
    return r;
}