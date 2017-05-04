// MoneyChangeHandler.h
// Frank Cline
// header file for MoneyChangeHandler class

#ifndef MONEY_CHANGE_HANDLER_H_INCLUDED
#define MONEY_CHANGE_HANDLER_H_INCLUDED

#include <memory>
#include <string>
#include "ChangeHandler.h"

class MoneyChangeHandler : public ChangeHandler
{
public:
	virtual ~MoneyChangeHandler() = default;
	MoneyChangeHandler(int value, const std::string & name);
	std::string handleChange(int change) override;
protected:
	int value_;
	std::string name_;
};

#endif // MONEY_CHANGE_HANDLER_H_INCLUDED