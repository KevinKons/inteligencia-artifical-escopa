package model;
import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.Random;

import javax.imageio.ImageIO;
import javax.swing.ImageIcon;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.border.LineBorder;

public class ViewCards extends JPanel 
{
		private int LINES;
		private int COLUMNS;
		private int CARDHEIGHT;
		private int CARDWIDTH;
		private int BORDERSIZE;
		private String CARDPICSPATH;
		private Color TABLEBACKGROUNDCOLOR;
		private Color HIGHLIGHTCARDCOLOR; 
		private Color LOWLIGHTCARDCOLOR;					
		private JLabel [][] map;
			
		public ViewCards(int LINES, int COLUMNS, int CARDHEIGHT, int BORDERSIZE,
						 String CARDPICSPATH,
				         Color TABLEBACKGROUNDCOLOR, Color HIGHLIGHTCARDCOLOR, 
				         Color LOWLIGHTCARDCOLOR) {
			this.LINES=LINES;
			this.COLUMNS=COLUMNS;
			this.CARDHEIGHT=CARDHEIGHT;
			this.BORDERSIZE=BORDERSIZE;
			this.CARDWIDTH=(int) Math.ceil(1192*CARDHEIGHT/1944);
			this.CARDPICSPATH=CARDPICSPATH;
			this.TABLEBACKGROUNDCOLOR= TABLEBACKGROUNDCOLOR;
			this.HIGHLIGHTCARDCOLOR= HIGHLIGHTCARDCOLOR; 
			this.LOWLIGHTCARDCOLOR= LOWLIGHTCARDCOLOR;					
			this.map = new JLabel [LINES][COLUMNS];
			
			setLayout(new GridBagLayout());
			setBackground(TABLEBACKGROUNDCOLOR);
			this.build();
		}	
		
