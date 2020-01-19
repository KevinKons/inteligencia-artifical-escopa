// Agent sample_agent in project trabalho

/* Initial beliefs and rules */
on_table([]).
on_hand([]).

remove_card(X, [], []).
remove_card(X, [X|T], NEWLIST):-remove_card(X, T, N1) & NEWLIST=N1.
remove_card(X, [H|T], NEWLIST):-remove_card(X, T, N1) & NEWLIST=[H|N1].

number_to_points(X, Y):-X>=10 & Y = X - 2.
number_to_points(X, Y):-X<10 & Y = X.

points_to_number(X, Y):-X>=8 & Y = X + 2.
points_to_number(X, Y):-X<8 & Y = X.

points_on_list([], P):-P=0.
points_on_list([card(NAIPE, NUMBER, POINTS)|[]], P):-P=NUMBER.
points_on_list([card(NAIPE, NUMBER, POINTS)|T], P):- points_on_list(T, P1) & P=P1+NUMBER.

get_lower_hand([card(NAIPE, NUMBER, POINTS)], L):-L=card(NAIPE, NUMBER, POINTS).
get_lower_hand([card(NAIPE, NUMBER, POINTS)|T], L):-get_lower_hand(T, card(NA, NU, PO)) & NUMBER >= NU & L = card(NA, NU, PO). 
get_lower_hand([card(NAIPE, NUMBER, POINTS)|T], L):-get_lower_hand(T, card(NA, NU, PO)) & NUMBER  < NU & L = card(NAIPE, NUMBER, POINTS). 

get_higher_hand([card(NAIPE, NUMBER, POINTS)], L):-L=card(NAIPE, NUMBER).
get_higher_hand([card(NAIPE, NUMBER, POINTS)|T], L):-get_lower_hand(T, card(NA, NU, PO)) & NUMBER  < NU & L = card(NA, NU, PO). 
get_higher_hand([card(NAIPE, NUMBER, POINTS)|T], L):-get_lower_hand(T, card(NA, NU, PO)) & NUMBER >= NU & L = card(NAIPE, NUMBER, POINTS). 

change_to_patter([],[]).
change_to_patter([card(A, B, C)|T], X):-change_to_patter(T, X1) & X = [card(A, B)|X1].

convert_pontuation([], []).
convert_pontuation([card(NAIPE, POINTS)|T], X):-convert_pontuation(T, X1) & points_to_number(POINTS, NUMBER) & X=[card(NAIPE, NUMBER)|X1].

get_list_table(N, M):-cardontable(X,Y) & (X \== coins & Y \== 7) & number_to_points(Y, K) & Z = 1 & not .member(card(X,K,Z), N) & .concat(N, [card(X,K,Z)], NZ) & get_list_table(NZ, M).
get_list_table(N, M):-cardontable(X,Y) & (X = coins & Y = 7) & number_to_points(Y, K) & Z = 5 & not .member(card(X,K,Z), N) & .concat(N, [card(X,K,Z)], NZ) & get_list_table(NZ, M).
get_list_table(N, M):-cardontable(X,Y) & (X \== coins & Y = 7) & number_to_points(Y, K) & Z = 4 & not .member(card(X,K,Z), N) & .concat(N, [card(X,K,Z)], NZ) & get_list_table(NZ, M).
get_list_table(N, M):-cardontable(X,Y) & (X = coins & Y \== 7) & number_to_points(Y, K) & Z = 2 & not .member(card(X,K,Z), N) & .concat(N, [card(X,K,Z)], NZ) & get_list_table(NZ, M).
get_list_table(N, N).
                        
//________________________________________________________________________________________________________________________

weight([],0).
weight([card(_,W,_)|Rest], X) :-  weight(Rest,RestW) &  X = W + RestW.

points([],0).
points([card(_,_,P) | Rest], X) :-  points(Rest,RestP) &  X = P + RestP.

subseq([],[]).
subseq([Item | RestX], [Item | RestY]) :-  subseq(RestX,RestY).
subseq(X, [_ | RestY]) :-  subseq(X,RestY).

legalKnapsack(PANTRY,CAPACITY,Knapsack):-  (subseq(Knapsack,PANTRY)  &  weight(Knapsack,W)  &  W = CAPACITY 
	& points(Knapsack, POINTS)) & 
	not (subseq(Knapsack2,PANTRY) &  weight(Knapsack2,W2) &  W2 = CAPACITY
		& points(Knapsack2, POINTS2) & POINTS > POINTS2
	).

