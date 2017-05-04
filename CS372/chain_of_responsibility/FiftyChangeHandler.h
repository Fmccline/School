// FiftyChangeHandler.h
// Frank Cline
// header file for FiftyChangeHandler class

#ifndef FIFTY_CHANGE_HANDLER_H_INCLUDED
#define FIFTY_CHANGE_HANDLER_H_INCLUDED

#include <memory>
#include <string>
#include "MoneyChangeHandler.h"

class FiftyChangeHandler : public MoneyChangeHandler
{
public:
	FiftyChangeHandler();
};

#endif // FIFTY_CHANGE_HANDLER_H_INCLUDED