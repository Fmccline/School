// FiveChangeHandler.h
// Frank Cline
// header file for FiveChangeHandler class

#ifndef FIVE_CHANGE_HANDLER_H_INCLUDED
#define FIVE_CHANGE_HANDLER_H_INCLUDED

#include <memory>
#include <string>
#include "MoneyChangeHandler.h"

class FiveChangeHandler : public MoneyChangeHandler
{
public:
	FiveChangeHandler();
};

#endif // FIVE_CHANGE_HANDLER_H_INCLUDED