/* Initial goals */

!start.

/* Plans */

+!start 
	: true 
	<- 
		join;
	.

		
+playerturn(AGENTE)
		: .my_name(AGENTE) 
		<-		
			-on_table(HAND);
			?get_list_table([], Z);
			+on_table(Z);
			!play;
		.
		
// Na verdade ele não utiliza os pontos da mochila nas cartas da mão. Mas, para deixar padronizado incluo diferente para ouros e 7s.

//+hand(card(NAIPE, NUMBER))
//	: number_to_points(NUMBER, X) &
//	NAIPE = coins
//	<-
//		-on_hand(HAND);
//		+on_hand([card(NAIPE, X, 2) | HAND]);
//	.
//	
//+hand(card(NAIPE, NUMBER))
//	: number_to_points(NUMBER, X) &
//	NUMBER = 7
//	<-
//		!include_hand(NAIPE, X);
//	.
//

+hand(card(NAIPE, NUMBER))
	: number_to_points(NUMBER, X)
	<-
		!include_hand(NAIPE, X);
		+card(NAIPE, X);
	.
	
@include_card[atomic]
+!include_hand(NAIPE, X) : true
	<-
		-on_hand(HAND);
		+on_hand([card(NAIPE, X, 1) | HAND]);
	.
	
	
@remove_card_drop[atomic]
+!removecarddrop(NAIPE, POINT, WEIGHT, NUMBER) : true
		<-
			dropcard(NAIPE, NUMBER);
			-on_hand(HAND);
			?remove_card(card(NAIPE, POINT, WEIGHT), HAND, W);
			+on_hand(W);
			-card(NAIPE, POINT);
		.


@remove_card[atomic]
+!removecard(NAIPE, POINT, WEIGHT) : true
		<-
			-on_hand(HAND);
			?remove_card(card(NAIPE, POINT, WEIGHT), HAND, W);
			+on_hand(W);
			-card(NAIPE, POINT);
		.

//Primeiro eu testo com as cartas de ouros.
	
+!play 
	: on_table(TABLE) &
	 on_hand([card(NAIPE, POINT, WEIGHT)|REST]) &
	 NAIPE = coins &
	  legalKnapsack(TABLE, (15-POINT), X) &
	   change_to_patter(X, Y) &
	    convert_pontuation(Y, O) &
	     points_to_number(POINT, NUMBER)
		<-
			collectcards(card(NAIPE, NUMBER), O);
			!removecard(NAIPE, POINT, WEIGHT);
		.
		
//Segundo eu testo com as cartas com pontuação 7.
		
+!play 
	: on_table(TABLE) &
	 on_hand([card(NAIPE, POINT, WEIGHT)|REST]) &
	 POINT = 7 &
	  legalKnapsack(TABLE, (15-POINT), X) &
	   change_to_patter(X, Y) &
	    convert_pontuation(Y, O) &
	     points_to_number(POINT, NUMBER)
		<-
			collectcards(card(NAIPE, NUMBER), O);
			!removecard(NAIPE, POINT, WEIGHT);
		.
	
// Em seguida eu testo todas as cartas da mão.
	
+!play 
	: on_table(TABLE) &
	 on_hand([K, L, card(NAIPE, POINT, WEIGHT)]) &
	  legalKnapsack(TABLE, (15-POINT), X) &
	   change_to_patter(X, Y) &
	    convert_pontuation(Y, O) &
	     points_to_number(POINT, NUMBER)
		<-
			collectcards(card(NAIPE, NUMBER), O);
			!removecard(NAIPE, POINT, WEIGHT);
		.
		
+!play 
	: on_table(TABLE) &
	 on_hand([K, card(NAIPE, POINT, WEIGHT)|REST]) &
	  legalKnapsack(TABLE, (15-POINT), X) &
	   change_to_patter(X, Y) &
	    convert_pontuation(Y, O) &
	     points_to_number(POINT, NUMBER)
		<-
			collectcards(card(NAIPE, NUMBER), O);
			!removecard(NAIPE, POINT, WEIGHT);
		.

