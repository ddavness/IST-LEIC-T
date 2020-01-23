/*
 * File: free.h
 * Description: Implements utilities to free memory components.
 * Author: David Ferreira de Sousa Duque, student n.o. 93698
 * 
 * Timestamp: 13th May, 02:15
*/

#include <stdlib.h>
#include "manager.h"

/*
   Frees parts of a contact. This is because the system
   shares pointers in order to keep memory usage to a
   minimum. The point is that we don't want to free pointers
   that are already free.
*/
void freeContact(void* ptr) {
    Contact* c; Mail* m;
    c = ptr; m = c -> mail;
    free(c -> phone);
    free(m -> name);
    free(c); free(m);
}

/* Self explanatory. Does nothing at all. */
void doNothing(__attribute__((unused)) void* _){}