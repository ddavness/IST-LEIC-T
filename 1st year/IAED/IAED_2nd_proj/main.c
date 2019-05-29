/*
 * File: main.c
 * Description: 2nd IAED project (2019) - Contact manager.
 * Author: David Ferreira de Sousa Duque, student n.o. 93698
 * 
 * Timestamp: 4th May, 16:37
*/

#include <stdio.h>
#include <string.h>
#include "cmdset.h" /* "memutils.h" and "manager.h" are imported recursively as dependencies of "cmdset.h" */
#include "free.h"

char cmdlst[8] = "alprecx";
void (*cmdset[7])() = {a, l, p, r, e, c, x};

int main(){
    char cmd = '\0';
    stdin_buffer[0] = '\0';
    
    CONTACT_LIST = createLinkedList();
    CONTACT_HASHMAP = createHashTable();
    DOMAIN_HASHMAP = createHashTable();

    while (cmd != 'x'){
        int i; char* c;
        cmd = getchar();
        for (i = 0, c = cmdlst; *c; i++, c++) {
            if (*c == cmd) {
                flushIO();
                cmdset[i]();
                break;
            }
        }
    }
    
    destroyLinkedList(CONTACT_LIST, freeContact);
    destroyHashTable(CONTACT_HASHMAP, doNothing);
    destroyHashTable(DOMAIN_HASHMAP, NULL);
    return 0;
}