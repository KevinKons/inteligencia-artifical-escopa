package model;
import java.util.Collections;
import java.util.Stack;

import fails.CardNotFounded;

public class Deck {
	private Stack<Card> cards;
	public Deck() {
		this.cards = new Stack<Card>();
		String [] naipes = {"clubs","coins","swords","cups"};
		for (String naipe:naipes) 
			for (int number=1;number<13;number++) 
				if (number!=8 && number!=9) 
					if (number>9) 
						this.cards.push(new Card(naipe, number, number-2));
					else 
						this.cards.push(new Card(naipe, number, number));
		Collections.shuffle(this.cards);
	}
	public boolean isEmpty(){
		return this.cards.isEmpty();
	}
	public Card popCard() throws CardNotFounded{
		if (this.cards.isEmpty()) {
				throw new CardNotFounded("the deck is empty");
		}
		else {
			return this.cards.pop(); 
		}		
	}
	
}
