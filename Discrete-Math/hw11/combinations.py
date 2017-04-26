def fact(n):
	x = 1
	for i in range(1,n+1):
		x = x*i
	return x

def choose(n,r):
	x = fact(n)
	y = fact(r)
	z = fact(n-r)
	return x/(y*z)

def pchoose(n,r):
	x = choose(n,r)
	print(str(n)+" choose " + str(r) + ": " + str(x))

def total_choose(n, _range):
	total = 0
	for i in _range:
		pchoose(n,i)
		total += choose(n,i)
	print("Total: " + str(total))

def perm(n,r):
	x = fact(n)
	y = fact(n-r)
	return x/y

def pperm(n,r):
	x = perm(n,r)
	print("P({},{}) = ".format(n,r) + str(x))


def intitial_amount(p,i, n):
	# A = P(1+i)^-n
	# if interest is compound, i/month
	# n = time multiplied by amount/time
	return pow(p*(1+i),-1*n)


def main():	
	# x = choose(8,4)
	# y= choose(6,4)
	# print(x+y)
	# pchoose(9,4)
	# pperm(9,4)
	pperm(1500,4)



if __name__ == "__main__":
	main() 