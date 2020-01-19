package model;
import cartago.*;
import fails.CardNotFounded;
import fails.CollectException;
import fails.DropException;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.parser.ParseException;

public class Escopa extends Artifact {
	int DELAY;
	View view;
	Match match;
	
	@OPERATION 
	void init (int delay){
		this.DELAY=delay;
		this.view = new View();
		this.match = new Match();
	}
	
	@OPERATION
	void join() {
		if (this.match.join(getCurrentOpAgentId())) {
				beginMatch();	
				this.view.setScore(	this.match.getPlayerName(0), 
			 			   			this.match.getPlayerName(1), 
			 			   			this.match.getScore()[0], 
			 			   			this.match.getScore()[1]);
				updatePlayerTurn();
		}
		
		
	}
		
	@OPERATION
	void dropcard(String naipe, int number) {
			Card c= new Card(naipe, number, true);			
			try {
				this.match.dropcard(getCurrentOpAgentId().getAgentName(), c);				
			} catch (DropException e1) {				
				failed("drop card failed","drop_card_failed",e1.getMessage());
			} catch (CardNotFounded e1) {
				failed("drop card failed","drop_card_failed",e1.getMessage());
			}

			this.view.removeHandCard(this.match.getCurrentPlayer(), naipe, number);	
			try {
				defineObsProperty("cardontable", 
								  ASSyntax.parseLiteral(c.getNaipe()), 
										  				c.getNumber()).commitChanges();
				commit();											 	
			}
			catch (Exception e) { e.printStackTrace(); }
			this.view.putCard(c.getNaipe(), c.getNumber());
			finalprocedures(); 
	}
	
	
	
	@OPERATION
	void collectcards(String card, Object[] cards) throws ParseException {
		
		Card [] tCards = new Card[cards.length];
		for (int i=0;i<cards.length;i++) 
			tCards[i]= new Card((String) cards[i], true);
		Card hCard = new Card(card, true);
		boolean escopa=false;
		try {
			escopa = this.match.collectcard(getCurrentOpAgentId().getAgentName(),
													hCard, 
													tCards);
		} catch (CollectException e1) {
			e1.printStackTrace();
			failed("collect cards failed","collect_cards_failed",e1.getMessage());
		} catch (CardNotFounded e1) {
			e1.printStackTrace();
			failed("collect cards failed","collect_cards_failed",e1.getMessage());
		}
		//highlight
		view.highlightHandCard(this.match.getCurrentPlayer(), 
							   hCard.getNaipe(), 
							   hCard.getNumber());
		for (Card c:tCards) {
			view.highlightCard(c.getNaipe(), c.getNumber());		
			await_time(this.DELAY);
		}						
		//remove
		for (Card c:tCards) {
			view.removeCard(c.getNaipe(), c.getNumber());
			try {				
				removeObsPropertyByTemplate("cardontable", 
							ASSyntax.parseLiteral(c.getNaipe()), 
							c.getNumber());				
				commit();
			}
			catch (Exception e) {
				e.printStackTrace();
			}
		}
			
		view.removeHandCard(this.match.getCurrentPlayer(),
							hCard.getNaipe(), hCard.getNumber());
		signal("cardusedtocollect", 
				ASSyntax.parseLiteral(this.match.getCurrentPlayerId().getAgentName()),
				ASSyntax.parseLiteral(hCard.getNaipe()), 
				hCard.getNumber());
		//check escova
		if (escopa) {
			this.view.showMessage(
							this.match.getPlayerName(this.match.getCurrentPlayer())
							+ " ESCOPA!!!", this.DELAY*3);
			this.view.setScore(this.match.getPlayerName(0), 
				 			   this.match.getPlayerName(1), 
				 			   this.match.getScore()[0], 
				 			   this.match.getScore()[1]);
		}
		finalprocedures();
	}
	
	private void finalprocedures() {
		if (!this.match.isEndMatch()) {
			if (this.match.isHandEmptyPlayer(this.match.getCurrentPlayer()) &&
				!this.match.isEmptyDeck()) {
				drawCards(this.match.getCurrentPlayer());
			}
			this.match.passTurn();
			updatePlayerTurn();
		}
		else {				
			view.setScore(this.match.getPlayerName(0), 
						  this.match.getPlayerName(1), 
					      this.match.getScore()[0], 
					      this.match.getScore()[1]);
			if (this.match.hasWinner()) {					
				this.view.showWinner(this.match.getCurrentPlayer(), 
								     this.match.winner());
			}
			else {
				beginMatch();
				this.match.passTurn();
				updatePlayerTurn();
			}
				
		}
	}
	private void beginMatch() {
		this.view.clearTable();
		while (hasObsProperty("cardontable")) {
			removeObsProperty("cardontable");
		}
		commit();
		
		view.setScore(this.match.getPlayerName(0), 
				  	  this.match.getPlayerName(1), 
			          this.match.getScore()[0], 
			          this.match.getScore()[1]);
		this.match.beginMatch();
		this.view.showMessage(this.match.getMatchRound()+" Round", this.DELAY*3);
		for (Card c:this.match.getTableCards())  {
			try {
				defineObsProperty("cardontable", 
								  ASSyntax.parseLiteral(c.getNaipe()), 
										  				c.getNumber()).commitChanges();
				commit();
				this.view.putCard(c.getNaipe(), c.getNumber());
			}
			catch (Exception e) { e.printStackTrace(); }
		}
		
		for (int i=0; i<2; i++)
			drawCards(i);
	}
	
	private void updatePlayerTurn() {
		if (hasObsProperty("playerturn")) 
			removeObsProperty("playerturn");		
		try {
			defineObsProperty("playerturn", 
							  ASSyntax.parseLiteral(
									  this.match.getPlayerName(
											  this.match.getCurrentPlayer()))).commitChanges();
			commit();
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}
	private void drawCards (int ag) {
		Card [] tmp = this.match.drawCard(ag);
		for (Card c:tmp) {
			signal(this.match.getCurrentPlayerId(ag), 
				   "hand", 
				   c.getLiteralCard());	
			this.view.addHandCard(ag, 
								  c.getNaipe(), 
								  c.getNumber());
		}
	}
}