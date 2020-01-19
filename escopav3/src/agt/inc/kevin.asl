// Agent sample_agent in project escoba

/* Initial beliefs and rules */

coins(0).
sevens(0).
qntontable(0).
cardsalreadyshown([]).

realvalue(NUMBER,VALUE):-NUMBER>=10 & VALUE=NUMBER-2 | VALUE=NUMBER. 

qntofnumber([],NUMBER,0).
qntofnumber([card(NAIPE,NUMBER)|T],NUMBER,R+1):-qntofnumber(T,NUMBER,R).
qntofnumber([card(NAIPE,NUMBER)|T],NUMBER2,R):-qntofnumber(T,NUMBER,R).

qntofsevens([],0).
qntofsevens([card(NAIPE,7)|T],R+1):-qntofsevens(T,R).
qntofsevens([card(NAIPE,NUMBER)|T],R):-qntofsevens(T,R).

qntofcoins([],0).
qntofcoins([card(coins,NUMBER)|T],R+1):-qntofcoins(T,R).
qntofcoins([card(NAIPE,NUMBER)|T],R):-qntofcoins(T,R).

getcardsontable(L,R):- cardontable(NAIPE,NUMBER) &
						not .member(card(NAIPE,NUMBER),L) & .concat(L, [card(NAIPE,NUMBER)], LL) & 
						getcardsontable(LL,R).
getcardsontable(L,L).

sumcards([],0).
sumcards([card(NAIPE,NUMBER)|T],RNUMBER+R):-realvalue(NUMBER,RNUMBER) & sumcards(T,R).

getcardsonhand(L,R):- onhand(card(NAIPE,NUMBER)) &
						not .member(card(NAIPE,NUMBER),L) & .concat(L, [card(NAIPE,NUMBER)], LL) & 
						getcardsonhand(LL,R).
getcardsonhand(L,L).			
											
countcardsspecs([],0,0,0).
countcardsspecs([card(coins,7)|T],C+1,S+1,Q+1):-countcardsspecs(T,C,S,Q).
countcardsspecs([card(coins,NUMBER)|T],C+1,S,Q+1):-countcardsspecs(T,C,S,Q).
countcardsspecs([card(NAIPE,7)|T],C,S+1,Q+1):-countcardsspecs(T,C,S,Q).
countcardsspecs([card(NAIPE,NUMBER)|T],C,S,Q+1):-countcardsspecs(T,C,S,Q) .
									
combinationvalue(L,VVV):-countcardsspecs(L,C,S,Q) & (sevens(SQ) & SQ<3 & V=S*1 | V=0) & (coins(CQ) & CQ<6 & VV=V+C*1 | VV=V) &
									VVV=VV+Q*0.2.
						
collecttable(L,15,L).
collecttable(L,S,R):-    cardontable(NAIPE,NUMBER) & realvalue(NUMBER,RN) &
                         not .member(card(NAIPE,NUMBER),L) &                    
                         S+RN<16 & collecttable([card(NAIPE,NUMBER)|L],S+RN,R).

collect(R) :-    onhand(card(NAIPE,NUMBER)) &
                 realvalue(NUMBER,RN) &
                 collecttable([card(NAIPE,NUMBER)],RN,R).
                 
collectwith(R,card(NAIPE,NUMBER)) :-    realvalue(NUMBER,RN) &
				 	   					collecttable([card(NAIPE,NUMBER)],RN,R).

/* Initial goals */

!start.

/* Plans */

+!start : true <- join .//+playerturn(sample_agent1).

@hand[atomic]
+hand(card(NAIPE,NUMBER))
	: 	
		true
	<-
		+onhand(card(NAIPE,NUMBER));
		
		?cardsalreadyshown(CAS);	
		if( not .member(card(NAIPE,NUMBER),CAS) ) {
			.concat(CAS,[card(NAIPE,NUMBER)],NCAS);
			-cardsalreadyshown(CAS);
			+cardsalreadyshown(NCAS);
		}	
	.

