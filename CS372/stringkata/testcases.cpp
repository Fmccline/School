/*
	main.cpp
	By Frank Cline, Alex Eckert
	2-18-17
*/

// URL : http://osherove.com/tdd-kata-1

#include "catch.hpp"
#include <iostream>
#include <string>
using std::string;
using std::stoi;
using std::cout;
using std::endl;

int Add(string numbers)
{
	if (numbers.length() == 0)
	{
		return 0;
	}

	string delimiter;
	string sumstr;
	string nonnum;
	const int NUM = 0;
	const int NONNUM = 1;
	int state = NUM;
	int i = 0;
	int sum = 0;
	int index = 0;

	if (numbers.length() >= 4 && numbers.substr(0,2) == "//")
	{
		i = 2;
		while (i < numbers.length() && numbers.at(i) != '\n')
		{
			delimiter += numbers.at(i);
			++i;
		}
		++i;
	}
	else
	{
		delimiter = ",";
	}

	for (i; i<numbers.length(); ++i)
	{
		if (isdigit(numbers.at(i)))
		{
			if (state == NUM)
			{
				sumstr += numbers.at(i);
			}
			else
			{
				if (nonnum != delimiter && nonnum != "\n")
				{
					cout << "Invalid input: " << nonnum << "\n";
					return 0;
				}
				state = NUM;
				sum += stoi(sumstr);
				sumstr = string(1,numbers.at(i));
			}
		}
		else
		{
			if (state == NUM)
			{
				nonnum = string(1,numbers.at(i));
				state = NONNUM;
			}
			else
			{
				nonnum += numbers.at(i);
			}
		}
	}
	if (sumstr.length() > 0)
	{
		sum += stoi(sumstr);		
	}
	return sum;
}

TEST_CASE("String Kata")
{
	REQUIRE(Add("12\n4") == 16);
	REQUIRE(Add("") == 0);
	REQUIRE(Add("1") == 1);
	REQUIRE(Add("12") == 12);
	REQUIRE(Add("1\n2") == 3);
	REQUIRE(Add("10\n11") == 21);
	REQUIRE(Add("12\n4") == 16);
	REQUIRE(Add("110\n111") == 221);
	REQUIRE(Add("101") == 101);
	REQUIRE(Add("1\n2\n3\n4\n5\n6\n9") == 30);
	REQUIRE(Add("//[\n1[2[3[12[41") == 59);
	REQUIRE(Add("//[\n][]p2[41") == 0);
	REQUIRE(Add("213 wq2  213  32 sa") == 0);
	REQUIRE(Add("//[\n") == 0);
	REQUIRE(Add("//***\n1***2***3***41***5") == 52);
}