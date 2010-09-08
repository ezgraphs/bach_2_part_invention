# Load required packages
$LOAD_PATH[0, 0] = File.join(File.dirname(__FILE__), '..', 'lib')
['rubygems', 'midilib/sequence'].each{|l|require l}

# Read in the midi file and extract the sequence of interest
seq = MIDI::Sequence.new()
File.open(file,'rb') {|file|seq.read(f'Bach2PartInvention8InF.MID')}
track=seq.entries[1]

# Output all of the ne "note on" midi events.
idx=0
puts "idx;Time;Pitch;Note;Octave"
track.each {|e| e.print_decimal_numbers = true 
  idx+=1
  if e.note_on?
    e.pch_oct=~/(.*)(\d)/ # Split out the note and the octave
    puts  "#{idx};#{e.time_from_start};#{e.note};#{$1};#{$2}"  rescue puts "==>"+$!
  end  
}