		public void showMessage(String msg, int time) {
			int l=Math.floorDiv(this.LINES, 3);
			int c=Math.floorDiv(this.COLUMNS, 2);
			this.map[l][c].setFont(new Font(Font.MONOSPACED, Font.BOLD, 80));
			this.map[l][c].setOpaque(true);
			for (int i=0; i<30; i++) {
				this.map[l][c].setIcon(null);
				this.map[l][c].setBackground(
						new Color((int)(Math.random()*255),
								  (int)(Math.random()*255),
								  (int)(Math.random()*255))
						);
				this.map[l][c].setBorder(
						new LineBorder(new Color((int)(Math.random()*255),
								  				 (int)(Math.random()*255),
								  				 (int)(Math.random()*255)), 
								  	    this.BORDERSIZE, true));
				this.map[l][c].setText(msg);
				this.map[l][c].repaint();
				try {
					Thread.sleep(time/50);
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
			this.map[l][c].setOpaque(false);
			this.map[l][c].setBackground(this.TABLEBACKGROUNDCOLOR);
			this.map[l][c].setText("");
			this.map[l][c].setIcon(new ImageIcon(emptyImage(CARDWIDTH, CARDHEIGHT)));
			this.map[l][c].setBorder(
					new LineBorder(this.TABLEBACKGROUNDCOLOR, 
							  	    this.BORDERSIZE, true));
			this.map[l][c].repaint();
			
		}
		
		public void showMessage(String msg) {
			int l=Math.floorDiv(this.LINES, 3);
			int c=Math.floorDiv(this.COLUMNS, 2);
			this.map[l][c].setFont(new Font(Font.MONOSPACED, Font.BOLD, 80));
			this.map[l][c].setIcon(null);			
			this.map[l][c].setText(msg);
		}
		
		public void funnyEnd(int time) {
			while (true) {
				String [] naipes = {"swords","clubs","coins","cups"};
				for (int l=0;l<this.map.length;l++)
					for (int c=0;c<this.map[0].length;c++) {
						int n= (int) Math.floor(Math.random()*4);
						int number=8;
						while (number ==8 || number==9) {
							number=(int) Math.ceil(Math.random()*12);
						}
						ImageIcon icon = new ImageIcon(getCardImage(naipes[n], number));
						this.map[l][c].setIcon(icon);
						
						
//						this.map[l][c].setOpaque(true);
//												
//						this.map[l][c].setBackground(
//								new Color((int)(Math.random()*255),
//										  (int)(Math.random()*255),
//										  (int)(Math.random()*255))
//								);
						this.map[l][c].setBorder(
								new LineBorder(new Color((int)(Math.random()*255),
										  				 (int)(Math.random()*255),
										  				 (int)(Math.random()*255)), 
										  	    this.BORDERSIZE, true));
						this.map[l][c].repaint();
						try {
							Thread.sleep(time);
						} catch (InterruptedException e) {
							e.printStackTrace();
						}
					}
			}
		}
		
		public void hideMessage(String msg) {
			int l=Math.floorDiv(this.LINES, 3);
			int c=Math.floorDiv(this.COLUMNS, 2);
			this.map[l][c].setIcon(new ImageIcon(emptyImage(CARDWIDTH,CARDHEIGHT)));
			this.map[l][c].setText("");
		}
		
		public void putCard(String naipe, int number) {
			for (int i=0;i<LINES;i++) {
				for (int j=0;j<COLUMNS;j++) {
					if (this.map[i][j].getName().equals("")) {
						ImageIcon icon = new ImageIcon(getCardImage(naipe, number));
						this.map[i][j].setIcon(icon);
						this.map[i][j].setName(naipe+"-"+String.valueOf(number));
						this.map[i][j].setBorder (new LineBorder(LOWLIGHTCARDCOLOR, this.BORDERSIZE, true));
						this.map[i][j].repaint();
						return;
					}
				}
			}
		}
		public void removeAllCards() {
			for (int i=0;i<this.map.length;i++)
				for (int j=0;j<this.map[0].length;j++) {
					ImageIcon icon = new ImageIcon(emptyImage(CARDWIDTH, CARDHEIGHT));
					this.map[i][j].setIcon(icon);
					this.map[i][j].setName("");
					this.map[i][j].setBorder (
							new LineBorder(TABLEBACKGROUNDCOLOR, this.BORDERSIZE, true));
					this.map[i][j].repaint();
				}
		}
		
		public void removeCard(String naipe, int number) {
			JLabel tmp = findCard(naipe, number); 
			ImageIcon icon = new ImageIcon(emptyImage(CARDWIDTH, CARDHEIGHT));
			tmp.setIcon(icon);
			tmp.setName("");
			tmp.setBorder (new LineBorder(TABLEBACKGROUNDCOLOR, this.BORDERSIZE, true));
			tmp.repaint();
		}
		
		public void highlightCard(String naipe, int number) {
			JLabel tmp = findCard(naipe, number); 
			tmp.setBorder (new LineBorder(HIGHLIGHTCARDCOLOR, this.BORDERSIZE, true));
			tmp.repaint();
		}

		public void lowlightCard(String naipe, int number) {
			JLabel tmp = findCard(naipe, number); 
			tmp.setBorder (new LineBorder(LOWLIGHTCARDCOLOR, this.BORDERSIZE, true));
			tmp.repaint();
		}
		
		private JLabel findCard(String naipe, int number) {
			for (int i=0;i<LINES;i++) 
				for (int j=0;j<COLUMNS;j++) 
					if (this.map[i][j].getName().equals(naipe+"-"+String.valueOf(number))) 
						return this.map[i][j]; 
			return null;
		}
		
		private void build(){					
			GridBagConstraints c = new GridBagConstraints();

			for (int i=0;i<LINES*2;i+=2) {
				for (int j=0;j<COLUMNS*2;j+=2) {
					JLabel tmp = new JLabel("");
					tmp.setName("");
					tmp.setIcon(new ImageIcon(emptyImage(CARDWIDTH,CARDHEIGHT)));
					tmp.setBorder (new LineBorder(TABLEBACKGROUNDCOLOR, this.BORDERSIZE, true));
					c.gridx=j;
					c.gridy=i;
					this.add(tmp,c);
					this.map[i/2][j/2]=tmp;
					
					JLabel tmp2 = new JLabel(" ");
					c.gridx=j+1;
					c.gridy=i+1;
					this.add(tmp2,c);
					
				}
			}
		}
		private BufferedImage emptyImage(int width, int height) {
	        BufferedImage bi = new BufferedImage( width, height, 
	        								BufferedImage.TYPE_INT_ARGB);
	        Graphics g = bi.getGraphics();	        
	        g.dispose();
	        return bi;
	    }
		private BufferedImage getCardImage(String naipe, int number) {
			BufferedImage bi= new BufferedImage(
	                CARDWIDTH, 
	                CARDHEIGHT, 
	                BufferedImage.TYPE_INT_ARGB);
			Graphics g = bi.getGraphics();
			try {
				g.drawImage(ImageIO.read(new File (CARDPICSPATH+naipe+
											  String.valueOf(number)+".jpg")).
						getScaledInstance(CARDWIDTH, CARDHEIGHT, Image.SCALE_SMOOTH),
						0, 0, null);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	        g.dispose();
	        return bi;
	    }

		
		
}