function []= DispersalSimulation(InTimeSteps, InpopSize, InNumHabitats, InMeanDispersalTrait, InSigmaDispersalTrait, InSigmaTraitCoordinates, InSigmaDispersal, InMeanHabitatMove, InSigmaHabitatMove)

	%randomStete=csvread("state_file1.csv");
	%rand("state",randomStete);

	natSelLociX=1:2; %adaptation traits from both parents
	natSelLociY=3:4;
	dispLociF=5:6;
	dispLociS=7:8;
	dispLociM=9:10;
	sex=11;
	habitat=12;

	%Initialize population
	popSize = InpopSize;
	numHabitats=InNumHabitats;
	K = 2 * popSize/numHabitats; %carrying capacity


	Init_Mean=InMeanDispersalTrait;
	Init_Prob_dispersal=1/(1+exp(-Init_Mean));
	Init_Sigma=InSigmaDispersalTrait;


	N = zeros(habitat, popSize); %Initialize the "diploid genome"
	N(1:natSelLociY(end),:) = rand(natSelLociY(end),popSize); %Initialize environmatal coordinates
	N(dispLociF(1):dispLociM(end),:) = normrnd(Init_Mean,Init_Sigma,[dispLociM(end)-natSelLociY(end),popSize]);
	N(sex,:) = unidrnd(2,1,popSize)-1; %female:0, males:1
	N(habitat,:) = unidrnd(numHabitats,1,popSize);

	%Mutations and Habitat changes
	sigmaTraitCoordinates=InSigmaTraitCoordinates;
	sigmaDispersal=InSigmaDispersal;
	meanHabitatMove=InMeanHabitatMove;
	sigmaHabitatMove=InSigmaHabitatMove;


	%Initialize stat matrix
	timeSteps = InTimeSteps;


	%Initialize habitat coordinates;
	%coordsHabitatsMatrix=rand(2,1).*ones(2,numHabitats); %2 is the number of traits, X, and Y in this case
	coordsHabitatsMatrix=rand(2,numHabitats);


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%    Only do it for NumHabitat = 2      %%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	RecordHabitat1=zeros(2,timeSteps);
	RecordHabitat2=zeros(2,timeSteps);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%    Only do it for NumHabitat = 2      %%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	%Summary data:1->total number of individuals, 2->mean distance to the habitat centre, 3->female dispersal, 4->male dispersal
	SummaryData=NaN(6,timeSteps);


	for t=1:timeSteps
		%Selection by Environment
		t
		trait_x=mean(N(natSelLociX,:));
		trait_y=mean(N(natSelLociY,:));
		traitCoordsMatrix=[trait_x; trait_y];
		habitatVector=N(habitat,:);
		distVector = myDistance(habitatVector, traitCoordsMatrix, coordsHabitatsMatrix);
		envSteepness=0;
		survEnv=(rand(1,popSize)<exp(-envSteepness*distVector.^2)).*(N(sex,:)==0)+(rand(1,popSize)<exp(-envSteepness*distVector.^2)).*(N(sex,:)==1);
	
		%Selection by Competition
		survComp=zeros(1,popSize);
		for i=1:numHabitats
			Juv_H_i=find(N(habitat,:)==i);
			numJuv_H_i=length(Juv_H_i);
			if or(numJuv_H_i < K, numJuv_H_i==K)
				survComp(Juv_H_i)=1;
			else
				survComp(Juv_H_i(randperm(numJuv_H_i)(1:K)))=1;
			end
		end
	
		%Final Survival
		surv=and(survEnv, survComp);
		N(habitat,surv==0)=0; % habitat equals 0 for those who are dead
	
		%Population census
		females=cell(1,numHabitats);
		males=cell(1,numHabitats);
		femaleTraitDistance=cell(1,numHabitats);
		maleTraitDistance=cell(1,numHabitats);
		femaleResource=cell(1,numHabitats);
		maleQuality=cell(1,numHabitats);
		for i=1:numHabitats
			%count individuals, record sex ratio
			LocalFemales=find(and(N(habitat,:)==i, N(sex,:)==0));
			LocalMales=find(and(N(habitat,:)==i, N(sex,:)==1));
		
			if or(length(LocalFemales)==0, length(LocalMales)==0) %doesn't make sense to record if there's only one sex in a habitat
				continue;
			end
			males{i}=LocalMales;
			numMales=length(LocalMales);
			females{i}=LocalFemales;
			numFemales=length(LocalFemales);
		
			%recourd female resource
			femaleTrait_x=mean(N(natSelLociX,LocalFemales));
			femaleTrait_y=mean(N(natSelLociY,LocalFemales));
			femaleTraitCoordsMatrix=[femaleTrait_x; femaleTrait_y];
			femaleTraitDistance{i}=myDistance(i*ones(1,numFemales),femaleTraitCoordsMatrix,coordsHabitatsMatrix);
			femaleResourceSteepness=3;
			femaleRawResource=exp(-femaleResourceSteepness*femaleTraitDistance{i}.^2);
		
		
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%%%%%%%%    Soft selection on Female fitness     %%%%%%%%%
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%femaleResource{i}=femaleRawResource/sum(femaleRawResource);
		
		
		
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%%%%%%%%    Hard selection on Female fitness     %%%%%%%%%
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			femaleResource{i}=femaleRawResource;
		
			%record male trait distance and quality at this habitat
			maleTrait_x=mean(N(natSelLociX,LocalMales));
			maleTrait_y=mean(N(natSelLociY,LocalMales));
			maleTraitCoordsMatrix=[maleTrait_x; maleTrait_y];
			maleTraitDistance{i}=myDistance(i*ones(1,numMales),maleTraitCoordsMatrix,coordsHabitatsMatrix);
			MaleQualitySteepness=3;
			maleQuality{i}=exp(-MaleQualitySteepness*maleTraitDistance{i}.^2);
		
				
		end
	
		NumHabitatsWithFemales=length(females(~cellfun('isempty',females)));
	
		survivedIndivs=find(N(habitat,:) != 0);
		totalSurv=length(survivedIndivs);
		if totalSurv < 10
			break;
		end
	
		Idxfemales=cell2mat(females);
		femaleResourceArray=cell2mat(femaleResource);
	
		meanFemaleTraitDistance=mean(cell2mat(femaleTraitDistance));
		meanMaleTraitDistance=mean(cell2mat(maleTraitDistance));
		meanFemaleDispersal=mean(mean(N(dispLociF(1):dispLociS(end),Idxfemales)));
		ProbmeanFemaleDispersal=1/(1+exp(-meanFemaleDispersal));
		meanMaleDispersal=mean(mean(N(dispLociS(1):dispLociM(end),cell2mat(males))));
		ProbmeanMaleDispersal=1/(1+exp(-meanMaleDispersal));
	
	
		%[totalSurv; NumHabitatsWithFemales; meanFemaleTraitDistance; meanMaleTraitDistance; ProbmeanFemaleDispersal; ProbmeanMaleDispersal]
		SummaryData(:,t)=[totalSurv; NumHabitatsWithFemales; meanFemaleTraitDistance; meanMaleTraitDistance; ProbmeanFemaleDispersal; ProbmeanMaleDispersal];
	
		%produce offspring one by one
		young=NaN(habitat,popSize); 
		for i=1:popSize 
			%pick a mom
			MomID=Idxfemales(myID_parent(femaleResourceArray));
			momGenome=N(:,MomID);
			momHabitat=N(end,MomID);
		
			%pick a dad from mom's habitat
			DadID=males{momHabitat}(myID_parent(maleQuality{momHabitat}));
			dadGenome=N(:,DadID);
		
			%construct offspring genome, assume all loci are independent in linkage
			young(1,i)=momGenome(unidrnd(2),1); %Environmental X trait from mom
			young(2,i)=dadGenome(unidrnd(2),1); %Environmental X trait from dad
			young(3,i)=momGenome(unidrnd(2)+natSelLociX(end),1); %Environmental Y trait from mom
			young(4,i)=dadGenome(unidrnd(2)+natSelLociX(end),1); %Environmental Y trait from dad
			young(5,i)=momGenome(unidrnd(2)+natSelLociY(end),1); %Females dispersal trait from mom
			young(6,i)=dadGenome(unidrnd(2)+natSelLociY(end),1); %Females dispersal trait from dad
			young(7,i)=momGenome(unidrnd(2)+dispLociF(end),1); %shared dispersal trait from mom
			young(8,i)=dadGenome(unidrnd(2)+dispLociF(end),1); %shared dispersal trait from dad
			young(9,i)=momGenome(unidrnd(2)+dispLociS(end),1); %male dispersal trait from mom
			young(10,i)=dadGenome(unidrnd(2)+dispLociS(end),1); %male dispersal trait from dad
			young(sex,i)=unidrnd(2)-1;
			young(habitat,i)=momHabitat;
		
			%offspring mutation
			mutations=[normrnd(0,sigmaTraitCoordinates,4,1); normrnd(0,sigmaDispersal,6,1); 0; 0];
			young(:,i)=young(:,i)+mutations;

		end
		N=young; %Replace the old generation
	
		%dispersal process!!!!
		TraitsOffspringDispersal=mean(N(dispLociF(1):dispLociS(end),:)).*(N(sex,:)==0)+mean(N(dispLociS(1):dispLociM(end),:)).*(N(sex,:)==1);
		ProbOffspringDispersal=1./(1+exp(-TraitsOffspringDispersal));
		willmove=rand(1,popSize)<ProbOffspringDispersal;
	
		probDeathbyDispersal=0;
		movedIndividuals=find(willmove==1);
		movedDead=rand(size(movedIndividuals))<probDeathbyDispersal;
		N(habitat,movedIndividuals(find(movedDead==1)))=0;
		N(habitat,movedIndividuals(find(movedDead==0)))=unidrnd(numHabitats);
	
	
		%Habitats change
		%habitatChanges=[normrnd(0,sigmaHabitatMove,2,1).*ones(1,numHabitats/2), normrnd(0,sigmaHabitatMove,2,1).*ones(1,numHabitats/2)];
		%habitatChanges=normrnd(0,sigmaHabitatMove,2,numHabitats);
		goDown=rand(2,numHabitats)<coordsHabitatsMatrix;
		habitatChanges=-abs(normrnd(meanHabitatMove,sigmaHabitatMove,2,numHabitats)).*(goDown==1)+abs(normrnd(meanHabitatMove,sigmaHabitatMove,2,numHabitats)).*(goDown==0);
		coordsHabitatsMatrix=coordsHabitatsMatrix+habitatChanges;
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%    Only do it for NumHabitat = 2      %%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		RecordHabitat1(:,t)=coordsHabitatsMatrix(:,1);
		RecordHabitat2(:,t)=coordsHabitatsMatrix(:,2);
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%    Only do it for NumHabitat = 2      %%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	end

	csvwrite([strcat("FemaleHard-NumHabitats-2-InitDispProb-",num2str(Init_Prob_dispersal),".csv")], SummaryData);
	csvwrite([strcat("FemaleHard-NumHabitats-2-InitDispProb-",num2str(Init_Prob_dispersal),"-CoordinatesHabitat-1.csv")],RecordHabitat1);
	csvwrite([strcat("FemaleHard-NumHabitats-2-InitDispProb-",num2str(Init_Prob_dispersal),"-CoordinatesHabitat-2.csv")],RecordHabitat2);
	
endfunction