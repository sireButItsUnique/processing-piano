public class Key { 
	int octave;
	int note; // note in letter form = 'A' + note
	boolean sharp;
	
	int blackNeutral = 50;
	int blackPressed = 0;
	int whiteNeutral = 240;
	int whitePressed = 180;

	int keyWidth = 75;
	int keyHeight = 300;

	public Key(int note, boolean sharp) {
		this.octave = note / 7;
        this.note = note % 7;
		this.sharp = sharp;
	}

	public boolean isMouseOver(int pos, boolean blackOnLeft, boolean blackOnRight) {
		
		// check for black keys
		if (this.sharp) {
			float startX = keyWidth * pos + (keyWidth - (0.3 * keyWidth));
			float endX = startX + (0.6 * keyWidth);
			return (mouseX > startX && mouseX < endX && mouseY < (0.8 * keyHeight));
		} 
		
		// check for white keys
		else {
			int startX = keyWidth * pos;
			int endX = startX + keyWidth;
			if (mouseX > startX && mouseX < endX && mouseY < keyHeight) {
				if (blackOnLeft && mouseY < (0.8 * keyHeight)) {
					if (mouseX < startX + (0.3 * keyWidth)) {
						return false;
					}
				}
				if (blackOnRight && mouseY < (0.8 * keyHeight)) {
					if (mouseX > endX - (0.3 * keyWidth)) {
						return false;
					}
				}
				return true;
			}
			return false;
		}
	} 

	public void render(int pos, boolean blackOnLeft, boolean blackOnRight) {

		// render black key
 		if (this.sharp) {
			fill(this.blackNeutral);

			// highlight if hovered
			float startX = keyWidth * pos + (keyWidth - (0.3 * keyWidth));
			if (this.isMouseOver(pos, blackOnLeft, blackOnRight)) {
				fill(87, 108, 115);
				if (mousePressed) {
					fill(this.blackPressed);
				}
			}

			rect(startX, 0, (0.6 * keyWidth), (0.8 * keyHeight));
			if (this.isMouseOver(pos, blackOnLeft, blackOnRight)) {
				fill(255);
				textSize(25);
				text((char)('A' + this.note) + "#", startX + (0.3 * keyWidth), (0.8 * keyHeight) - 20); // char is just int mapped to ascii
			}
		} 
		
		// render white key
		else {
			fill(this.whiteNeutral);

			// highlight if hovered
			int startX = keyWidth * pos;
			if (this.isMouseOver(pos, blackOnLeft, blackOnRight)) {
				fill(173, 216, 230);
				if (mousePressed) {
					fill(this.whitePressed);
				}
			}

			rect(startX, 0, keyWidth, keyHeight);
			if (this.isMouseOver(pos, blackOnLeft, blackOnRight)) {
				fill(0);
				textSize(40);
				text((char)('A' + this.note), startX + (0.5 * keyWidth), keyHeight - 20); // char is just int mapped to ascii
			}
		}
		
	}
}

public class Piano {
	Key[] keys;

	public Piano(int numKeys) {
		keys = new Key[numKeys];
		int note = 2;
		for (int i = 0; i < numKeys; i++) {

			// add the white key
			keys[i] = new Key(note, false);

			// only add black key if theres room and if not b or e
			if (note % 7 != 1 && note % 7 != 4 && (i + 1) < numKeys) {
				i++;
				keys[i] = new Key(note, true);
			}
			note++;
		}
	}

	public void render() {

		// rendering the white keys
		stroke(255);
		strokeWeight(1);
		int pos = 0;
		for (int i = 0; i < this.keys.length; i++) {
			if (!this.keys[i].sharp) {

				// prevents from trying to access out of bounds in array
				boolean blackOnLeft = (i != 0) ? this.keys[i - 1].sharp : false;
				boolean blackOnRight = (i + 1 < this.keys.length) ? this.keys[i + 1].sharp : false;

				// render the white key
				keys[i].render(pos, blackOnLeft, blackOnRight);
				pos++;
			}
		}

		// reset pos for rendering the black keys
		pos = -1;
		for (int i = 0; i < this.keys.length; i++) {

			// render the black key
			if (this.keys[i].sharp) {
				keys[i].render(pos, false, false);
			} else {
				pos++;
			}
		}
	}
}