@playerturn[atomic]
+playerturn(Ag)
	:
		.my_name(Ag) 
	<-
		?getcardsontable([],C);
		?sumcards(C,SUM);

		-qntontable(_);
		+qntontable(SUM);
		
		.length(C,L);
		for( .range(I,0,L-1) ) {
			.nth(I,C,E);
			?cardsalreadyshown(CAS);
			if( not .member(E,CAS) ) {
				.concat(CAS,[E],NCAS);
	 			-cardsalreadyshown(CAS);
				+cardsalreadyshown(NCAS);
			}
		}
	
		!play;
	.	

@notplayerturn[atomic]
+playerturn(Ag)
	:
		not .my_name(Ag) 
	<-	
		?getcardsontable([],C)
		.length(C,L);
		
		for( .range(I,0,L-1) ) {
			.nth(I,C,E);
			?cardsalreadyshown(CAS);
			if( not .member(E,CAS) ) {
				.concat(CAS,[E],NCAS);
	 			-cardsalreadyshown(CAS);
				+cardsalreadyshown(NCAS);
			}
		}
	.	
	
// 1 . Scopa com 7 de ouro
@scopacomsetedeouro[atomic]
+!play
	:
		onhand(card(coins,7)) & sevens(S) & coins(C) & 
		qntontable(8) &
		getcardsontable([],R)
	<-
		collectcards(card(coins,7), R);
		-onhand(card(coins,7));
		
		?qntofsevens(R,QS);
		?qntofcoins(R,QC);
		-coins(C);
		+coins(C+1+QC);
		-sevens(S);
		+sevens(S+1+QS);
	.
	
// 2. Coletar utilizando 7 de ouros.
@coletarutilizando7deouro[atomic]
+!play
	: 
		onhand(card(coins,7)) & coins(C) & sevens(S) &
		collectwith(R,card(coins,7)) & combinationvalue(R,V) & not (
				                collectwith(R2,card(coins,7)) & combinationvalue(R2,V2) & V2>V
				                 ) &
				                 .reverse(R,[card(NAIPE,NUMBER)|T])	
	<-		
		collectcards(card(coins,7), T);
		-onhand(card(coins,7));
		
		?qntofsevens(R,QS);
		?qntofcoins(R,QC);
		-coins(C);
		+coins(C+QC);
		-sevens(S);
		+sevens(S+QS);
		
	.
	
// 3. Scopa com 7.
@scopacomsete[atomic]
+!play
	:
		onhand(card(NAIPE,7)) & qntontable(8) & coins(C) & sevens(S) & 
		getcardsontable([],CARDSONTABLE)
	<-
		collectcards(card(NAIPE,7), CARDSONTABLE);
		-onhand(card(NAIPE,7));
		
		?qntofsevens(CARDSONTABLE,QS);
		?qntofcoins(CARDSONTABLE,QC);
		-coins(C);
		+coins(C+QC);
		-sevens(S);
		+sevens(S+QS+1);
	.
	

// 4. Scopa com ouro.
@scopacomouro[atomic]
+!play
	:
		onhand(card(coins,NUMBER)) & realvalue(NUMBER, RN) & qntontable(Q) & Q+RN==15 & 
		getcardsontable([],CARDSONTABLE) & 
		coins(C) & sevens(S) 
	<-
		collectcards(card(coins,NUMBER), CARDSONTABLE);
		-onhand(card(coins,NUMBER));
		
		?qntofsevens(CARDSONTABLE,QS);
		?qntofcoins(CARDSONTABLE,QC);
		-coins(C);
		+coins(C+QC+1);
		-sevens(S);
		+sevens(S+QS);
	.
	

// 5. Scopa com 6.
@scopacomseis[atomic]
+!play
	:
		onhand(card(NAIPE,6)) & qntontable(9) & 
		getcardsontable([],CARDSONTABLE) &
		coins(C) & sevens(S) 
	<-
		collectcards(card(NAIPE,6), CARDSONTABLE);
		-onhand(card(NAIPE,6));
		
		?qntofsevens([card(NAIPE,6)|CARDSONTABLE],QS);
		?qntofcoins([card(NAIPE,6)|CARDSONTABLE],QC);
		-coins(C);
		+coins(C+QC);
		-sevens(S);
		+sevens(S+QS);
	.

