This is a timesheet generator I created to help my cousin
practice her math. It generates 20 random questions, reports
your score & time spent, & prints out any questions you got wrong.

There are three versions: console_math.rb, which only prints to the console,
choice_math.rb, which uses ruby2d to make a multiple choice quiz, &
type_math.rb, which uses ruby2d but makes you type the answer. The
choice_math.rb version ocasionally displays duplicate choices. If duplicate
correct choices are displayed, then any correct choice can be entered.

Choice Math Controls:
  - Mouse:  Click buttons
  - Esc:    Quit (does not print results)
  - Enter:  Hits submit button

Type Math Controls:
  - Mouse:  Click buttons
  - Esc:    Quit (does not print results)
  - Enter:  Hits submit button
  - Type the answer & either hit enter or click submit. Numbers
    with leading zeros will be counted as wrong.

Console Math Controls:
  Type the answer & press enter. Numbers with leading zeros will
  be counted as wrong.

Setting the Operators:
  - All games have support for +, -, *, /, and %, but default to using
    using + and -. Change the by supplying a command line argument 
    ( e.g. ruby type_math.rb "+-*/%" ). 
      - Note: The quotation marks are required because the operations are
        special characters in most operation systems.

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
  - Print final results in ruby2d window instead of console.
  - Select operations at start of quiz Using in-game controls.
    ~ All quizzes default to only + and -. You can change the operations
      by supplying a command line argument. ( e.g. ruby type_math.rb "+-*/%" )
  - Select range of operands at start of quiz.
  - Set number of questions at start of quiz.
  - Move play again screen from console to ruby2d window.
  - High score.
  - Difficulty selection
    ~ Overall time limit
    ~ Per question time limit

This game is currently developed in Ruby 3.4.8. Other versions may or may not work.
