package model;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;

import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;

public class View extends JFrame 
{
		private ViewCards table = 	   new ViewCards(2		, 7, 
													 150	, 5,
													 "cardpics/", 
													 new Color(79,199,120),
													 Color.RED,
													 Color.WHITE);
		private ViewCards [] hands = { new ViewCards(	1	, 3, 
														120	, 5, 
														"cardpics/", 
														new Color(79,199,120),
														Color.RED,	
														Color.WHITE),
									   new ViewCards(	1	, 3, 
											   			120	, 5,
											   			"cardpics/", 
											   			new Color(79,199,120),
											   			Color.RED,	
											   			Color.WHITE)};		
		private JLabel score = new JLabel("                                ");
		
		public View() {						
			setTitle("viewer");
			setPreferredSize(new Dimension(1200,800));					
			setLayout(new BorderLayout());
			
			JPanel jp = new JPanel(new BorderLayout());
			jp.add(this.hands[0], BorderLayout.NORTH);			
			jp.add(this.table, BorderLayout.CENTER);
			jp.add(this.hands[1], BorderLayout.SOUTH);
			
			this.score.setFont(new Font(Font.MONOSPACED, Font.BOLD, 32));
						
			add(jp, BorderLayout.CENTER);
			add(this.score, BorderLayout.SOUTH);
			
			setVisible(true);
		    pack();
	        setLocation(0, 0);   		    		    			
		}		
		public void showMessage(String msg, int time) {
			this.table.showMessage(msg, time);
		}
		public void showWinner(int ag, String msg) {
			if (ag==-1) {
				for (int i=0;i<this.hands.length;i++)
					this.hands[i].showMessage("D R A W");				
			}
			else {
				this.hands[ag].showMessage(msg+" W I N S");
			}
			this.table.funnyEnd(15);
		}
		
		public void clearTable() {
			this.table.removeAllCards();
		}
		
		public void putCard(String naipe, int number) {
			this.table.putCard(naipe, number);
		}
		public void removeCard(String naipe, int number) {
			this.table.lowlightCard(naipe, number);
			this.table.removeCard(naipe, number);
		}
		public void highlightCard(String naipe, int number) {
			this.table.highlightCard(naipe, number);			
		}
		public void lowlightCard(String naipe, int number) {
			this.table.lowlightCard(naipe, number);
		}		
		public void addHandCard(int player, String naipe, int number) {
			this.hands[player].putCard(naipe, number);
		}
		public void removeHandCard(int player, String naipe, int number) {
			this.hands[player].lowlightCard(naipe, number);
			this.hands[player].removeCard(naipe, number);
		}
		public void highlightHandCard(int player, String naipe, int number) {
			this.hands[player].highlightCard(naipe, number);			
		}
		public void lowlighthandCard(int player, String naipe, int number) {
			this.hands[player].lowlightCard(naipe, number);
		}
		public void setScore(String player1, String player2, int scoreP1, int scoreP2) {
			this.score.setText(player1+" - "+scoreP1+"       "+ player2+" - "+scoreP2);
		}
		
}