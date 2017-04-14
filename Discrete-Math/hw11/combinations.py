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

def main():	
	# x = choose(8,4)
	# y= choose(6,4)
	# print(x+y)
	# pchoose(9,4)
	# pperm(9,4)
	pchoose(6,2)
	pchoose(6,3)
	pchoose(6,4)
	pchoose(6,5)

	print(45.0/64)

if __name__ == "__main__":
	main() 