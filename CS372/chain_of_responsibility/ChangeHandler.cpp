/*
	main.cpp
	Frank Cline

	Chain of Responsibility Demo
*/

#define CATCH_CONFIG_MAIN 

#include "ChangeHandler.h"
using std::shared_ptr;

void ChangeHandler::setNext(shared_ptr<ChangeHandler> next)
{
	next_ = next;
}