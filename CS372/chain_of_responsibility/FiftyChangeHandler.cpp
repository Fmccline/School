/*
	FiftyChangeHandler.cpp
	Frank Cline

	FiftyChangeHandler concrete class for MoneyChangeHandler
*/

#include "FiftyChangeHandler.h"
using std::shared_ptr;
using std::string;
using std::to_string;

FiftyChangeHandler::FiftyChangeHandler(): MoneyChangeHandler(50,"$50")
{}