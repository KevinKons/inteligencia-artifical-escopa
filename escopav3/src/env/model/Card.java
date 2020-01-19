package model;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Literal;
import jason.asSyntax.parser.ParseException;

public class Card {
	private int number, value;
	private String naipe;
	public Card(String naipe, int number, int value) {
		this.naipe=naipe;
		this.number=number;
		this.value=value;
	}
	public Card(String naipe, int number, boolean escopa) {
		this.naipe=naipe;
		this.number=number;
		if (escopa & number>9) {
			this.value=number-2; } 
		else {
			this.value=number; }
	}
	
	public Card(String card, boolean escopa) {
		this.naipe= card.substring(5, card.indexOf(","));
		this.number= Integer.parseInt(card.substring(card.indexOf(",")+1,card.length()-1));
		if (escopa & number>9) {
			this.value=number-2; } 
		else {
			this.value=number; }
	}
	
		
	public int getValue() {
		return this.value;
	}
	
	public String getNaipe() {
		return this.naipe;
	}
	
	public int getNumber() {
		return this.number;
	}
	
	public Literal getLiteralCard() {
		try {
			return ASSyntax.parseLiteral("card("+this.naipe+","+this.number+")");
		} catch (ParseException e) {
			e.printStackTrace();
			return null;
		}
	}
	@Override
	public Card clone() {
		return new Card(this.naipe, this.number, true);
	}
	
	@Override
	public boolean equals(Object o) {
		return (this.naipe.equals(((Card)o).getNaipe()) && 
				this.number==((Card)o).getNumber());
	}
}
