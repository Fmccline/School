/*
	FiveChangeHandler.cpp
	Frank Cline

	FiveChangeHandler concrete class for MoneyChangeHandler
*/

#include "FiveChangeHandler.h"
using std::shared_ptr;
using std::string;
using std::to_string;

FiveChangeHandler::FiveChangeHandler(): MoneyChangeHandler(5,"$5")
{}