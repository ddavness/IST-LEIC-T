/*
 * File: manager.c
 * Description: Implements utilities for contact management.
 * Author: David Ferreira de Sousa Duque, 93698
 *
 * Timestamp: 4th May, 23:46
*/

#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdio.h>
#include "manager.h"

/*
   Adds a new contact to the system that is in place. It sets up the
   email and adds everything into it's place. Returns TRUE if the operation
   is successful, FALSE otherwise (the contact with the given name exists
   already).
*/
bool addContact(Contact* contact, char* mail_name, char* mail_domain) {
    if (findInHashTable(CONTACT_HASHMAP, contact -> name)) {
        return FALSE;
    } else {
        Mail* m; ListNode* domain_node;
        m = newGlobal(Mail);

        addToHashTable(CONTACT_HASHMAP, contact -> name, appendToList(CONTACT_LIST, contact));
        domain_node = findInHashTable(DOMAIN_HASHMAP, mail_domain);

        if (domain_node) {
            int* count = domain_node -> content;
            (*count)++;
        } else {
            int* count = newGlobal(int); *count = 1;
            domain_node = addToHashTable(DOMAIN_HASHMAP, copyString(mail_domain), count);
        }

        m -> domain = domain_node;
        m -> name = copyString(mail_name);

        contact -> mail = m;
    }

    return TRUE;
}

/*
   Runs through the contact list linearly and prints every contact
   inside each node. This way we guarantee that the contacts are in
   the order that was requested.
*/
void listAllContacts() {
    ListNode* current; RootNode* list;
    list = CONTACT_LIST;
    current = list -> first;
    while (current) {
        Contact* c; Mail* m;
        c = current -> content;
        m = c -> mail;
        printf("%s %s@%s %s\n", c -> name, m -> name, m -> domain -> key, c -> phone);

        current = current -> _next;
    }
}

/*
   Searches for a contact in particular via the hashtable.
   Returns NULL if the name given does not exist.
*/
Contact* searchContact(char* name) {
    ListNode* node = findInHashTable(CONTACT_HASHMAP, name);
    if (node) {
        ListNode* contact = node -> content;
        return contact -> content;
    }

    return NULL;
}

/*
   Searches for a contact in particular via the hashtable.
   If it exists, it is deleted. The result of the operation
   (successful or not) is then returned via a boolean.
*/
bool eraseContact(char* name) {
    ListNode* hash_node = findInHashTable(CONTACT_HASHMAP, name);
    if (hash_node) {
        ListNode* list_node; Contact* c; Mail* m; int* d_count;
        list_node = hash_node -> content;
        c = list_node -> content;
        m = c -> mail;
        d_count = m -> domain -> content; (*d_count)--;

        /* Free them all in reverse order */
        removeFromHashTable(CONTACT_HASHMAP, hash_node);
        removeFromList(CONTACT_LIST, list_node);

        free(m -> name);
        free(c -> phone);
        free(c -> name);
        free(m); free(c);
        
        return TRUE;
    }

    return FALSE;
}

/*
   Changes the e-mail address of a given contact.
   As with other operations, fails if such contact does not exist.
*/
bool changeMailAddress(char* name, char* new_name, char* new_domain) {
    ListNode* contact_node = findInHashTable(CONTACT_HASHMAP, name);
    if (contact_node) {
        ListNode* list_node; Contact* c; Mail* m;

        list_node = contact_node -> content;
        c = list_node -> content;
        m = c -> mail;
        if (strcmp(new_domain, m -> domain -> key)) { /* Domains are different. Oh noes! */
            ListNode* domain_node; int* d_count;
            d_count = m -> domain -> content;

            (*d_count)--;

            domain_node = findInHashTable(DOMAIN_HASHMAP, new_domain);
            if (domain_node) {
                d_count = domain_node -> content;
                (*d_count)++;
            } else {
                d_count = newGlobal(int); *d_count = 1;
                domain_node = addToHashTable(DOMAIN_HASHMAP, copyString(new_domain), d_count);
            }

            m -> domain = domain_node;
            free(m -> name);
            m -> name = copyString(new_name);
        } else {
            /* Just change the name */
            free(m -> name);
            m -> name = copyString(new_name);
        }
        return TRUE;
    }

    return FALSE;
}

/*
   Looks up how many e-mails belong to a particular domain.
   This is done via keeping track on a counter.
*/
int getMailDomainCount(char* domain) {
    ListNode* domain_node = findInHashTable(DOMAIN_HASHMAP, domain);
    if (domain_node) {
        int* domain_count = domain_node -> content;
        return (*domain_count);
    }

    return 0;
}
