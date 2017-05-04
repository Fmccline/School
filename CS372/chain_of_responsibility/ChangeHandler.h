// ChangeHandler.h
// Frank Cline
// header file for ChangeHandler class

#ifndef CHANGE_HANDLER_H_INCLUDED
#define CHANGE_HANDLER_H_INCLUDED

#include <memory>
#include <string>

class ChangeHandler
{
public:
	virtual ~ChangeHandler() = default;
	ChangeHandler() = default;
	void setNext(std::shared_ptr<ChangeHandler> next);
	virtual std::string handleChange(int change) = 0;
protected:
	std::shared_ptr<ChangeHandler> next_;
};

#endif // CHANGE_HANDLER_H_INCLUDED