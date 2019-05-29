/*
 * File: memutils.h
 * Description: Describes utilities for data structure manipulation
 * Author: David Ferreira de Sousa Duque, 93698
 *
 * Timestamp: 3rd May, 17:41
*/

#ifndef MEMUTILS
#define MEMUTILS

#define FALSE 0
#define TRUE 1

#define INDEX_INTERVAL 64
#define HASHTAB_SIZE 5903
#define PRIME_A 78977
#define PRIME_B 47639

#define newDynamicArray(TYPE, SIZE) (createDynamicArray(sizeof(TYPE), SIZE))
#define newGlobal(TYPE) malloc(sizeof(TYPE))
#define pwr(X, Y) (int)pow((double)(X), (double)(Y))

typedef int bool;
typedef struct lnode ListNode;
typedef struct {
	ListNode* first;
	ListNode* last;
} RootNode;

struct lnode {
	ListNode* _next;
	ListNode* _prev;
	char* key;
	void* content;
};

/* Miscellaneous function prototyped */
char* copyString(char*);

/* Double-Linked list abstraction function prototypes */
RootNode* createLinkedList();
ListNode* findInList(RootNode*, char*);
ListNode* appendToList(RootNode*, void*);
void removeFromList(RootNode*, ListNode*);
void destroyLinkedList(RootNode*, void(void*));

/* Hashing prototypes */
int hashKey(char*);

/* Hashtable abstraction function prototypes */
RootNode** createHashTable();
ListNode* findInHashTable(RootNode**, char*);
ListNode* addToHashTable(RootNode**, char*, void*);
void removeFromHashTable(RootNode**, ListNode*);
void destroyHashTable(RootNode**, void(void*));

#endif