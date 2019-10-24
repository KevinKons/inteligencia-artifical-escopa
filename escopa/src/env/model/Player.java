package model;
import cartago.AgentId;
import fails.CardNotFounded;

public class Player {
	private CardCollection hand = new CardCollection("hand");
	private CardCollection collectedCards = new CardCollection("collected cards");
	private AgentId id;
	
	public Player(AgentId id) {
		this.id=id;
	}
	
	public String getAgName() {
		return this.id.getAgentName();		
	}
	
	public AgentId getAgId() {
		return this.id;		
	}
	
	public void receiveHandCard(Card c) {
		this.hand.receive(c);	
	}
	
	public void dropHandCard(Card c)  throws CardNotFounded{
		this.hand.drop(c);	
	}
	
	public boolean hasCard(Card c)  {
		return this.hand.check(c);	
	}
	
	public boolean isHandEmpty()  {
		return this.hand.isEmpty();	
	}
	
	public CardCollection getHand() {
		return this.hand;
	}
	
	public void receiveCollectedCard(Card c) {
		this.collectedCards.receive(c);	
	}
	
	public void dropCollectedCard(Card c)  throws CardNotFounded{
		this.collectedCards.drop(c);	
	}
	
	public void clearCollectedCard() {
		this.collectedCards= new CardCollection("collected cards");	
	}
	
	public int deckPoints() {
		return this.collectedCards.pointsForBelo()  +
			   this.collectedCards.pointsForCards() +
			   this.collectedCards.pointsForCoins();
	}
	public int countPrimeira() {
		return this.collectedCards.countPrimeira();
	}

}
