import re
import sys
import operator


istemp = lambda s : bool(re.match(r"^t[0-9]*", s)) 		
isid = lambda s : bool(re.match(r"^[A-Za-z][A-Za-z0-9_]*", s)) 

#icg_file="icg.txt"
icg_file="pp.txt"


def eval_binary_expr(op1, oper, op2):
    op1,op2 = int(op1), int(op2)
    if(oper=='+'):
        return op1+op2
    elif(oper=='-'):
        return op1-op2
    elif(oper=='*'):
        return op1*op2
    elif(oper=="/"):
        return op1/op2
    elif(oper=="<"):
        return op1<op2
    elif(oper==">"):
        return op1>op2


def printICG(list_of_lines):
	for i in range(len(list_of_lines)):
		#print(list_of_lines[i])
		print(list_of_lines[i].strip())

def add_to_dict(x,y,temp_vars):
    temp_vars[x]=y

def constant_folding(list_of_lines):
	for i in range(len(list_of_lines)):
		#print(list_of_lines[i])
		if(len(list_of_lines[i].split())==5):
			x=list_of_lines[i].split()
			if x[2].isdigit() and x[4].isdigit():
				s=" "
				t=s.join([x[0],x[1],str(eval_binary_expr(x[2],x[3],x[4])),"\n"])
				list_of_lines[i]=t
	return list_of_lines


def constant_propagation(list_of_lines):
	#print(list_of_lines)
	temp_vars=dict()
	for i in range(len(list_of_lines)):
		temp_list=list_of_lines[i].split()
		l=len(temp_list)
		if(l==3):
			#while(temp_list[2] in temp_vars):
				#temp_list[2] = temp_vars[temp_list[2]]
				
			add_to_dict(temp_list[0],temp_list[2],temp_vars)
			
		elif(l==5):
			list_of_lines[i]=func1(temp_list,i,temp_vars)
	
	return list_of_lines

def copy_propagation(list_of_lines):
	copy_dict=dict()
	for i in range(len(list_of_lines)):
		temp_list=list_of_lines[i].split()
		l=len(temp_list)
		if(l==3 and isid(temp_list[0]) and isid(temp_list[2])):
			copy_dict[temp_list[0]]=temp_list[2]
			
		elif(l==3 or l==5):
			list_of_lines[i]=func2(temp_list,i,l,copy_dict)
	#print(list_of_lines)
	return list_of_lines

def remove_dead_code(list_of_lines) :
	num_lines = len(list_of_lines)
	temps_on_lhs = set()
	for line in list_of_lines :
		tokens = line.split()
		if istemp(tokens[0]) :
			temps_on_lhs.add(tokens[0])
	#print(temps_on_lhs)
	useful_temps = set()
	for line in list_of_lines :
		tokens = line.split()
		if len(tokens) == 5 :
			if istemp(tokens[2]) :	
				useful_temps.add(tokens[2])
			if istemp(tokens[4]) :	
				useful_temps.add(tokens[4])
		if len(tokens) == 3 :
			if istemp(tokens[2]) :
				useful_temps.add(tokens[2])

	temps_to_remove = temps_on_lhs - useful_temps
	new_list_of_lines = []
	for line in list_of_lines :
		tokens = line.split()
		if tokens[0] not in temps_to_remove :
			new_list_of_lines.append(line)
	if num_lines == len(new_list_of_lines) :
		return new_list_of_lines
	return remove_dead_code(new_list_of_lines)

def func1(x,i,temp_vars):
	s=" "
	list_of_lines[i]=s.join([x[0],x[1],x[2],x[3],x[4],"\n"])
	
	if x[2].isdigit() or x[4].isdigit():
		if x[2].isdigit():
			if(x[4] in temp_vars):
				s=" "
				val=temp_vars[x[4]]
				s=s.join([x[0],x[1],x[2],x[3],val,"\n"])
				list_of_lines[i]=s
				
		elif x[4].isdigit():
			if(x[2] in temp_vars):
				s=" "
				val=temp_vars[x[2]]
				s=s.join([x[0],x[1],val,x[3],x[4],"\n"])
				list_of_lines[i]=s
				     
	else:
		if(x[2] in temp_vars):
			if(x[4] in temp_vars):
				s=" "
				val1=temp_vars[x[2]]
				val2=temp_vars[x[4]]
				s=s.join([x[0],x[1],val1,x[3],val2,"\n"])
				list_of_lines[i]=s
				
			else:
				val=temp_vars[x[2]]
				s=" "
				s=s.join([x[0],x[1],val,x[3],x[4],"\n"])
				list_of_lines[i]=s
				
		if(x[4] in temp_vars):
			val=temp_vars[x[4]]
			s=" "
			s=s.join([x[0],x[1],x[2],x[3],val,"\n"])
			list_of_lines[i]=s
			
	print("in func1 :",list_of_lines[i],"\n")
	return list_of_lines[i]


def func2(x,i,l,copy_dict):
	s=" "
	
	if(l==3):
		list_of_lines[i]=s.join([x[0],x[1],x[2],"\n"])
		if(x[2] in copy_dict):
			s=" "
			s=s.join([x[0],x[1],copy_dict[x[2]],"\n"])
			list_of_lines[i]=s
		
	else:
		list_of_lines[i]=s.join([x[0],x[1],x[2],x[3],x[4],"\n"])
		if(x[2] in copy_dict and x[4] in copy_dict):
			s=" "
			s=s.join([x[0],x[1],copy_dict[x[2]],x[3],copy_dict[x[4]],"\n"])
			list_of_lines[i]=s
		elif(x[2] in copy_dict):
			s=" "
			s=s.join([x[0],x[1],copy_dict[x[2]],x[3],x[4],"\n"])
			list_of_lines[i]=s
		elif(x[4] in copy_dict):
			s=" "
			s=s.join([x[0],x[1],x[2],x[3],copy_dict[x[4]],"\n"])
			list_of_lines[i]=s
		
	
	
	return list_of_lines[i]


# MAIN FUNCTION :

list_of_lines = []
f = open(icg_file, "r")
for line in f :
	#print(line)
	list_of_lines.append(line)
	
f.close()

#print(list_of_lines[0])

print('Initial ICG: ')
printICG(list_of_lines)
print("\n\n")

print('After Copy Propagation:')
list_of_lines = copy_propagation(list_of_lines)
printICG(list_of_lines)
print("\n\n")

print('After Constant Propagation:')
list_of_lines=constant_propagation(list_of_lines)
printICG(list_of_lines)
print("\n\n")

print('After Constant Folding: ')
list_of_lines = constant_folding(list_of_lines)
printICG(list_of_lines)
print("\n\n")

print('After Dead Code Elimination: ')
list_of_lines=remove_dead_code(list_of_lines)
#list_of_lines=remove_dead_code(list_of_lines)
printICG(list_of_lines)

	
