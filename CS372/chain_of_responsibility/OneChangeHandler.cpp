/*
	OneChangeHandler.cpp
	Frank Cline

	OneChangeHandler concrete class for MoneyChangeHandler
*/

#include "OneChangeHandler.h"
using std::shared_ptr;
using std::string;
using std::to_string;

OneChangeHandler::OneChangeHandler(): MoneyChangeHandler(1,"$1")
{}