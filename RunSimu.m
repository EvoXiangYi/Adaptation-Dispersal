arguments=csvread("InputArguments.csv");
for i=1:size(arguments)(1)
	x=[arguments(i,:)];
	x=mat2cell(x,1,ones(1,numel(x)));
	DispersalSimulation(x{:});
end

%DispersalSimulation(5,1000,2.0,-0.619039,1,0.01,0.01,0.03,0.01);