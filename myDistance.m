function [distVector] = myDistance(habitatVector, traitCoordsMatrix, coordsHabitatsMatrix)
	nTraits=size(traitCoordsMatrix)(1);
	popSize=size(traitCoordsMatrix)(2);
	nHabitats=size(coordsHabitatsMatrix)(2);
	traitDist=zeros(nTraits,popSize);
	for i=1:nTraits
		for j=1:nHabitats
			traitDist(i,:) = traitDist(i,:) + abs(traitCoordsMatrix(i,:)-coordsHabitatsMatrix(i,j)).*(habitatVector==j);
		end
	end
	distVector=sqrt(sum(traitDist.^2));
endfunction