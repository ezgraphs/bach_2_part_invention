library(sqldf)
library(ggplot2)

df=read.csv('bach2part8inF.txt',sep=';', header=TRUE)
df = df[,-1]

# Melody Lines
# Algorithm to split voices
# 1)  Identify number of simultaneous notes at the time each note occurs
df=sqldf('select df.Time, df.Pitch, df.Note, df.Octave, t2.simultaneous_notes from df join (select Time, count(*) simultaneous_notes from df group by Time) t2 on t2.Time = df.Time')

#) 2)  Find all of the notes that are the highest when more than one occurs at the same time, and combine them with
# the set of all notes that occur by themselves but are higher that the first note in the piece
upper=sqldf('select Time, max(Pitch) Pitch from df where simultaneous_notes >1 group by time 
             union 
             select time, Pitch from df where simultaneous_notes=1 and Pitch >= 65')

# 3)  Identify voice 1 (upper voice) and 2 (lower voice).  Note that this is not exactly accurate 
# for the last chord which has 4 simultaneous notes
df=sqldf('select df.*, "1" Voice from df where (Time + Pitch) in (select Time + Pitch from upper) 
 union select df.*, "2" Voice from df where (Time + Pitch) not in (select Time + Pitch from upper)')

octave_boundary=sqldf('select Octave + 1, max(Pitch) + 1 Pitch from df group by Octave having Octave < 6')

ggplot(data=df, aes(Time, Pitch, color=Note, group=Voice)) + 
geom_line() + 
geom_point() +
scale_x_continuous('Measure', breaks=seq(0,103000, 3072), labels=1:length(seq(0,103000, 3072))) +
scale_y_continuous("Octave", breaks=as.numeric(octave_boundary$Pitch), labels=octave_boundary$Octave) +
opts(title="Bach 2 Part Invention #8 in F Major (BWV779)")

ggsave('bach2part8inF.png')

# Note Frequency by Voice
ggplot(df, aes(Note, fill=factor(Voice))) + geom_bar() + opts(title="Note Frequency by Voice")
ggsave('bach2part8inFNoteFrequencyByVoice.png')

# Note Frequency by Octave
ggplot(df, aes(Note, fill=factor(Octave))) + geom_bar()+ opts(title="Note Frequency by Octave")
ggsave('bach2part8inFNoteFrequencyByOctave.png')

# Additional analysis could involve looking at intervals and chords
chords=sqldf("SELECT Time, group_concat(Note)chord , min(pitch) min_pitch FROM (SELECT * FROM df ORDER BY Time, Pitch) GROUP BY Time")
chords$first_note=sub(',.*$','', chords$chord)
