/*
 * File: manager.h
 * Description: Describes utilities for contact management.
 * Author: David Ferreira de Sousa Duque, 93698
 *
 * Timestamp: 4th May, 23:08
*/

#include "memutils.h"
#ifndef MANAGER
#define MANAGER

typedef struct {
	char* name;
	ListNode* domain;
} Mail;

typedef struct {
	Mail* mail;
	char* name;
	char* phone;
} Contact;

RootNode* CONTACT_LIST;
RootNode** CONTACT_HASHMAP;
RootNode** DOMAIN_HASHMAP;

/* Management function prototypes */
bool addContact(Contact*, char*, char*);
void listAllContacts();
Contact* searchContact(char*);
bool eraseContact(char*);
bool changeMailAddress(char*, char*, char*);
int getMailDomainCount(char*);

#endif
