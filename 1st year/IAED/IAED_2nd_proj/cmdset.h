/*
 * File: cmdset.h
 * Description: Describes front-end command interface functions.
 * Author: David Ferreira de Sousa Duque, student n.o. 93698
 * 
 * Timestamp: 8th May, 23:38
*/

#include "manager.h" /* Imports "memutils.h" as a dependency */

#ifndef CMDSET
#define CMDSET

#define STDIN_BUFFER 2048
#define NAME_BUFFER 1024
#define MAIL_BUFFER 512
#define PHONE_BUFFER 64

char stdin_buffer[STDIN_BUFFER];
char tok_name[NAME_BUFFER];
char tok_mail[MAIL_BUFFER];
char tok_mail_name[MAIL_BUFFER];
char tok_mail_domain[MAIL_BUFFER];
char tok_phone[PHONE_BUFFER];

/* Helper functions */
void flushIO();
void splitArgs(char*, char*, char**);

/* Command functions */
void a();
void l();
void p();
void r();
void e();
void c();
void x();

#endif