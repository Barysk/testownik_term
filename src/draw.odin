package tesuteru

import "core:fmt"
import "core:math/rand"
import "core:terminal/ansi"
import "core:strings"
import "core:time"

ANSI_I :: ansi.CSI + ansi.FG_CYAN + ansi.SGR    // info
ANSI_S :: ansi.CSI + ansi.FG_GREEN + ansi.SGR   // super
ANSI_W :: ansi.CSI + ansi.FG_YELLOW + ansi.SGR  // warning
ANSI_C :: ansi.CSI + ansi.FG_RED + ansi.SGR     // critical
ANSI_RST :: ansi.CSI + ansi.RESET + ansi.SGR    // reset

print_help :: proc() {
    fmt.println("\n\n" + 
    "┌─ HELP ───────────────────────────────────────────────────────┐\n" +
    "│ Usage: tesuteru <path/to/folder> <flags>                     │\n" +
    "│ Flags:                                                       │\n" +
    "│ -a - addintional repeats if you failed to answer correctly   │\n" +
    "│ -i - initial repeats for each question                       │\n" +
    "│ -m - max repeats for each question                           │\n" +
    "│ -c - activate cheat mode                                     │\n" +
    "│ -d - disable ansi codes (not recomended, use if your term    │\n" +
    "│  doesn't support them for any reason. But consider upgrading │\n" +
    "│  your term, it not 1975 anymore bruh). Hope your term        │\n" +
    "│  supprorts UTF-8 at least.                                   │\n" +
    "├──────────┬──────────┬────────────────────────────────────────┤\n" +
    "│ テステル │ ver1.0.0 │ bk                                     │\n" +
    "└──────────┴──────────┴────────────────────────────────────────┘\n" +
    "\n\n")
}

choose_random_question :: proc(questions: ^[dynamic]Question) -> int {
    if len(questions^) == 0 {
        fmt.println("No questions, congrats..")
        return -1
    }

    index_rand := rand.int_max(len(questions^))
    rand.shuffle(questions[index_rand].answers[:])

    return index_rand
}

print_question :: proc(
    questions: ^[dynamic]Question,
    index: ^int,
    show_answers: ^bool,
    config: ^Config
) {
    fmt.printfln("%s\n", questions[index^].text)
    i := 1
    for answer in questions[index^].answers {
        if answer.is_correct && show_answers^ {
            if config.ansimode {
                fmt.printfln(ANSI_I + "  + %i. %s\n" + ANSI_RST, i, answer.text)
            } else {
                fmt.printfln("  + %i. %s\n", i, answer.text)
            }
        } else {
            fmt.printfln("    %i. %s\n", i, answer.text)
        }
        i += 1
    }
}

print_data :: proc(
    dir_path: ^string,
    filename: ^string,
    question_count: ^u32,
    testing_data: ^TestingData,
    config: ^Config
) {
    all_answers := testing_data^.correct_answers + testing_data^.incorrect_answers
    ratio := f32(100)
    if testing_data^.correct_answers + testing_data^.incorrect_answers != 0 {
        ratio =
        f32(testing_data^.correct_answers) /
        f32(all_answers) *
        100
    }
    fmt.printfln("┌ Loaded directory: %s", dir_path^)
    fmt.printfln("│ Current file: %s", filename^)
    fmt.printfln("│ Qiestions: %d", testing_data^.number_of_questions)
    fmt.printfln("│ Completed questions: %d", testing_data^.completed_questions)
    fmt.printfln("│ Repeats: %d", question_count^)
    fmt.printfln("│ Total answers: %d", all_answers)

    switch config.ansimode {
        case true:
            if ratio >= 75 {
                fmt.printfln("└ " + ANSI_S + "Accurancy: %.2f%%" +
                    ANSI_RST +"\n", ratio)
            } else if ratio >= 50 {
                fmt.printfln("└ " + ANSI_W + "Accurancy: %.2f%%" + 
                    ANSI_RST +"\n", ratio)
            } else if ratio < 50 {
                fmt.printfln("└ " + ANSI_C + "Accurancy: %.2f%%" + 
                    ANSI_RST +"\n", ratio)
            }
        case false: 
                fmt.printfln("└ Accurancy: %.2f%%\n", ratio)
    }
    // fmt.printf("|\u001B[36m Accurancy: %.2f%%\u001B[0m\n", ratio)
}