+!play 
	: on_table(TABLE) &
	 on_hand([card(NAIPE, POINT, WEIGHT)|REST]) &
	  legalKnapsack(TABLE, (15-POINT), X) &
	   change_to_patter(X, Y) &
	    convert_pontuation(Y, O) &
	     points_to_number(POINT, NUMBER)
		<-
			collectcards(card(NAIPE, NUMBER), O);
			!removecard(NAIPE, POINT, WEIGHT);
		.
		
// Se houverem pelo menos 15 pontos na mesa eu jogo a menor carta diferente de 7.
		
+!play 
	: on_hand(HAND) &
	  points_on_list(HAND, P) &
	  P >= 15 &
	  get_lower_hand(HAND, card(X, Y, Z)) &
	  Y \== 7 &
	  points_to_number(Y, K)
		<-
			.print(Y, K);
//			dropcard(X, K);
			!removecarddrop(X, Y, Z, K);
		.
		
// Se houverem menos de 15 pontos na mesa eu jogo a maior carta diferente de 7.
		
+!play 
	: on_hand(HAND) &
	  points_on_list(HAND, P) &
	  P < 15 &
	  get_higher_hand(HAND, card(X, Y, Z)) &
	  Y \== 7 &
	  points_to_number(Y, K)
		<-
			.print(Y, K);
			
			!removecarddrop(X, Y, Z, K);
		.		
	
// Por fim eu dropo qualquer carta.
	
+!play 
	: on_hand([H|T]) &
	 H = card(X, Y, Z) &
	  points_to_number(Y, K)
		<-
			.print(Y, K);
//			dropcard(X, K);
			!removecarddrop(X, Y, Z, K);
		.	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
//+!play : on_table(CARDS) & check_collect(CARDS, POINTS, C) & card(NAIPE, NUMERO) & number_to_points(NUMERO, NUM) & C + NUM = 15
//		<-
//			collectcards(card(NAIPE, NUMERO), POINTS);
//			-card(NAIPE, NUMERO);
//			?on_hand(Z);
//			?remove_card(card(NAIPE, NUMERO), Z, W);
//			-on_hand(HAND);
//			+on_hand(W);
//		.
//	
//+!play : on_table([card(_,NU)|CARDS]) & check_collect(CARDS, POINTS, C) & card(NAIPE, NUMERO) & number_to_points(NUMERO, NUM) & C + NUM = 15
//		<-
//			collectcards(card(NAIPE, NUMERO), POINTS);
//			-card(NAIPE, NUMERO);
//			?on_hand(Z);
//			?remove_card(card(NAIPE, NUMERO), Z, W);
//			-on_hand(HAND);
//			+on_hand(W);
//		.
//		
//+!play : on_table([card(_,NU),card(_,NU)|CARDS]) & check_collect(CARDS, POINTS, C) & card(NAIPE, NUMERO) & number_to_points(NUMERO, NUM) & C + NUM = 15
//		<-
//			collectcards(card(NAIPE, NUMERO), POINTS);
//			-card(NAIPE, NUMERO);
//			?on_hand(Z);
//			?remove_card(card(NAIPE, NUMERO), Z, W);
//			-on_hand(HAND);
//			+on_hand(W);
//		.
		
//// 1 - Check if its possible to collect all cards
//+!play : on_table(H) & points_on_table(H, R) & number_to_points(NUM, Y) & R + Y = 15
//		<-
//			collectcards(card(_, NUM), on_table);
//			.print(1);
//		.
		
//// 2 - Check if its possible to collect any cards
//+!play : on_table(H) & check_collect(H, R) & points_on_table(R, P) & number_to_points(NUM, Y) & P + Y = 15
//		<-
//			collectcards(card(_, NUM), R);
//			.print(2);
//		.
		
//// 3 - Check if the card to drop will result in 7 or 8 points on the table
//+!play : on_table(H) & points_on_table(H, R) & card(NAIPE, NUM) & number_to_points(NUM, X) & (R + X \== 7 | R + X \== 8)
//		<-
//			dropcard(NAIPE, NUM);
//			.print(3);
//		.
		
//+!play : on_hand(H) & get_lower_hand(H, L) & L = card(X, Y, Z)
//		<-
//			dropcard(X, Y);
//			-card(X, Y, Z);
//			?on_hand(H);
//			?remove_card(card(X, Y, Z), H, W);
//			-on_hand(HAND);
//			+on_hand(W);
//		.

//// 4 - Drop any card
//+!play : card(NAIPE, NUMBER)
//		<-
//			dropcard(NAIPE, NUMBER);
//			.print(4);
//		.
//		

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
