/*
 * File: cmdset.c
 * Description: Implements front-end command interface functions.
 * Author: David Ferreira de Sousa Duque, student n.o. 93698
 * 
 * Timestamp: 8th May, 23:46
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cmdset.h"

char* std_split[3] = {tok_name, tok_mail, tok_phone};
char ARG_TOK[2] = " ";
char MAIL_TOK[2] = "@";
char* mail_tok_tuple[2] = {tok_mail_name, tok_mail_domain};

/********************
 * HELPER FUNCTIONS *
 ********************/

/*
   Flushes whatever is still in the stdin up to the next
   line break. The contents are stored in the stdin_buffer
   string array.
*/
void flushIO(){
    char c;
    int i = 0;
    while ((c = getchar()) != '\n' && c != EOF){
        stdin_buffer[i] = c;
        i++;
    }
    stdin_buffer[i] = '\0';
}

/*
   An easy way to split a string into multiple ones. The "destiny"
   argument is an array of arrays so that we can pass in a variable amount
   of outputs.
*/
void splitArgs(char* input, char* splitter, char** destiny) {
    char* token; int i = 0;
    for (token = strtok(input, splitter); token != NULL; token = strtok(NULL, splitter)){
        strcpy(destiny[i], token);
        i++;
    }
}

/*******************************
 * COMMAND FRONT-END OPERATORS *
 *******************************/

void a() {
    splitArgs(stdin_buffer, ARG_TOK, std_split);
    if (!searchContact(tok_name)) {
        Contact* new;
        new = newGlobal(Contact);

        splitArgs(tok_mail, MAIL_TOK, mail_tok_tuple);

        new -> name = copyString(tok_name);
        new -> phone = copyString(tok_phone);

        addContact(new, tok_mail_name, tok_mail_domain);
    } else {
        printf("Nome existente.\n");
    }
}

void l() {
    listAllContacts();
}

void p() {
    Contact* c;
    splitArgs(stdin_buffer, ARG_TOK, std_split);
    c = searchContact(tok_name);
    if (c) {
        printf("%s %s@%s %s\n", tok_name, c -> mail -> name, c -> mail -> domain -> key, c -> phone);
    } else {
        printf("Nome inexistente.\n");
    }
}

void r() {
    splitArgs(stdin_buffer, ARG_TOK, std_split);
    if (!eraseContact(tok_name)) {
        printf("Nome inexistente.\n");
    }
}

void e() {
    splitArgs(stdin_buffer, ARG_TOK, std_split);
    splitArgs(tok_mail, MAIL_TOK, mail_tok_tuple);

    if (!changeMailAddress(tok_name, tok_mail_name, tok_mail_domain)) {
        printf("Nome inexistente.\n");
    }
}

void c() {
    int j;
    char* d[1] = {tok_mail_domain};
    splitArgs(stdin_buffer, ARG_TOK, d);

    j = getMailDomainCount(tok_mail_domain);
    printf("%s:%d\n", tok_mail_domain, j);
}

void x() {}