print_stat :: proc(
    dir_path: ^string,
    testing_data: ^TestingData,
    elapsed: ^time.Duration,
    config: ^Config
) {

    // hours   := int(total_seconds / 3600)
    // minutes := int((total_seconds / 60) - (hours * 60))
    // seconds := int(total_seconds - (hours * 3600) - (minutes * 60))
    // milliseconds := int(time.duration_milliseconds(duration^)) % 1000

    all_answers := testing_data^.correct_answers + testing_data^.incorrect_answers
    ratio := f32(100)
    if testing_data^.correct_answers + testing_data^.incorrect_answers != 0 {
        ratio =
        f32(testing_data^.correct_answers) /
        f32(all_answers) *
        100
    }
    fmt.printfln("┌ Loaded directory: %s", dir_path^)
    fmt.printfln("│ Qiestions: %d", testing_data^.number_of_questions)
    if config.ansimode {
        fmt.printfln("│ Took you: " + ANSI_I + "%s" +
            ANSI_RST, formated_time(elapsed))
    } else {
        fmt.printfln("│ Took you: %s", formated_time(elapsed))
    }
    // print_time(elapsed)
    // fmt.printfln("| Completed questions: %d", testing_data^.completed_questions)
    fmt.printfln("│ Total answers: %d", all_answers)
    switch config.ansimode {
        case true:
            if ratio >= 75 {
                fmt.printfln("└ " + ANSI_S + "Accurancy: %.2f%%" +
                    ANSI_RST +"\n", ratio)
            } else if ratio >= 50 {
                fmt.printfln("└ " + ANSI_W + "Accurancy: %.2f%%" + 
                    ANSI_RST +"\n", ratio)
            } else if ratio < 50 {
                fmt.printfln("└ " + ANSI_C + "Accurancy: %.2f%%" + 
                    ANSI_RST +"\n", ratio)
            }
        case false: 
                fmt.printfln("└ Accurancy: %.2f%%\n", ratio)
    }
}