// 6. Scopa com uma carta qualquer
@scopacomqualquercoisa[atomic]
+!play
	:
		onhand(card(NAIPE,NUMBER)) & realvalue(NUMBER,NR) &
		qntontable(A) & A+NR==15 & 
		getcardsontable([],CARDSONTABLE) &
		coins(C) & sevens(S) 
	<-
		collectcards(card(NAIPE,NUMBER), CARDSONTABLE);
		-onhand(card(NAIPE,NUMBER));
		
		?qntofsevens([card(NAIPE,NUMBER)|CARDSONTABLE],QS);
		?qntofcoins([card(NAIPE,NUMBER)|CARDSONTABLE],QC);
		-coins(C);
		+coins(C+QC);
		-sevens(S);
		+sevens(S+QS);
	.
	
	
// 7. Coletar utilizando 7.
@coletarutilizandosete[atomic]
+!play
	:
		onhand(card(NAIPE,7)) & coins(C) & sevens(S) &
		collectwith(R,card(NAIPE,7)) & combinationvalue(R,V) & not (
		                collectwith(R2,card(NAIPE,7)) & combinationvalue(R2,V2) & V2>V
		                 ) &
		                 .reverse(R,[card(NAIPE,NUMBER)|T])	
	<-
		collectcards(card(NAIPE,7),T);
		-onhand(card(NAIPE,7));
		
		?qntofsevens(R,QS);
		?qntofcoins(R,QC);
		-coins(C);
		+coins(C+QC);
		-sevens(S);
		+sevens(S+QS);
	.
	
// 8. Coletar utizando ouro.
@coletarutilizandoouro[atomic]
+!play
	:
		onhand(card(coins,NUMBER)) & coins(C) & sevens(S) & 
		collectwith(R,card(coins,NUMBER)) & combinationvalue(R,V) & not (
		                collectwith(R2,card(coins,NUMBER)) & combinationvalue(R2,V2) & V2>V
		                 ) &
		                 .reverse(R,[card(NAIPE,NUMBER)|T])	
		
	<-	
		collectcards(card(coins,NUMBER),T);
		-onhand(card(coins,NUMBER));
		
		?qntofsevens(R,QS);
		?qntofcoins(R,QC);
		-coins(C);
		+coins(C+QC);
		-sevens(S);
		+sevens(S+QS);
	.
	
// 9. Coletar utilzando 6.
@coletarutilizando[atomic]
+!play
	:
		onhand(card(NAIPE,6)) & coins(C) & sevens(S) & 
		collectwith(R,card(NAIPE,6)) & combinationvalue(R,V) & not (
                collectwith(R2,card(NAIPE,6)) & combinationvalue(R2,V2) & V2>V
                 ) &
                 .reverse(R,[card(NAIPE,NUMBER)|T])	
	<-	
		collectcards(card(NAIPE,6),T);
		-onhand(card(NAIPE,6));
		
	    ?qntofsevens(R,QS);
		?qntofcoins(R,QC);
		-coins(C);
		+coins(C+QC);
		-sevens(S);
		+sevens(S+QS);
	.
	
// 10. Coletar com qualquer carta
@coletarcomqualquercarta[atomic]
+!play
	:
		collect(R) & combinationvalue(R,V) & not (
                collect(R2) & combinationvalue(R2,V2) & V2>V
                 ) &
                 .reverse(R,[card(NAIPE,NUMBER)|T]) &
        coins(C) & sevens(S) 
	<-	
		
	
		collectcards(card(NAIPE,NUMBER),T);
		-onhand(card(NAIPE,NUMBER));
		
		?qntofsevens(R,QS);
		?qntofcoins(R,QC);
		-coins(C);
		+coins(C+QC);
		-sevens(S);
		+sevens(S+QS);
	.
// Descarta uma carta - que não seja ouro ou 7 - soma das cartas na mesa deve ficar inferior a 4.
@descarteum[atomic]
+!play
	:
		onhand(card(NAIPE,NUMBER)) & realvalue(NUMBER,NR) & 
		NAIPE\==coins & qntontable(Q) & Q+NR<5   
	<-
		dropcard(NAIPE,NUMBER);
		-onhand(card(NAIPE,NUMBER));
	.

