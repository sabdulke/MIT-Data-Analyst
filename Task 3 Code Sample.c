// Various implementations of sorting algorithms.
#include "sorters.h"
#include <string.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

void swap(char ** elem1, char ** elem2) {
	char * temp = *elem1;
	*elem1 = *elem2;
	*elem2 = temp;
}
//QUICKSORT IMPLEMENTATION
int partition (char ** args, int start, int end) {
	char * piv = args[end];									//Pivot initialized to end of array
	int swapp = start-1;									//index to be swapped initialized to start-1 (will be incremented before implemented)
	for (int i = start; i < end; i++) {						//i initialized to start num; iterate indices
		if (strcmp(args[i],piv) <= 0) {						//If ASCII rep of args[i] is less than pivot
			swapp += 1;										//Increment swapp
			swap (&args[i], &args[swapp]);					//Utilize helper function to swap both elements 
		}
	}
	swap (&args[swapp + 1], &args[end]);					//Swap pivot with increment swapp
	return (swapp + 1);
	}

void quicksort3Param (char ** args, int start, int end ) {		//recursive quicksort function
	if (start < end) {											//If the end (pivot i) greater than the beginning of (partioned) array
		int newPos = partition(args, start, end);				//Call partition
		quicksort3Param(args, start, (newPos-1));				//Recurse with new pivot
		quicksort3Param(args, (newPos+1), end);					//Recurse with new start
	}
}

	
void quicksort(int argc, char ** args) {				//quicksort function with 2 arguments
	int start = 0;										//initialize start variable with 1 (beginning index of array to be sorted)
	int end = argc-1;									//initialize end with last index of array 
	quicksort3Param (args, start, end);					//Call recursive quicksort func with 3 parameters
	
}



void bubble_sort(int argc, char ** args) {
	for (int i = 0; i < argc; i++) {
	for (int j = 0; j < argc - i - 1; j++) {
	if (strcmp(args[j], args[j + 1]) > 0) {
	swap(&args[j], &args[j + 1]);
			}
		}
	}
}
	
void bogo_sort(int argc, char ** args) {
	int num_swaps = 10;
	int seed = 2;
	srand(seed);
	// Idea: randomly shuffle. If the list is sorted, return. If not, try again.
	bool is_sorted = false;
	while (!is_sorted) {
	// Shuffle the list.
		for (int i = 0; i < num_swaps; i++) {
			int index1 = rand() % argc;
			int index2 = rand() % argc;
			swap(&args[index1], &args[index2]);
		}
	// Update is_sorted depending on list.
	is_sorted = true;
	for (int i = 0; i < argc - 1; i++) {
		if (strcmp(args[i], args[i + 1]) > 0) {
			is_sorted = false; break;
			}
		}
	}
}