print_congrats :: proc(config: ^Config, testing_data: ^TestingData) {

    BOOK_ASCII :: "\n\n" +
        "      ______ ______        \n" +
        "    _/      Y      \\_     \n" +
        "   // ~~ ~~ | ~~ ~  \\\\   \n" +
        "  // ~ ~ ~~ | ~~~ ~~ \\\\  \n" +
        " //________.|.________\\\\ \n" +
        "`----------`-'----------'  \n" +
        "\n\n"

    COFFEE_ASCII :: "\n\n" +
        "      )  (         \n" +
        "     (   ) )       \n" +
        "      ) ( (        \n" +
        "    _(_____)_      \n" +
        " .-'---------|     \n" +
        "( C|/\\/\\/\\/\\/| \n" +
        " '-./\\/\\/\\/\\/| \n" +
        "   '_________'     \n" +
        "    '-------'      \n" +
        "\n\n"

    BEER_ASCII :: "\n\n" +
        "  .   *   ..  . *  *   \n" +
        "*  * @()Ooc()*   o  .  \n" +
        "    (Q@*0CG*O()  ___   \n" +
        "   |\\_________/|/ _ \\\n" +
        "   |  |  |  |  | / | | \n" +
        "   |  |  |  |  | | | | \n" +
        "   |  |  |  |  | | | | \n" +
        "   |  |  |  |  | | | | \n" +
        "   |  |  |  |  | | | | \n" +
        "   |  |  |  |  | \\_| |\n" +
        "   |  |  |  |  |\\___/ \n" +
        "   |\\_|__|__|_/|      \n" +
        "    \\_________/       \n" +
        "\n\n"

    MISATO :: "\n\n" + 
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣠⣤⣄⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⣾⣿⣿⣿⣿⣿⣿⣿⣷⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣶⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⡿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⢸⠏⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⢸⣿⣿⣿⣿⣿⣿⣟⣿⠀⠀⠘⠉⠁⠀⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠿⢿⣿⡙⠇⠙⠏⠑⣆⠀⠀⠀⠀⡰⢟⣹⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⢷⠠⡤⢤⣀⠀⠀⠀⠀⠀⠀⠞⠙⠉⠿⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢨⣌⠀⠀⠛⠻⠁⠀⠀⠀⠀⠀⠠⠤⣤⣀⠀⠀⢨⢻⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⡆⠂⠖⡔⠀⠀⠀⠀⠀⠀⠀⠓⣿⢠⡉⠁⡀⣾⣯⠟⣽⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⡇⠀⠀⠀⢾⠀⡰⠀⠀⠊⡯⠢⣳⠛⢝⣷⣎⣱⣻⣾⣿⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⠟⠋⠉⠙⣄⠀⠀⠀⡁⠀⠀⠀⠀⠐⡄⢱⣇⢸⡼⡯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡿⠁⠀⠀⠀⠀⠈⣢⡀⠀⠈⠉⠉⠁⠀⢀⠃⢸⡏⢨⣷⣿⣯⠟⣩⠟⠛⠿⢿⣿⣿⣿⣿⡄⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠁⠀⠀⠀⠀⠀⡰⠁⡱⣄⠀⠀⠀⡠⠒⠁⠀⠘⠀⡼⣱⣟⠇⣴⠏⠀⠀⠀⠀⠈⢻⣿⣿⣿⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡆⠀⠀⠀⠀⠀⠀⡇⠰⠁⠈⢳⠶⠋⠀⠠⠐⠂⠀⠀⢀⣭⠞⡸⠁⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⡆⠀⠸⢡⡇⠀⠀⠏⠀⠀⠀⠉⠀⢀⣠⡶⢋⡇⢠⠃⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⣧⢠⢁⢷⡇⠀⠀⠀⠀⠠⠀⠀⣶⢿⣷⠖⢺⠁⡘⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣷⡀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⣀⠤⠔⠒⠢⠬⢬⣻⣎⣹⢱⠀⠀⡄⠀⠀⠀⠀⣹⠉⠀⠀⣾⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⣷⠀\n" +
        "⠀⠀⠀⢀⠄⠒⠈⠁⠀⠀⠀⠀⠀⠀⠀⢻⠁⠈⢆⠣⡀⠃⠀⠀⠀⠄⢸⡎⠀⣠⢿⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡾⢸⣿⣿⣿⣿⡇\n" +
        "⠀⠀⠀⢎⠆⠀⢰⠀⠀⣴⢳⠀⠀⣦⠀⠈⡆⠀⠈⢆⠑⠄⠀⠀⠀⠀⠺⣧⠞⣡⠼⡜⠀⠀⠀⠀⠀⠀⠀⠀⣸⠛⢻⣿⣿⣿⡿⠀\n" +
        "⠀⠀⢠⢸⠀⠀⡇⠀⢀⣷⣿⡆⠀⢣⣆⠀⠸⡀⠀⠈⠢⠄⠀⠀⠀⠀⠀⡧⠊⠁⡜⠀⠀⠀⠀⠀⠀⠀⠀⢠⣇⣠⢿⣿⣿⡟⠀⠀\n" +
        "⠀⠀⢸⠸⣄⣸⠀⢀⣸⣿⣿⡇⠀⢸⣿⠀⠀⡇⠀⠀⠀⢨⠀⠀⠀⠀⠀⢡⠀⡼⠀⠀⠀⠀⠀⠀⠀⠀⠀⣞⠶⢃⢿⣿⠏⠀⠀⠀\n" +
        "⠀⠀⠸⠀⠈⠻⣆⣨⣿⣿⣿⣧⠀⣸⣿⡆⠄⠇⠀⠀⠀⢸⠀⠀⠀⠀⠀⠘⡴⠁⠀⠀⠀⠀⠀⠀⠀⠀⣘⣁⠔⠃⢸⠃⠀⠀⠀⠀\n" +
        "⠀⠀⠇⠀⠀⠀⠻⣿⣿⣿⣿⣿⠁⣿⣿⣷⣼⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⢇⠀⠀⠀⠀⠀⠀⠀⠀⡰⠁⠀⠀⠀⡇⠀⠀⠀⠀⠀\n" +
        "⠀⠸⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠸⡀⠀⠀⠀⠀⠀⠀⡰⠁⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀\n" +
        "⠀⠉⠉⠉⠉⠉⠉⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n" +
        "⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠛⠛⠛⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n" +
        "\n\n"

    ratio := f32(100)
    all_answers := testing_data^.correct_answers + testing_data^.incorrect_answers
    if testing_data^.correct_answers + testing_data^.incorrect_answers != 0 {
        ratio =
        f32(testing_data^.correct_answers) /
        f32(all_answers) *
        100
    }

    if config.cheatmode {
        fmt.println("Well done... now try it without cheats!\n")
        fmt.println(BOOK_ASCII)
    } else {
        if ratio >= 95 {
            fmt.println("Excellent job!\n")
            fmt.println(MISATO)
        } else if ratio >= 75 {
            fmt.println("Good job! Good luck on your test!\n")
            fmt.println(BEER_ASCII)
        } else if ratio >= 50 {
            fmt.println("Not bad. But give it another go later.\n")
            fmt.println(COFFEE_ASCII)
        } else {
            fmt.println("How did you pass? Anyway, try learning a bit more.\n")
            fmt.println(BOOK_ASCII)
        }
    }
}

formated_time :: proc(elapsed: ^time.Duration) -> string{
    total_milliseconds := int(time.duration_milliseconds(elapsed^))

    hours := total_milliseconds / 3_600_000
    minutes := (total_milliseconds % 3_600_000) / 60_000
    seconds := (total_milliseconds % 60_000) / 1_000
    milliseconds := total_milliseconds % 1_000

    buffer: [dynamic]u8
    builder:= strings.Builder{
        buf = buffer
    }

    result: string
    
    if hours == 0 {
        result = fmt.sbprintf(&builder, "%02d:%02d.%03d", minutes, seconds, milliseconds)
    } else {
        result = fmt.sbprintf(
            &builder,
            "%02d:%02d:%02d.%03d",
            hours,
            minutes,
            seconds,
            milliseconds
        )
    }

    return result
}

clear_term :: proc(config: ^Config) {
    if config.ansimode {
        fmt.print("\x1b[2J\x1b[H")
    } else {
        for i in 0..=63 {
            fmt.print("\n")
        }
        fmt.println("________________________________")
    }
    // fmt.println(ansi.CSI + ansi.FG_CYAN + ansi.SGR + "Hellope!" + ansi.CSI + ansi.RESET + ansi.SGR)
}

