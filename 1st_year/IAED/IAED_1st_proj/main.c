/*
 * File: main.c
 * Author: David Ferreira de Sousa Duque (93698) @ IST-UL
 * Description: IAED project, 2018/19. Recreates an event scheduling system.
 * 
 * 2019
*/

/*
    **************************************
    HEADER IMPORT AND CONSTANT DEFINITIONS
    **************************************
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "timeStamp.h"

#define MIN(a,b) (((a)>(b))?(b):(a))

#define ROOMS 10
#define EVENTS 101
#define STR_CAP 64
#define MAX_PART 3
#define LONGEST_ARG_COUNT 9

#define TRUE 1
#define FALSE 0
typedef unsigned char bool;

/* Define data structures and other constants */
typedef struct{
	char topic[STR_CAP];
	TimeStamp timeStampPeriod[2];
    int period;
	int room;
	char host[STR_CAP];
	char participants[MAX_PART][STR_CAP];
} Event;
typedef struct{
    int array;
    int room;
    int matrix;
} EventSystemPosition;
const char ARG_SPLIT[2] = ":";
const char EMPTY_STRING[1] = "";

/*
    *******************
    VARIABLE DEFINITION
    *******************
*/
char arguments[1024];
char command;
char argumentList[LONGEST_ARG_COUNT][STR_CAP];
char *token;

int matrix_count[ROOMS];
int array_count;
int local_overlap_count;
Event schedule_matrix[ROOMS][EVENTS];
Event schedule_array[ROOMS * EVENTS];
Event *local_overlap_array[ROOMS * EVENTS];

/* Copies whatever is in the current stdin line onto the 'arguments' string, and clears the argument list. */
void flushIO(){
    char c;
    int i = 0;
    while ((c = getchar()) != '\n' && c != EOF){
        arguments[i] = c;
        i++;
    }
    arguments[i] = '\0';
    for (i = 0; i < LONGEST_ARG_COUNT; i++){
        strcpy(argumentList[i], "");
    }
}

/* COMMAND OPERATOR PROTOTYPES */
void listAllEvents();
void a(char[LONGEST_ARG_COUNT][STR_CAP]);
void s(char[LONGEST_ARG_COUNT][STR_CAP]);
void r(char[LONGEST_ARG_COUNT][STR_CAP]);
void i(char[LONGEST_ARG_COUNT][STR_CAP]);
void t(char[LONGEST_ARG_COUNT][STR_CAP]);
void m(char[LONGEST_ARG_COUNT][STR_CAP]);
void A(char[LONGEST_ARG_COUNT][STR_CAP]);
void R(char[LONGEST_ARG_COUNT][STR_CAP]);

char cmd_list[9] = "asritmAR";
void (*cmd[8]) (char[LONGEST_ARG_COUNT][STR_CAP]) = {a, s, r, i, t, m, A, R};

/*
    *****************
    MAIN PROGRAM BODY
    *****************
*/
int main(){
    /* Initialize the values */
    int rms;
    int evs;
    array_count = 0;
    local_overlap_count = 0;
    for (rms = 0; rms < ROOMS; rms++){
        matrix_count[rms] = 0;
        for (evs = 0; evs < EVENTS; evs++){
            schedule_matrix[rms][evs].room = 0;
            schedule_array[rms * EVENTS + evs].room = 0;
            local_overlap_array[rms * EVENTS + evs] = NULL;
        }
    }

    do {
        command = getchar();
        if (command == 'l'){
            /* The commands x and l do not take arguments, so no need to scan for them, hence why they're treated specially :^) */
            getchar(); /* eat the newline (\n) char */
            listAllEvents();
        } else if (command != 'x') {
            int i; i = 0;
            getchar(); flushIO();

            /* Split the arguments if needed */

            for (token = strtok(arguments, ARG_SPLIT); token != NULL; token = strtok(NULL, ARG_SPLIT)){
                strcpy(argumentList[i], token);
                i++;
            }

            for (i = 0; i < 8; i++){
                if (command == cmd_list[i]) {
                    (*cmd[i]) (argumentList);
                    break;
                }
            }
        }
    } while (command != 'x'); 
    
    return 0;
}

/*
    **************************
    AUXILIARY COMMON FUNCTIONS
    **************************
*/

/* Regenerates the local_overlap_array for the provided event. */
void regenOverlapArray(Event ev){
    int i, j;
    TimePeriodRelation tpr;
    j = 0;
    for (i = 0; i < ROOMS*EVENTS; i++){
        tpr = relation(schedule_array[i].timeStampPeriod, ev.timeStampPeriod);
        if (tpr == OVERLAP && strcmp(ev.topic, schedule_array[i].topic)){
            local_overlap_array[j] = &(schedule_array[i]);
            j++;
        } else if(tpr == AFTER){
            break;
        }
    }
    local_overlap_count = j;
}

