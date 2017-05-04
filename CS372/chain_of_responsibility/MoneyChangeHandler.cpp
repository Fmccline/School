/*
	MoneyChangeHandler.cpp
	Frank Cline

	cpp file for abstract class MoneyChangeHandler
*/

#include "MoneyChangeHandler.h"
using std::shared_ptr;
using std::string;
using std::to_string;

MoneyChangeHandler::MoneyChangeHandler(int value, const string & name): ChangeHandler()
{
	value_ = value;
	name_ = name;
}

string MoneyChangeHandler::handleChange(int change)
{
	if (change <= 0)
	{
		return "Change: $0";
	}

	int amount_of_change = change/value_;
	if (amount_of_change > 0)
	{
		string return_change = name_ + ": " + to_string(amount_of_change) + "\n";
		change -= amount_of_change*value_;
		return change ? return_change + next_->handleChange(change) : return_change;
	}
	else
	{
		return next_->handleChange(change);
	}
}