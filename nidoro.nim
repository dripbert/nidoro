import std/[os, strutils, terminal]

var study_time: string = "25m"
var break_time: string = "5m"
var iterations: int    = 5
var n_flag: bool       = false

const anim = ["·.", ".·"]


proc print_usage(): void =
  echo "Options:"
  echo "  -h, --help       print help"
  echo "  -s [n<h, m, s>]  set study time"
  echo "  -b [n<h, m, s>]  set break time"
  echo "  -i [n]           set number of iterations"
  echo "  -n               end the break on user input"
  quit(0)

proc is_number(str: string): bool =
  var t: bool = true
  for c in str:
    if not contains($c, Digits):
      t = false
  return t

proc resolve_flags(): void =
  var pass: bool = false
  for i in countup(1, param_count()):
    case param_str(i):
      of "-h":
        print_usage()
        return
      of "--help":
        print_usage()
        return
      of "-s":
        if param_count() < i+1:
          print_usage()
        study_time = param_str(i+1)
        pass = true
      of "-b":
        if param_count() < i+1:
          print_usage()
        break_time = param_str(i+1)
        pass = true
      of "-i":
        if param_count() < i+1:
          print_usage()
        if not is_number(param_str(i+1)):
          print_usage()
        iterations = parseInt(param_str(i+1))
        pass = true
      of "-n":
        n_flag = true
        pass = true
      else:
        if not pass:
          print_usage()
        pass = false

proc time_to_seconds(time: string): int =
  var seconds: int = 0

  if time[^1] == 's':
    seconds = parse_int(time[0..^2])
  elif time[^1] == 'm':
    seconds = 60 * parse_int(time[0..^2])
  elif time[^1] == 'h':
    seconds = 3600 * parse_int(time[0..^2])
  return seconds

proc time_to_biggest_unit(time: int): string =
  var out_time = "-1"
  if time <= 60:
    out_time = $ time & "s" 
  elif time > 60 and time < 3600:
    out_time = $ ((int)time/60) & "m"
  elif time > 3600:
    out_time = $ ((int)time/3600) & "h"
  return out_time

proc break_timer(time: int): void =
  if n_flag:
    stdout.write("BREAK(Press enter to continue)> ")
    discard readline(stdin)
    return
  for i in countdown(time-1, 0):
    stdout.write("BREAK" & anim[i mod 2])
    echo "> Time left: " & time_to_biggest_unit(i)
    sleep(1000)
    cursor_up 1
    erase_line()

proc study_timer(time: int): void =
  for i in countdown(time-1, 0):
    stdout.write("STUDY" & anim[i mod 2])
    echo "> Time left: " & time_to_biggest_unit(i)
    sleep(1000)
    cursor_up 1
    erase_line()
        

resolve_flags()

if not is_number(study_time[0..^2]) or not is_number(break_time[0..^2]):
  print_usage()

for n in countdown(iterations, 1):
  study_timer(time_to_seconds(study_time))
  if n != 1:
    break_timer(time_to_seconds(break_time))