/* Determines whether a participant is busy in a given time period. Uses the local_overlap_array generated as a base. */
bool participantBusy(char participant[STR_CAP]){
    int i;
    for (i = 0; i < local_overlap_count; i++){
        Event x = *(local_overlap_array[i]);
        if((!strcmp(x.host, participant) || !strcmp(x.participants[0], participant) || !strcmp(x.participants[1], participant) || !strcmp(x.participants[2], participant)))
            return TRUE;
    }

    return FALSE;
}

/* Checks whether any of the participants is busy during the event proposed schedule. Relies on the participantBusy() function. */
/* updateOverlapList IS ONLY FOR PERFORMNCE PURPOSES: ONLY SET TO FALSE WHEN YOU'RE SURE YOUR OVERLAP LIST DOES NOT CHANGE! IN DOUBT, KEEP THIS AS TRUE! */
bool participantsBusy(Event ev, bool complain, bool regenOverlapList){
    int i;
    bool result = FALSE;

    /* Generates an array that contains all the events that would overlap with ev, regardless of room. It is of no use to check 4 times events that don't even overlap */
    if (regenOverlapList) {
        regenOverlapArray(ev);
    }

    if (complain) {
        if (participantBusy(ev.host)){
            printf("Impossivel agendar evento %s. Participante %s tem um evento sobreposto.\n", ev.topic, ev.host);
            result = TRUE;
        }
        for (i = 0; i < MAX_PART; i++){
            if (strcmp(ev.participants[i], "") && participantBusy(ev.participants[i])){
                printf("Impossivel agendar evento %s. Participante %s tem um evento sobreposto.\n", ev.topic, ev.participants[i]);
                result = TRUE;
            }
        }
    } else {
        if (participantBusy(ev.host)){
            return TRUE;
        }
        for (i = 0; i < MAX_PART; i++){
            if (strcmp(ev.participants[i], "") && participantBusy(ev.participants[i])){
                return TRUE;
            }
        }
    }

    return result;
}

/* Prints an event to the stdout according to the requested format. */
void printEvent(Event *ev_ptr){
    int i;
    Event e = *ev_ptr;
    printf("%s ", e.topic);
    printTimeStamp(e.timeStampPeriod[0]);
    printf(" %d Sala%d %s\n*", e.period, e.room, e.host);
    for (i = 0; i < MAX_PART && strcmp(e.participants[i], ""); i++){
        printf(" %s", e.participants[i]);
    }

    printf("\n");
}

/* Auxiliary function for addEvent(); Inserts the event into the global schedule_array. */
void addEventToArray(Event event){
    if (array_count == 0){
        schedule_array[0] = event;
        array_count++;
        return;
    } else {
        int i;
        for (i = 0; i < (array_count + 1); i++){
            Event this = schedule_array[i];

            TimeStampRelation rel = getEarlier(this.timeStampPeriod[0], event.timeStampPeriod[0]);
            if (rel == T2_BEFORE || (rel == TST_EQUAL && event.room < this.room)){ 
                /* We can place it here but we need to move all those after away */
                int n;
                for (n = array_count; n > i; n--){
                    schedule_array[n] = schedule_array[n - 1];
                }
                array_count ++;
                schedule_array[i] = event;
                return;
            }
        }
        schedule_array[array_count] = event;
        array_count ++;
    }
}

/*
    **********************************
    MAIN PROGRAM FUNCTION DECLARATIONS
    **********************************
*/

/* Attempts to find a scheduled event, and returns a struct containing information on how to reach it. */
EventSystemPosition findEvent(char topic[STR_CAP], bool complain){
    int i;
    int n;
    EventSystemPosition ptr;
    for(i = 0; (i < ROOMS * EVENTS) && (schedule_array[i].room); i++){
        if(!strcmp(schedule_array[i].topic, topic)){
            int r = schedule_array[i].room - 1;
            ptr.room = r;
            ptr.array = i;
            for (n = 0; (n < EVENTS) && (schedule_matrix[r][n].room); n++){
                if(!strcmp(schedule_matrix[r][n].topic, topic)){
                    ptr.matrix = n;
                    return ptr;
                }
            }
        }
    }

    if (complain){
        printf("Evento %s inexistente.\n", topic);
    }
    ptr.room = -1; /* Signal that such event does not exist */
    return ptr;
}

