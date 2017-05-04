/*
	TenChangeHandler.cpp
	Frank Cline

	TenChangeHandler concrete class for MoneyChangeHandler
*/

#include "TenChangeHandler.h"
using std::shared_ptr;
using std::string;
using std::to_string;

TenChangeHandler::TenChangeHandler(): MoneyChangeHandler(10,"$10")
{}