class Staff {
	int startY = 410;
	int startX = 20;
	int barHeight = 20;
	int noteMargin = 50;
	int startingOctave;

	Key[] notes = {new Key(4, false), new Key(5, false), new Key(6, false)};

	public Staff(int startingOctave) {
		this.startingOctave = startingOctave;
	}

	public void addNote(Key newNote) {
		this.notes = (Key[])append(this.notes, newNote);
		int maxNotes = floor((1800 - startX) / noteMargin);
		print(max(0, this.notes.length - maxNotes) + "->" + this.notes.length + "\n");
	}

	public void render() {

		// draw staff
		stroke(255);
		strokeWeight(2);
		line(startX, startY, startX, startY + 4 * barHeight);
		line(startX + 15, startY, startX + 15, startY + 4 * barHeight);
		for (int i = 0; i < 5; i++) {
			line(startX, startY + i * barHeight, 1800, startY + i * barHeight);
		}
		
		// draw notes
		int maxNotes = floor((1800 - startX) / noteMargin);
		for (int i = max(0, this.notes.length - maxNotes); i < this.notes.length; i++) { // only draw last maxNotes notes
			Key note = this.notes[i]; 

			// octave offset is height of one octave * (startingOctave - note.octave)
			int octaveOffset = (7 * (barHeight / 2)) * (startingOctave - note.octave);
			int y = startY + (4 * barHeight) - (barHeight / 2) * (note.note - 4) + octaveOffset;
			int x = startX + noteMargin * (i - max(0, this.notes.length - maxNotes)) + 40;

			// draw the line under the note if necassary
			stroke(255);
			strokeWeight(2);

			// low note
			for (int lineHeight = startY + (5 * barHeight); lineHeight <= y; lineHeight += barHeight) {
				line(x - 15, lineHeight, x + 15, lineHeight);
			} 

			// high note
			for (int lineHeight = startY - barHeight; lineHeight >= y; lineHeight -= barHeight) {
				line(x - 15, lineHeight, x + 15, lineHeight);
			}

			// draw the measure line if necassary
			if ((i + 1) % 4 == 0) {
				line(x + noteMargin / 2, startY, x + noteMargin / 2, startY + 4 * barHeight);
			}

			// draw settings
			fill(0);
			stroke(0);
			strokeWeight(3);
			strokeCap(SQUARE);

			// draw the note
			ellipse(x, y, 20, 10);
			if (y > startY + 2 * barHeight) {
				line(x + 10, y, x + 10, y - 40);
			} else {
				line(x - 10, y, x - 10, y + 40);
			}
			
			if (note.sharp) {
				textSize(35);
				text("#", x + 20, y + 10);
			}
		} 
	}
}

Piano piano = new Piano(41);
Staff staff = new Staff(1);

void setup() {
	size(1800, 600);
	stroke(255);
	rectMode(CORNER);
	background(69);
	textAlign(CENTER);
}

void draw() {
	background(69);
	piano.render();
	staff.render();
}

void mouseClicked() {
	int pos = 0;
	for (int i = 0; i < piano.keys.length; i++) {
		if (!piano.keys[i].sharp) {

			// prevents from trying to access out of bounds in array
			boolean blackOnLeft = (i != 0) ? piano.keys[i - 1].sharp : false;
			boolean blackOnRight = (i + 1 < piano.keys.length) ? piano.keys[i + 1].sharp : false;

			// try registering the key
			if (piano.keys[i].isMouseOver(pos, blackOnLeft, blackOnRight)) {
				staff.addNote(piano.keys[i]);
				break;
			} 
			pos++;
		} else {
			if (piano.keys[i].isMouseOver(pos - 1, false, false)) {
				staff.addNote(piano.keys[i]);
				break;
			}
		}
	}
}