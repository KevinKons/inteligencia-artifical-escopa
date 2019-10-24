package model;
import java.util.ArrayList;

import cartago.AgentId;
import cartago.OPERATION;
import fails.CardNotFounded;
import fails.CollectException;
import fails.DropException;

public class Match {
	private int handlerPlayers = 0;
	private Player [] players = new Player[2];
	private int [] score = new int [2];
	private int matchRound=0;
	private int lastVaza=0;
	private Deck deck = new Deck();
	private CardCollection cardsOnTable = new CardCollection("table");
	
	public boolean join(AgentId ag) {
		this.players[this.handlerPlayers]= new Player(ag);
		this.handlerPlayers++;
		return this.handlerPlayers==2;
	}
	
	public void beginMatch() {
		//initiate collected cards
		for (int i=0; i<2; i++)
			this.players[i].clearCollectedCard();	
		//initiate deck
		this.deck =new Deck();
		//initial message
		this.matchRound++;
		try {
			//initiate table
			for (int j=0; j<4; j++) {
				cardsOnTable.receive(this.deck.popCard());			
			}	
		}
		catch (Exception e) { e.printStackTrace(); }
		// Random player start
		this.handlerPlayers=((int) Math.round(Math.random()));
	}
	
	public boolean isEndMatch() {
		if (this.players[0].isHandEmpty() && 
			this.players[1].isHandEmpty() &&
			this.deck.isEmpty()) {
			
			//collect lasts table cards
			while(!this.cardsOnTable.isEmpty()) {
				Card c = this.cardsOnTable.dropByindex(0);
				this.players[this.lastVaza].receiveCollectedCard(c);
			}					
			for (int i=0; i<2; i++) 
				this.score[i]+=this.players[i].deckPoints();
	
			this.score[0]+=(this.players[0].countPrimeira()>
							this.players[1].countPrimeira())?1:0;
			this.score[1]+=(this.players[1].countPrimeira()>
							this.players[0].countPrimeira())?1:0;
			return true;	
			
		}
		else return false;
	}
			
	public void dropcard(String Agent, Card c) throws DropException, CardNotFounded {
		if (!this.players[this.handlerPlayers].getAgName().equals(Agent)) {
			throw new DropException("wait your turn!");	
		}
		else {
			this.players[this.handlerPlayers].dropHandCard(c);
			this.cardsOnTable.receive(c);
		}				
	}
	
	public boolean collectcard(String Agent, Card hCard, Card[] tCards) throws CollectException, CardNotFounded {
		if (!this.players[this.handlerPlayers].getAgName().equals(Agent)) {
			throw new CollectException("wait your turn!");	
		}
		else {
			
			if (!this.players[this.handlerPlayers].hasCard(hCard)) {
				throw new CollectException("you do not have the card");	
			}
			else {	
				int sum=hCard.getValue();		
				for (Card c:tCards) {
					if (this.cardsOnTable.check(c)) {
						sum+= c.getValue();
					}
					else {
						throw new CollectException("card "+c.getLiteralCard()+" not in the table");	
					}			
				}
				if (sum!=15) {
					throw new CollectException("the sum is different than 15");
				}										

				for (Card c:tCards) { 				
					this.cardsOnTable.drop(c);
					this.players[this.handlerPlayers].receiveCollectedCard(c);
				}
				this.players[this.handlerPlayers].dropHandCard(hCard);
				this.players[this.handlerPlayers].receiveCollectedCard(hCard);
				
				this.lastVaza=this.handlerPlayers;
				
				//check escoba
				if (this.cardsOnTable.isEmpty()) {
					this.score[this.handlerPlayers]++;
					return true;
				}				
				return false;
			}
		}
	}
	
	public void passTurn() {
		this.handlerPlayers= (this.handlerPlayers+1)%2;
	}
	
	public int [] getScore() {
		return this.score;
	}
	public String getPlayerName(int i) {
		return players[i].getAgName();
	}
	
	public ArrayList<Card> getPlayerHand(int i) throws CardNotFounded {
			return this.players[i].getHand().getCards();
	}
	
	public boolean isEmptyDeck() {
		return this.deck.isEmpty();
	}
	
	public boolean isHandEmptyPlayer(int i) {
		return this.players[i].isHandEmpty();
	}
	
	public ArrayList<Card> getTableCards(){
		return this.cardsOnTable.getCards();
	}
	
	public Card[] drawCard(int i) {
		Card [] tmp = new Card[3];
		for (int j=0; j<3; j++) {
			try {
				tmp[j]=this.deck.popCard();
				this.players[i].receiveHandCard(tmp[j]);
			} catch (CardNotFounded e) {
				e.printStackTrace();
			}
		}
		return tmp;
	}
	
	public int getCurrentPlayer() {
		return handlerPlayers;
	}
		
	public AgentId getCurrentPlayerId() {
		return this.players[this.handlerPlayers].getAgId();
	}
	
	public AgentId getCurrentPlayerId(int i) {
		return this.players[i].getAgId();
	}
	
	public Boolean hasWinner() {
		return this.score[0]>14 || this.score[1]>14; 
	}
	
	public String winner() {
		if (this.score[0]>14 && this.score[1]<15 ) 
			return this.players[0].getAgName();
		else if (this.score[1]>14 && this.score[0]<15 ) 
			return this.players[1].getAgName();
		else if (this.score[0]>14 && this.score[1]>14 ) 
			return "DRAW";
		else 
			return "NOT YET";
	}
	public int getMatchRound() {
		return this.matchRound;
	}
}
