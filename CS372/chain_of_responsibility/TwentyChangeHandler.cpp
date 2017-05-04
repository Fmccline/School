/*
	TwentyChangeHandler.cpp
	Frank Cline

	TwentyChangeHandler concrete class for MoneyChangeHandler
*/

#include "TwentyChangeHandler.h"
using std::shared_ptr;
using std::string;
using std::to_string;

TwentyChangeHandler::TwentyChangeHandler(): MoneyChangeHandler(20,"$20")
{}