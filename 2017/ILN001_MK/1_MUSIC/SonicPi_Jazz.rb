#pianoBot v0.05b
# so what if your sonic pi sat down at a piano
# and started noodling around?


#genre = 'default' #don't really need to uncomment this
genre = 'jazz'  #uncomment to play smoooth jazz
#genre = 'ambient'  #uncomment to play ambient
#genre = 'test'  #uncomment to play newage


#global defaults
set_volume!5
use_random_seed 10
use_bpm 100

breathlimit = 0 #how long to "rest" between chords (expression!)
chordTimeLimit = 2.0 #how long each chord lasts, must be float
chordTime_step = 2.0 #allow odd/even increments in chord times

rightHandPlayPercent = 50 #how often the right hand bothers to play
playstyle = "adlib" #adlib = random | progression = sequential chords
mod_cutoff = 130


#global FX defaults
echomix = 0
verbroom = 0



case genre
when 'jazz'
  puts "LETS PLAY SOME JAZZ"
  use_bpm = 60
  chordTime_limit = 6.0
  chordTime_step = 1.0
  breathlimit = 2 #maximum beats to rest between bars
  rightHandPlayPercent = 75
  
  use_random_seed 19
  
  verbroom = 0.85
  mod_cutoff = 85
  
  chords = [
    chord(:c, :major7),
    chord(:a, :minor7),
    chord(:d, :minor7),
    chord(:e, :minor7),
    chord(:g, '7'),
  ]
  playstyle = "adlib"
  
when 'ambient'
  puts "LETS PLAY SOME NewAge"
  use_bpm = 10
  chordTime_limit = 2.0 #max time a chord can last
  breathlimit = 8 #maximum beats to rest between bars
  
  use_random_seed 12
  echomix = 0.2
  verbroom = 1
  mod_cutoff = 80
  chords = [
    chord(:e, :major),
    chord(:a, :major),
    chord(:ab, :minor),
    chord(:b, :major),
    
  ]
  playstyle = "progression"
  
when 'test'
  puts "LETS PLAY SOME TEST"
  use_random_seed 11 #some seeds sound better than others
  use_bpm = 60 #tempo
  chordTime_limit = 2.0 #rrand(2.0, 8.0, step: 2.0) #how long should one chord last for
  breathlimit = 1 #maximum beats to rest between bars
  rightHandPlayPercent = 70
  
  mod_cutoff = 130
  
  chords = [
    chord(:d, :minor7),
    chord(:g, '7'),
    chord(:c, :major7),
    chord(:f, :major7),
    chord(:b, :minor7),
    chord(:e, '7'),
    chord(:a, :minor7),
  ]
  playstyle = "progression" #playstyle adlib|progression
  
else
  puts "LETS PLAY SOMETHING BASIC"
  
  use_random_seed 10  #decent tune
  use_bpm = 200 #play fastish
  chordTime_limit = rrand(4.0, 4.0, step: 2.0) #all the same bar length
  breathlimit = 1 #maximum beats to rest between bars
  
  echomix = 0.0  #how much echo mix?
  verbroom = 0.0 #how much room in the verb?
  mod_cutoff = 130 #how bright is the tone of the synth?
  
  chords = [
    chord(:e, :major),
    chord(:b, :major),
    chord(:db, :minor),
    chord(:a, :major),
  ]
  playstyle = "adlib"
end

#gear up to play something!

globalbreath = 0 #don't breathe before playing
chordTime = rrand(2.0, chordTime_limit, step: 2.0)
if playstyle == "progression"
  ticktracker = 0
  curchord = chords[ticktracker]
else
  curchord = choose(chords) #prime the first chord
end

#set up the FX
with_fx(:echo, mix: echomix, phase: 0.5, decay: 5 ) do |echo1|
  with_fx(:echo, mix: echomix, phase: 0.25, decay: 8 ) do |echo2|
    with_fx(:reverb, room: verbroom, damp: 1) do |reverb1|
      
      #LETS GO!
      live_loop :lefty do
        use_synth :piano
        sleep globalbreath
        puts "playing left-handed "+genre+"after taking a breath for "+globalbreath.to_s+" beats"
        
        leftyNoteCount = rrand_i(2, chordTime)
        sleepytime = leftyNoteCount/chordTime #calculate sleep between notes
        
        puts "sleeping left hand for "+sleepytime.to_s
        
        leftyNoteCount.times do
          lefttrans = rrand(-24,-12,step: 12)
          use_transpose lefttrans
          leftnorc = rrand(0,100, step: 1)
          if leftnorc > 50
            play curchord, release: chordTime, pan: rrand(-1,0,step: 0.25), pan_slide: 0.5, amp: 1, cutoff: mod_cutoff
          else
            play choose(curchord), pan: rrand(-1,0,step: 0.25), pan_slide: 0.5, amp: 1, cutoff: mod_cutoff
          end
          sleep sleepytime
          
        end
        
        #gear up for chord change
        #left hand dicatates new chords and breathing
        chordTime = rrand(2.0, chordTime_limit, step: chordTime_step) #get new chord time limit
        if playstyle == "progression"
          if ticktracker >= (chords.length - 1)
            ticktracker = 0
          else
            ticktracker += 1
          end
          curchord = chords[ticktracker]  #get the next chord
          puts "playing chord at index: "+ticktracker.to_s
        else
          curchord = choose(chords) #randomly choose a new chord
        end
        globalbreath = rrand_i(0,breathlimit) #how long should we breath for between bars?
      end
      
      live_loop :righty do
        puts "playing right-handed "+genre+"after taking a breath for "+globalbreath.to_s+" beats"
        sleep globalbreath
        rightynotecount = chordTime * rrand_i(1,2)  #the idea here is that sometimes the right hand plays twice the notes than the left
        sleepytime = rightynotecount/(chordTime*rightynotecount) # notecount / (8*2) = 8/16 - 0.5?
        puts "sleeping right hand for "+sleepytime.to_s
        use_synth :piano
        
        righttrans = rrand(0,24,step: 12)
        use_transpose righttrans
        
        rightynotecount.times do
          
          rightmaybeplay = rrand_i(0,100) #half the time, the right hand might not even play!
          if rightmaybeplay < rightHandPlayPercent
            rightnorc = rrand_i(0,100)
            if rightnorc < 10
              play curchord, pan: rrand(0,1,step: 0.25), pan_slide: 0.5, amp: 1, cutoff: mod_cutoff
            else
              play choose(curchord), pan: rrand(0,1,step: 0.25), pan_slide: 0.5, amp: 1, cutoff: mod_cutoff
            end
          end
          sleep sleepytime
        end
        
      end
    end
  end
end