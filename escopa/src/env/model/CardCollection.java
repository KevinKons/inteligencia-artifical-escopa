package model;
import java.util.ArrayList;

import fails.CardNotFounded;

public class CardCollection {
	private ArrayList<Card> Cards = new ArrayList<Card>();
	private String type;
	public CardCollection(String type) {
		this.type=type;
	}
	public void receive(Card c) {
		this.Cards.add(c);
	}
	public void  drop(Card c) throws CardNotFounded{
		if (!this.Cards.contains(c)) {
			throw new CardNotFounded("the "+type+" is empty");
		}
		else {
			 this.Cards.remove(c);
		}
	}
	
	public Card dropByindex(int i) {		
			Card tmp =this.Cards.get(i);
			this.Cards.remove(i);
			return tmp;	
	}

	
	public boolean check(Card c) {
		return this.Cards.contains(c);
	}
	
	public ArrayList<Card> getCards() {		
		return this.Cards;	
	}	
	
	public int size() {
		return this.Cards.size();
	}
	
	public boolean isEmpty() {
		return this.Cards.isEmpty();
	}
	
	public int countPrimeira() {
		int [] primeira = {0,0,0,0};
		String [] naipes = {"swords","cups","clubs","coins"};
		for (Card c:this.Cards) 
			for (int j=0; j<naipes.length;j++)
				if (c.getNaipe().equals(naipes[j]) 	&& 
					c.getNumber()<10		   		&&
					primeira[j]<c.getNumber()) 
					primeira[j]=c.getNumber(); 
		for (int j = 1; j<4;j++)
			primeira[0]+=primeira[j];
		return primeira[0];
	}
	public int pointsForBelo() {
		return this.Cards.contains(new Card("coins", 7, true))?1:0;
	}
	public int pointsForCards() {
		return (this.Cards.size()>20)?1:0;
	}
	public int pointsForCoins() {
		int sum = 0;
		for (Card c:this.Cards)
			sum += c.getNaipe().equals("coins")?1:0;
		return (sum>5)?1:0;
	}
	
	
	
}
