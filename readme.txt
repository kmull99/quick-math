This is a timesheet generator I created to help my cousin
practice her math. It generates 20 random questions & reports
your score & time spent, & prints out any questions you got wrong.

There are two versions: console_math.rb, which only prints to the console,
& quick_math.rb, which uses ruby2d to make a graphical quiz. The
quick_math.rb version ocasionally displays duplicate choices. If duplicate
correct choices are displayed, then any correct choice can be entered.

Quick Math Controls:
  - Mouse:  Click buttons
  - Esc:    Quit (does not print results)
  - Enter:  Hits submit button

Console Math Controls:
  Type the answer & press enter. Numbers with leading zeros will
  be counted as wrong.

Setup:
  - Install ruby for your system
  - Install ruby2d & it's dependencies
    - https://www.ruby2d.com/learn/get-started/
  - Run bundle to install other dependencies
  - Start the game by running quick_math.rb or console_math.rb
    in the console.
    - ruby quick_math.rb
    - ruby console_math.rb

TODO:
  - Improve final results printout.
  - Select operations at start of quiz.
    ~ The Question class supports +, -, *, /, and &, but both quizzes
      only use + and -.
  - Select range of operands at start of quiz.
  - Set number of questions at start of quiz.
  - Play again.
  - High score.
  - Difficulty selection
    ~ Overall time limit
    ~ Per question time limit

This game is currently developed in Ruby 3.4.7. Other versions may or may not work.