/* (a) Attempts to add the given event; */
/* regenOverlapArray might be set to FALSE to squeeze more performance, but can cause the program to malfunction if not used properly. In doubt, set it as TRUE. */
bool addEvent(Event *ev_ptr, bool complain, bool regenOverlapArray){
    int i, r, mc;
    int *c;
    Event ev;
    Event (*room)[];
    ev = *ev_ptr;
    r = ev.room - 1;
    room = &(schedule_matrix[r]);
    c = &(matrix_count[r]); mc = *c;

    if (!mc){
        if (participantsBusy(ev, complain, regenOverlapArray)){
            return FALSE;
        }
        (*room)[0] = ev;
        (*c) = 1;
        addEventToArray(ev);
        return TRUE;
    }

    for (i = 0; i < (*c + 1); i++){
        TimePeriodRelation tpr = relation((*room)[i].timeStampPeriod, ev.timeStampPeriod);
        if (((*room)[i]).room == 0){
            /* An empty space on the room was found */
            if (participantsBusy(ev, complain, regenOverlapArray)){
                return FALSE;
            }
            (*room)[i] = ev;
            (*c)++;
            addEventToArray(ev);
            return TRUE;
        } else if (tpr == AFTER) {
            /* We can place the event here but we have to shift all other events forward... */
            int j;
            if (participantsBusy(ev, complain, regenOverlapArray)){
                return FALSE;
            }
            for (j = (*c); j > i; j--){
                (*room)[j] = (*room)[j - 1];
            }
            (*room)[i] = ev;
            (*c)++;
            addEventToArray(ev);
            return TRUE;
        } else if (tpr == OVERLAP) {
            /* Overlap in schedule. Impossible to continue! */
            if (complain){
                printf("Impossivel agendar evento %s. Sala%d ocupada.\n", ev.topic, ev.room);
            }
            return FALSE;
        }
    }

    return FALSE;
}

/* (s) Loops through the schedule_matrix[room] and prints every event inside it. */
void listRoomEvents(int n){
    int i;
    Event (*room)[];
    room = &(schedule_matrix[n - 1]);

    for (i = 0; (*room)[i].room; i++){
        printEvent(&((*room)[i]));
    }
}

/* (l) Loops trough the schedule_array and prints each event inside it. */
void listAllEvents(){
    int i;

    for (i = 0; schedule_array[i].room; i++){
        printEvent(&(schedule_array[i]));
    }
}

/* (r) Removes the event that the respective EventSystemPosition points to. */
void removeEvent(EventSystemPosition ev_ptr){
    int i;
    int r;
    r = ev_ptr.room;
    /* Drag all other events back */

    for (i = ev_ptr.array; i < MIN(array_count, (ROOMS * EVENTS) - 1); i++){
        schedule_array[i] = schedule_array[i + 1];
    }
    for (i = ev_ptr.matrix; i < MIN(matrix_count[r], EVENTS - 1); i++){
        schedule_matrix[r][i] = schedule_matrix[r][i + 1];
    }

    /* Surely invalidates the last element left, avoids edge cases to occur */
    array_count--;
    schedule_array[array_count].room = 0;
    matrix_count[r]--;
    schedule_matrix[r][matrix_count[r]].room = 0;
}

/* (i, t) Attempts to change the start and/or end of the event with the given topic. */
void changeEventTimeStamp(EventSystemPosition ev_ptr, TimeStamp period[2], int declaredPeriod){
    Event old;
    Event new;
    old = schedule_array[ev_ptr.array];
    new = old;
    new.period = declaredPeriod;
    new.timeStampPeriod[0] = period[0];
    new.timeStampPeriod[1] = period[1];

    removeEvent(ev_ptr);
    if (!addEvent(&new, TRUE, TRUE)){
        addEvent(&old, TRUE, TRUE);
    }
}

/* (m) Attempts to change the room of an event with the given topic. */
void changeEventRoom(char topic[STR_CAP], int newRoom){
    Event old, new;
    EventSystemPosition ev = findEvent(topic, TRUE);
    if (ev.room == -1){
        return;
    }

    old = schedule_array[ev.array];
    new = old;
    new.room = newRoom;

    removeEvent(ev);
    if (!addEvent(&new, TRUE, TRUE)){
        addEvent(&old, TRUE, FALSE);
    }
}

/* (A) Attempts to find and add a participant to the given event name. */
void addParticipant(char topic[STR_CAP], char newParticipant[STR_CAP]){
    int i;
    Event e;

    EventSystemPosition ev = findEvent(topic, TRUE);
    if (ev.room == -1){
        return;
    }

    e = schedule_array[ev.array];
    
    for (i = 0; i < MAX_PART; i++){
        if (!strcmp(e.participants[i], "")){
            regenOverlapArray(e);
            if (participantBusy(newParticipant)){
                printf("Impossivel adicionar participante. Participante %s tem um evento sobreposto.\n", newParticipant);
                return;
            } else {
                /* Add the participant name to the event */

                strcpy(schedule_array[ev.array].participants[i], newParticipant);
                strcpy(schedule_matrix[ev.room][ev.matrix].participants[i], newParticipant);
            }
            return;
        } else if (!strcmp(e.participants[i], newParticipant)){
            return;
        }
    }

    printf("Impossivel adicionar participante. Evento %s ja tem 3 participantes.\n", topic);
}

