/*
	OneHundredChangeHandler.cpp
	Frank Cline

	OneHundredChangeHandler concrete class for MoneyChangeHandler
*/

#include "OneHundredChangeHandler.h"
using std::shared_ptr;
using std::string;
using std::to_string;

OneHundredChangeHandler::OneHundredChangeHandler(): MoneyChangeHandler(100,"$100")
{}