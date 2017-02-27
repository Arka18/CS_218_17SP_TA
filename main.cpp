// CS 218 - Provided C++ program
//	This program calls assembly language routines.

//  Note, must ensure g++ compiler is installed:
//	sudo apt-get install g++

// ***************************************************************************

#include <cstdlib>
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <string>
#include <iomanip>

using namespace std;

// ***************************************************************
//  Define program specific constants.

#define SUCCESS 0
#define NOSUCCESS 1
#define OVERMAX 2
#define INPUTOVERFLOW 3
#define ENDOFINPUT 4

// ***************************************************************
//  Prototypes for external functions.
//	The "C" specifies to use the standard C/C++ style
//	standard calling convention.

extern "C" int listEstMedian(unsigned int[], unsigned int);
extern "C" int rdTriNum(unsigned int *, char []);
extern "C" void selectionSort(unsigned int[], unsigned int);
extern "C" void listStats(unsigned int[], unsigned int, unsigned int,
		unsigned int *, unsigned int *, unsigned int *,
		unsigned int *, unsigned int *);
extern "C" long long betaValue(unsigned int[], unsigned int);


// ***************************************************************
//  Begin a basic C++ program (does not use any objects).

int main()
{

// --------------------------------------------------------------------
//  Declare variables and simple display header
//	Note, C++ unsigned int's are doublewords (32-bits).
//	Note, C++ unsigned long long's are quadwords (64-bits).

	string	bars;
	bars.append(50,'-');
	static const unsigned int	MAXLENGTH = 500;
	static const unsigned int	MINLENGTH = 3;

	unsigned int		i, status, newNumber;
	unsigned int		list[MAXLENGTH];
	unsigned int		len=0;
	unsigned int		estMed, min, max, med, ave, pctErr;
	unsigned long long	beta;
	char			prompt[] = "Enter Value (tridecimal): ";
	bool			endOfNumbers;

	cout << bars << endl;
	cout << "CS 218 - Assignment #9" << endl << endl;

// --------------------------------------------------------------------
//  Loop to read numbers from user.

	endOfNumbers = false;
	cout << "Enter values (return to end input)." << endl;

	while (!endOfNumbers && len<MAXLENGTH) {

		fflush(stdout);
		status = rdTriNum(&newNumber, prompt);

		switch (status) {
			case SUCCESS:
				list[len] = newNumber;
				len++;
				break;
			case NOSUCCESS:
				cout << "Error, invalid number. ";
				cout << "Please re-enter." << endl;
				break;
			case OVERMAX:
				cout << "Error, number above maximum value. ";
				cout << "Please re-enter." << endl;
				break;
			case INPUTOVERFLOW:
				cout << "Error, user input exceeded " <<
					"length, input ignored. ";
				cout << "Please re-enter." << endl;
				break;
			case ENDOFINPUT:
				if (len < MINLENGTH) {
					cout << "Error, not enough values.";
					cout << "Keep entering numbers." << endl;
				} else {
					endOfNumbers = true;
				}
				break;
			default:
				cout << "Error, invalid return status. ";
				cout << "Program terminated" << endl;
				exit(EXIT_FAILURE);
				break;
		}
	}

// --------------------------------------------------------------------
//  Ensure some numbers were read and, if so, display results.

	cout << bars << endl;
	cout << endl << "Program Results" << endl << endl;

	estMed = listEstMedian(list, len);
	selectionSort(list, len);
	listStats(list, len, estMed, &min, &med, &max, &ave, &pctErr);
	beta = betaValue(list, len);

	cout << "Sorted List: " << endl;
	for (i=0; i < len; i++) {
		cout << setw(6) << list[i] << "  ";
		if ( (i%7)==6 || i==(len-1) ) cout << endl;
	}
	cout << endl;

	cout << "      Length =  " << setw(15) << len << endl;
	cout << "  Est Median =  " << setw(15) << estMed << endl;
	cout << "     Minimum =  " << setw(15) << min << endl;
	cout << "      Median =  " << setw(15) << med << endl;
	cout << "     Maximum =  " << setw(15) << max << endl;
	cout << "     Average =  " << setw(15) << ave << endl;
	cout << "       Beta  =  " << setw(15) << beta << endl;
	cout << " Err Percent =  " << setw(15) << pctErr << endl;
	cout << endl;

// --------------------------------------------------------------------
//  All done...

	return 0;

}

