// Agent sample_agent in project escoba

/* Initial beliefs and rules */

onhand([]).
ontable([]).
coins(0).
sevens(0).
howmuchisleft([]).

havecoins([],false).
havecoins([card(coins,N)|T],true).
havecoins([H|T],R):-havecoins(T,R).

havesevenofcoins([],false).
havesevenofcoins([card(coins,7)|T],true).
havesevenofcoins([H|T],R):-havesevenofcoins(T,R).

haveseven([],false).
haveseven([card(_,7)|T],true).
haveseven([H|T],R):-haveseven(T,R).

countsevens([],0).
countsevens([card(_,7)|T],R+1):-countsevens(T,R).
countsevens([H|T],R):-countsevens(T,R).

sumnumbers([],0).
sumnumbers([card(_,N)|T],NN):-sumnumbers(T,R) & (N > 7 & NN = N-2 | NN=N).

buscacartasparacoleta(NEEDED,R):- cardontable(NAIPE, NUMBER) & cardontable(NAIPE2, NUMBER2) &
											NUMBER + NUMBER2 = NEEDED & 
											(.member([card(NAIPE,NUMBER), card(NAIPE2,NUMBER2)],R) & RR=R | RR=[[card(NAIPE,NUMBER), card(NAIPE2,NUMBER2)]|R]) &
											buscacartasparacoleta(NEEDED,RR).

cardspossibletocollect(NEEDED,SUM,LA,L,R):- cardontable(NAIPE,N) & (N>7 & NUMBER = N-2 | NUMBER=N) &
										(not .member(card(NAIPE,NUMBER),LA) & NUMBER + SUM < NEEDED & .concat(LA, [card(NAIPE,NUMBER)], NLA) & NSUM=SUM+NUMBER & NL = L|
											not .member(card(NAIPE,NUMBER),LA) & NUMBER + SUM = NEEDED & .concat(LA, [card(NAIPE,NUMBER)], NLA) & NL = [NLA|L] & L=[] & NSUM = 0
										) & 
										cardspossibletocollect(NEEDED, NSUM, NLA, NL, R).
cardspossibletocollect(NEEDED,SUM,LA,L,L).

sumcardsontable(N,L,R):-	cardontable(NAIPE,NUMBER) &
						not .member(card(NAIPE,NUMBER),L) & .concat(L, [card(NAIPE,NUMBER)], LL) & NN=N+NUMBER & 
						sumcardsontable(NN,LL,R).
sumcardsontable(N,L,N).//:-.count(cardontable(_,_),LE) & .length(L,LE).						

countcardsspecs([],0,0,0).
countcardsspecs([card(coins,7)|T],C+1,S+1,Q+1):-countcardsspecs(T,C,S,Q).
countcardsspecs([card(coins,NUMBER)|T],C+1,S,Q+1):-countcardsspecs(T,C,S,Q).
countcardsspecs([card(NAIPE,7)|T],C,C+1,Q+1):-countcardsspecs(T,C,S,Q).
countcardsspecs([card(NAIPE,NUMBER)|T],C,S,Q+1):-countcardsspecs(T,C,S,Q).

discoverbettercombination([],[]).
discoverbettercombination([H|T],[PPP|R]):-discoverbettercombination(T,R) & countcardsspecs(H,C,S,Q) & 
									(sevens(SQ) & SQ<3 & P=S*1 | P=0) & (coins(CQ) & CQ<6 & PP=P+C*1 | PP=P) &
									PPP=PP+Q*0.2.

/* Initial goals */

!start.

/* Plans */

+!start : true <- join.

+hand(card(NAIPE,NUMBER))
	: 	
		onhand(HAND) &
		howmuchisleft(LEFT)
	<-
		+myhand(card(NAIPE,NUMBER)); //Crenças separadas
		-onHand(HAND); //Crença com as cartas numa lista
		+onhand([card(NAIPE,NUMBER)|HAND]);
		
		-howmuchisleft(LEFT);
		+howmuchisleft([15-NUMBER|LEFT]);
		//!showhand;
	.
	
+cardontable(NAIPE,NUMBER)
	:
		ontable(TABLE)
	<-
		+table(card(NAIPE,NUMBER)); //Crenças separadas
		-ontable(TABLE); //Crença com as cartas numa lista
		+ontable([card(NAIPE,NUMBER)|TABLE]);
	.
	
	
+playerturn(Ag)
	:
		.my_name(Ag)& ontable(TABLE)
	<-
		//?sumcardsontable(0,[],R);
		//?cardspossibletocollect(5,0,[],[],R);
		//.print(TABLE);
		//?countcardsspecs(TABLE,C,S,Q);
		?discoverbettercombination([[card(coins,3),card(coins,2),card(cups,3),card(cups,7)],
									[card(coins,2),card(cups,2),card(cups,7)],
									[card(cups,3),card(cups,2),card(cups,3),card(cups,2)]],R);
		.print(R);

	
		//!play;
		
	.	
	
// 1. Scopa utilizando 7 de ouros.
+!play
	:
		onhand(HAND) & havesevenofcoins(HAND,R) & R = true &
		ontable(TABLE) & sumnumbers(TABLE,N) &  N+7=15
	<-
		collectcards(card(cups,7), cards[TABLE]);
		.delete(card(cups,7),HAND,NEWHAND);
		-onhand(HAND);
		+onhand(NEWHAND);
		-ontable(TABLE);
		-ontable([]);
	.
	
// Tentando fazer a estratégia 1 utilizando crenças separadas
//+!play
//	:
//		myhand(coins,7) 
//	<-
//		collectcards(card(cups,7), cards[TABLE]);
//		.delete(card(cups,7),HAND,NEWHAND);
//		-onhand(HAND);
//		+onhand(NEWHAND);
//		-ontable(TABLE);
//		-ontable([]);
//	.

// 2. Coletar utilizando 7 de ouros.
+!play
	:
		myhand(coins, 7) & cardspossibletocollect(8.0,[],[],R) & length(R,L) & L>0
	<-
		
		collectcards(card(cups,7), cards[TABLE]);
		.delete(card(cups,7),HAND,NEWHAND);
		-onhand(HAND);
		+onhand(NEWHAND);
		-ontable(TABLE);
		-ontable([]);
	.
	
	
+!play
	:
		onhand([card(NAIPE,NUMBER)|T])
	<-	
		.length([card(NAIPE,NUMBER)|T], L);
		
//		math.random(L);
		.print(L);
		//.print([card(NAIPE,NUMBER)|T]);
		dropcard(NAIPE,NUMBER);
		-onhand([card(NAIPE,NUMBER)|T]);
		+onhand(T);	
	.
	
// 2. Coletar 7 de ouro.
//+!showhand
//	: true
//	<-
//		?onhand(LISTAA);
//		?howmuchisleft(LISTA);
//		.print(LISTAA);
//		.print(LISTA);	
//	.
//	

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
