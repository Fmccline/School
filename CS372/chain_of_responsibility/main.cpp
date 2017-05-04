/*
	main.cpp
	Frank Cline

	Chain of Responsibility Demo
*/

#include <iostream>
using std::cout;
using std::endl;
#include <string>
using std::string;
#include <memory>
using std::shared_ptr;
using std::make_shared;
#include "ChangeHandler.h"
#include "OneHundredChangeHandler.h"
#include "FiftyChangeHandler.h"
#include "TwentyChangeHandler.h"
#include "TenChangeHandler.h"
#include "FiveChangeHandler.h"
#include "OneChangeHandler.h"

int main()
{
	auto one_dollar = make_shared<OneChangeHandler>();
	auto five_dollars = make_shared<FiveChangeHandler>();
	auto ten_dollars = make_shared<TenChangeHandler>();
	auto twenty_dollars = make_shared<TwentyChangeHandler>();
	auto fifty_dollars = make_shared<FiftyChangeHandler>();
	auto one_hundred_dollars = make_shared<OneHundredChangeHandler>();

	one_dollar->setNext(one_dollar);
	five_dollars->setNext(one_dollar);
	ten_dollars->setNext(five_dollars);
	twenty_dollars->setNext(ten_dollars);
	fifty_dollars->setNext(twenty_dollars);
	one_hundred_dollars->setNext(fifty_dollars);

	auto chain_of_responsibility = one_hundred_dollars;

	cout << chain_of_responsibility->handleChange(1000) << endl;

	for (int i=0; i<=10; i++)
	{
		cout << "$" << i*i << endl;
		cout << chain_of_responsibility->handleChange(i*i) << endl;
		cout << endl;
	}

	for (int i=100; i<=105; i++)
	{
		cout << "$" << i*i << endl;
		cout << chain_of_responsibility->handleChange(i*i) << endl;
		cout << endl;
	}

	cout << "Out of 50 and 20" << endl;
	one_dollar->setNext(one_dollar);
	five_dollars->setNext(one_dollar);
	ten_dollars->setNext(five_dollars);
	one_hundred_dollars->setNext(ten_dollars);

	for (int i=10; i<=15; i++)
	{
		cout << "$" << i*i << endl;
		cout << chain_of_responsibility->handleChange(i*i) << endl;
		cout << endl;
	}
}