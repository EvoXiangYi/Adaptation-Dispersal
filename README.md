# Adaptation-Dispersal
test scripts to run on the university cluster
The main function is "DispersalSimulation.m". It takes each line of the "InputArguments.csv" as arguments.
There are a few function files as well, such as "myID_parent.m", "myDistance.m", etc.
The output will be one or more .csv file(s).

Current problem:
I still haven't figured out how to pass the arguments from the file into the main function.
For example, if I copy the first line of the arguments "1000,2.0,-0.619039,1,0.01,0.01,0.03,0.01" and copy it into a "RunSimu.m" file, whilch is simply one line:
DispersalSimulation(1000,2.0,-0.619039,1,0.01,0.01,0.03,0.01);
And it works. 
But I don't know how to take the arguments from the input file directly.
For example, this doesn't work:
arguments=csvread("version01Input.csv");
for i=1:size(arguments)(1)
	DispersalSimulation([arguments(i,:)]);
end
I guess it's because the data structure of the line is a vector, the function "DispersalSimulation" takes it as a whole as the first argument... But I don't know how to fix it...
