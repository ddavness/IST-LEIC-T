/*
 * File: memutils.c
 * Description: Implements utilities for data structure manipulation
 * Author: David Ferreira de Sousa Duque, 93698
 *
 * Timestamp: 4th May, 11:50
*/

#include <math.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "memutils.h"

/************************
 * MISC IMPLEMENTATIONS *
 ************************/

/*
   Copies a string from a place to another. This is accomplished
   by allocating more memory so that the original source pointer
   (which in the context of this project, usually points to a
   buffer, which we want to avoid in our data structures) remains
   unaffected. Only the strictly needed memory is allocated.
*/
char* copyString(char* source) {
    char* new = malloc((strlen(source) + 1) * sizeof(char));
    strcpy(new, source);

    return new;
}

/**************************************
 * DOUBLE-LINKED LISTS IMPLEMENTATION *
 **************************************/

/*
   Creates a new, empty linked list (an empty root node).
   RootNodes are the heads of every linked list, pointing both
   to the first and last element of the list.
*/
RootNode* createLinkedList() {
    RootNode* root = newGlobal(RootNode);

    root -> first = NULL;
    root -> last = NULL;

    return root;
}

/*
   Performs a linear search on the list. Goes from the first to
   last nodes and returns the one that has the same key of the one
   passed. This search method is expensive, so it's only relevant
   on some other implementations, like open addressing in an hash
   table (which I used in this very project).
*/
ListNode* findInList(RootNode* start, char* key) {
    ListNode* current = start -> first;
    while (current) {
        if (!strcmp(current -> key, key)) {
            return current; 
        }

        current = current -> _next;
    }

    return NULL;
}

/*
   Appends a node to the end of the list, preserving the intent
   of keeping the order of the elements the same. It basically
   jumps to the last element of the list (we don't need to do a
   linear search here because the root node also has a pointer
   for the last element) and attaches the new node there.
*/
ListNode* appendToList(RootNode* list, void* content) {
    ListNode *new, *last;
    new = newGlobal(ListNode);
    last = list -> last;

    new -> key = NULL;
    new -> _prev = last;
    new -> _next = NULL;
    new -> content = content;

    if (last) {
        last -> _next = new;
    } else {
        list -> first = new;
        list -> last = new;
    }
    list -> last = new;

    return new;
}

/*
   Removes an element from the list. Since the node doesn't know
   which list it is part of (while I could technically append a
   pointer to the root node of the list, it would be expensive
   memory-wise), we also need to pass in the corresponding RootNode
   in case the first/last members are changed.
*/
void removeFromList(RootNode* start, ListNode* to_remove) {
    ListNode* prev;
    ListNode* next;

    prev = to_remove -> _prev;
    next = to_remove -> _next;

    if (prev) {
        prev -> _next = next;
    } else {
        start -> first = next;
    }
    if (next) {
        next -> _prev = prev;
    } else {
        start -> last = prev;
    }

    free(to_remove);
}

/*
   Destroys a list, freeing all nodes and respective contents. Since
   however that some contents might be more complex than simple primitive
   types (we mean pointers and pointer-based structs), that could end up
   in allocated memory being "lost" (as in "the program no longer can reach
   the pointer to it"), one can pass a pointer to a function that will handle
   the freeing of the contents of the nodes. If none is passed, then free() is
   used.
*/
void destroyLinkedList(RootNode* list, void (*free_function)(void*)) {
    ListNode* aux; ListNode* node;
    node = list -> first;
    while (node){
        if (node -> key) {
            free(node -> key);
        }
        if (free_function) {
            free_function(node -> content);
        } else {
            free(node -> content);
        }
        aux = node;
        node = node -> _next;
        free(aux);
    }

    free(list);
}

/****************************
 * LOOKUP HASHING ALGORITHM *
 ****************************/

/*
   Grabs a string and returns a position for the hashtable (usually
   called an hash). This algorithm in particular is based on the one
   given in IAED lectures ("Strings 2.0"), with some modifications where
   the individual character has bitwise rolling and/or negating depending
   on the position inside the string.
*/
int hashKey(char* key) {
    unsigned int h;
    unsigned char c, d;
    int i, roll, base;

    h = 0; base = PRIME_A;
    for (i = 0; *key; key++, i++) {
        base = (base * PRIME_B) % (HASHTAB_SIZE - 1);
        c = *key;
        d = c;
        roll = ((i % 7) + 1);
        if (roll%2) {
            c <<= roll;
            d >>= (8 - roll);
        } else {
            c >>= roll;
            d <<= (8 - roll);
        }

        c |= d;
        if (d % 2) {
            c = ~c;
        }

        h += base * (i + 1) * c;
        h %= PRIME_A;
    }
    return h % HASHTAB_SIZE;
}
/****************************
 * HASHTABLE IMPLEMENTATION *
 ****************************/

/*
   Creates an empty hashtable of length HASHTAB_SIZE (At this moment
   defined as 5903). It uses open addressing as hash collision resolution.
   Since it relies on the double-linked lists implementation for it's own
   implementation, this hashtable is an array of pointers to RootNodes
   which in their turn will eventually point to double-linked lists.
*/
RootNode** createHashTable() {
    RootNode** ptr;
    ptr = calloc(HASHTAB_SIZE, sizeof(RootNode*));

    return ptr;
}

/*
   Attempts to find the given key in the given hashtable, and returns the
   node which the content resides. This is due to the fact that for some
   implementations it's more convenient to have the node from which the
   content can be extracted rather than the content itself only (e.g.
   copying the key pointer).
*/
ListNode* findInHashTable(RootNode** hashtable, char* key) {
    RootNode* root = hashtable[hashKey(key)];
    if (root) {
        return findInList(root, key);
    }

    return NULL;
}

/*
   Adds content to the node with the associated key if one with such key doesn't
   exist already. For the same reason as the function above, the function
   returns the node in which the content passed now resides.
*/
ListNode* addToHashTable(RootNode** hashtable, char* key, void* content) {
    RootNode* root; ListNode* content_node;
    root = hashtable[hashKey(key)];
    if (!root) {
        root = createLinkedList();
        hashtable[hashKey(key)] = root;
    } else if (findInList(root, key)) {
        return NULL;
    }

    content_node = appendToList(root, content);
    content_node -> key = key;

    return content_node;
}

/*
   Removes an element from an hashtable. Since the project's implementation
   doesn't need to know the result of the operation, this function doesn't
   return any success value (e.g. a boolean carrying TRUE/FALSE).
*/
void removeFromHashTable(RootNode** hashtable, ListNode* node) {
    RootNode* root = hashtable[hashKey(node -> key)];
    removeFromList(root, node);
}

/*
   Destroys an hashtable by destroying every single initialized linked list
   (non-null) inside it. For the same reason of the linked-lists, you can pass
   a pointer to a function if you want to handle freeing the contents of the
   nodes differently.
*/
void destroyHashTable(RootNode** hashtable, void (*free_function)(void*)){
    int i; RootNode* root;
    for (i = 0; i < HASHTAB_SIZE; i++) {
        root = hashtable[i];
        if (root) {
            destroyLinkedList(root, free_function);
        }
    }

    free(hashtable);
}