/* Attempts to find and remove a participant from the given event name. */
void removeParticipant(char topic[STR_CAP], char participant[STR_CAP]){
    int i, j;
    bool removed;
    Event e;

    EventSystemPosition ev = findEvent(topic, TRUE);
    if (ev.room == -1){
        return;
    }

    removed = FALSE;
    e = schedule_array[ev.array];
    
    for (i = 0; i < MAX_PART; i++){
        if (!strcmp(e.participants[i], participant)){
            removed = TRUE;
            for (j = i; j < MAX_PART - 1; j++){
                strcpy(e.participants[j], e.participants[j + 1]);
            }
            strcpy(e.participants[j], "");
            break;
        }
    }

    /* Rearrange the participant list */
    if (removed){
        if (!strcmp(e.participants[0], "")){
            printf("Impossivel remover participante. Participante %s e o unico participante no evento %s.\n", participant, topic);
            return;
        } else {
            for (i = 0; i < MAX_PART; i++){
                strcpy(schedule_array[ev.array].participants[i], e.participants[i]);
                strcpy(schedule_matrix[ev.room][ev.matrix].participants[i], e.participants[i]);
            }
        }
    }
}

/*
    *********************************************************************************************************
    FRONT-END MAIN() OPERATORS; EACH FUNCTION EXECUTES THE COMMAND OF THEIR NAME (a() executes the a command)
    *********************************************************************************************************
*/

void a(char argumentList[LONGEST_ARG_COUNT][STR_CAP]){
    /* Treat the arguments */
    Event e;
    int i, p;
    strcpy(e.topic, argumentList[0]);
    e.period = atoi(argumentList[3]);
    e.timeStampPeriod[0] = newTimeStamp(argumentList[1], argumentList[2]);
    e.timeStampPeriod[1] = minutesAfter(e.timeStampPeriod[0], e.period);
    e.room = atoi(argumentList[4]);
    strcpy(e.host, argumentList[5]);
    for (p = 0; p < MAX_PART; p++){
        strcpy(e.participants[p], "");
    }
    p = 0;
    for (i = 6; strcmp(argumentList[i], "") && i < LONGEST_ARG_COUNT; i++){
        strcpy(e.participants[p], argumentList[i]);
        p++;
    }

    addEvent(&e, TRUE, TRUE);
}

void s(char argumentList[LONGEST_ARG_COUNT][STR_CAP]){
    listRoomEvents(atoi(argumentList[0]));
}

void r(char argumentList[LONGEST_ARG_COUNT][STR_CAP]){
    EventSystemPosition esp = findEvent(argumentList[0], TRUE);
    if (esp.room != -1){
        removeEvent(esp);
    }
}

void i(char argumentList[LONGEST_ARG_COUNT][STR_CAP]){
    EventSystemPosition esp = findEvent(argumentList[0], TRUE);
    if (esp.room != -1){
        TimeStamp newPeriod[2];
        Event e = schedule_array[esp.array];
        newPeriod[0] = newTimeStamp(getStandardDate(e.timeStampPeriod[0]), argumentList[1]);
        newPeriod[1] = minutesAfter(newPeriod[0], e.period);
        changeEventTimeStamp(esp, newPeriod, e.period);
    }
}

void t(char argumentList[LONGEST_ARG_COUNT][STR_CAP]){
    EventSystemPosition esp = findEvent(argumentList[0], TRUE);
    if (esp.room != -1){
        TimeStamp newPeriod[2];
        Event e = schedule_array[esp.array];
        newPeriod[0] = e.timeStampPeriod[0];
        newPeriod[1] = minutesAfter(newPeriod[0], atoi(argumentList[1]));
        changeEventTimeStamp(esp, newPeriod, atoi(argumentList[1]));
    }
}

void m(char argumentList[LONGEST_ARG_COUNT][STR_CAP]){
    changeEventRoom(argumentList[0], atoi(argumentList[1]));
}

void A(char argumentList[LONGEST_ARG_COUNT][STR_CAP]){
    addParticipant(argumentList[0], argumentList[1]);
}

void R(char argumentList[LONGEST_ARG_COUNT][STR_CAP]){
    removeParticipant(argumentList[0], argumentList[1]);
}