// Descarta uma carta - que não seja ouro ou 7 - soma das cartas na mesa deve ficar superior a 15.
@descartedois[atomic]
+!play
	:
		onhand(card(NAIPE,NUMBER)) & realvalue(NUMBER,NR) & 
		NAIPE\==coins & NUMBER\==7 & qntontable(Q) & Q+NR>15   
	<-
		dropcard(NAIPE,NUMBER);
		-onhand(card(NAIPE,NUMBER));
	.

//Descarta uma carta que faça com que para ser possível fazer scopa o adversário deva utilizar uma carta que não está mais no jogo
@descartetres[atomic]
+!play
	:
		onhand(card(NAIPE,NUMBER)) & realvalue(NUMBER,RN) &
		NAIPE\==coins & NUMBER\==7 &
		cardsalreadyshown(CAS) & qntofnumber(CAS,CARDTOBEDROPPED,Q) & Q>3 & 
		qntontable(QOT) & QOT+RN=NQOT & VALORRESTANTE=15-NQOT & 
	    (VALORRESTANTE>=8 & RVALORRESTANTE=VALORRESTANTE+2 | RVALORRESTANTE=VALORRESTANTE) &
		VALORRESTANTE == NUMBER
	<-
		dropcard(NAIPE,NUMBER);
		-onhand(card(NAIPE,NUMBER));
	.

//Descarta uma carta que não seja ouro ou 7.
@descartequatro[atomic]
+!play
	:
		onhand(card(NAIPE,NUMBER)) &
		NAIPE\==coins & NUMBER\==7  
	<-
		dropcard(NAIPE,NUMBER);
		-onhand(card(NAIPE,NUMBER));
	.
	
//Descarta uma carta de ouro, que não seja 7, caso o agente já possua ouros o suficiente
@descartecinco[atomic]
+!play
	:
		onhand(card(NAIPE,NUMBER)) & NUMBER\==7 &
		NAIPE==coins & coins(C) & C>5  
	<-
		dropcard(NAIPE,NUMBER);
		-onhand(card(NAIPE,NUMBER));
	.

// Descarta uma carta soma das cartas na mesa deve ficar inferior a 4.
@descarteseis[atomic]
+!play
	:
		onhand(card(NAIPE,NUMBER)) & realvalue(NUMBER,NR) & 
		qntontable(Q) & Q+NR<4   
	<-
		dropcard(NAIPE,NUMBER);
		-onhand(card(NAIPE,NUMBER));
	.
	
// Descarta uma carta soma das cartas na mesa deve ficar superior a 15.
@descartesete[atomic]
+!play
	:
		onhand(card(NAIPE,NUMBER)) & realvalue(NUMBER,NR) & 
		qntontable(Q) & Q+NR>15   
	<-
		dropcard(NAIPE,NUMBER);
		-onhand(card(NAIPE,NUMBER));
	.
	
//Descarta uma carta que faça com que para ser possível fazer scopa o adversário deva utilizar uma carta que não está mais no jogo
@descarteoito[atomic]
+!play
	:
		onhand(card(NAIPE,NUMBER)) & realvalue(NUMBER,RN) &
		cardsalreadyshown(CAS) & qntofnumber(CAS,CARDTOBEDROPPED,Q) & Q>3 & 
		qntontable(QOT) & QOT+RN=NQOT & VALORRESTANTE=15-NQOT & 
	    (VALORRESTANTE>=8 & RVALORRESTANTE=VALORRESTANTE+2 | RVALORRESTANTE=VALORRESTANTE) &
		VALORRESTANTE == NUMBER
	<-
		dropcard(NAIPE,NUMBER);
		-onhand(card(NAIPE,NUMBER));
	.

// Descartar qualquer carta
@descartenove[atomic]
+!play
	:
		onhand(card(NAIPE,NUMBER))
	<-
		dropcard(NAIPE,NUMBER);
		-onhand(card(NAIPE,NUMBER));
	.
	
+!play
	:
		true
	<-
		.print("N TEM O Q FAZER");
	.
	
	
{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }


