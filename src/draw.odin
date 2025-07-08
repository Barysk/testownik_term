package tesuteru

import "core:fmt"
import "core:math/rand"
import "core:terminal/ansi"
import "core:strings"
import "core:time"

ANSI :: true
ANSI_I :: ansi.CSI + ansi.FG_CYAN + ansi.SGR    // info
ANSI_S :: ansi.CSI + ansi.FG_GREEN + ansi.SGR   // super
ANSI_W :: ansi.CSI + ansi.FG_YELLOW + ansi.SGR  // warning
ANSI_C :: ansi.CSI + ansi.FG_RED + ansi.SGR     // critical
ANSI_RST :: ansi.CSI + ansi.RESET + ansi.SGR    // reset

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
    show_answers: ^bool
) {
    fmt.printfln("%s\n", questions[index^].text)
    i := 1
    for answer in questions[index^].answers {
        if answer.is_correct && show_answers^ {
            if ANSI {
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
    testing_data: ^TestingData
) {
    all_answers := testing_data^.correct_answers + testing_data^.incorrect_answers
    ratio := f32(100)
    if testing_data^.correct_answers + testing_data^.incorrect_answers != 0 {
        ratio =
        f32(testing_data^.correct_answers) /
        f32(all_answers) *
        100
    }
    fmt.printfln("| Loaded directory: %s", dir_path^)
    fmt.printfln("| Current file: %s", filename^)
    fmt.printfln("| Qiestions: %d", testing_data^.number_of_questions)
    fmt.printfln("| Completed questions: %d", testing_data^.completed_questions)
    fmt.printfln("| Repeats: %d", question_count^)
    fmt.printfln("| Total answers: %d", all_answers)

    switch ANSI {
        case true:
            if ratio >= 75 {
                fmt.printfln("| " + ANSI_S + "Accurancy: %.2f%%" +
                    ANSI_RST +"\n", ratio)
            } else if ratio >= 50 {
                fmt.printfln("| " + ANSI_W + "Accurancy: %.2f%%" + 
                    ANSI_RST +"\n", ratio)
            } else if ratio < 50 {
                fmt.printfln("| " + ANSI_C + "Accurancy: %.2f%%" + 
                    ANSI_RST +"\n", ratio)
            }
        case false: 
                fmt.printfln("| Accurancy: %.2f%%\n", ratio)
    }
    // fmt.printf("|\u001B[36m Accurancy: %.2f%%\u001B[0m\n", ratio)
}

print_stat :: proc(
    dir_path: ^string,
    testing_data: ^TestingData,
    elapsed: ^time.Duration
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
    fmt.printfln("| Loaded directory: %s", dir_path^)
    fmt.printfln("| Qiestions: %d", testing_data^.number_of_questions)
    if ANSI {
        fmt.printfln("| Took you: " + ANSI_I + "%s" +
            ANSI_RST, formated_time(elapsed))
    } else {
        fmt.printfln("| Took you: %s", formated_time(elapsed))
    }
    // print_time(elapsed)
    // fmt.printfln("| Completed questions: %d", testing_data^.completed_questions)
    fmt.printfln("| Total answers: %d", all_answers)
    switch ANSI {
        case true:
            if ratio >= 75 {
                fmt.printfln("| " + ANSI_S + "Accurancy: %.2f%%" +
                    ANSI_RST +"\n", ratio)
            } else if ratio >= 50 {
                fmt.printfln("| " + ANSI_W + "Accurancy: %.2f%%" + 
                    ANSI_RST +"\n", ratio)
            } else if ratio < 50 {
                fmt.printfln("| " + ANSI_C + "Accurancy: %.2f%%" + 
                    ANSI_RST +"\n", ratio)
            }
        case false: 
                fmt.printfln("| Accurancy: %.2f%%\n", ratio)
    }
}

print_congrats :: proc() {
    fmt.println("Congratulation, now go drink")
}

formated_time :: proc(elapsed: ^time.Duration) -> string{
    total_milliseconds := int(time.duration_milliseconds(elapsed^))

    hours := int(total_milliseconds / 3_600_00)
    minutes := int(total_milliseconds / 60_000) - hours * 60
    seconds := int(total_milliseconds / 1_000) - hours * 3_600_000 - minutes * 60
    milliseconds := int(total_milliseconds) - hours * 3_600_000 - minutes * 60_000 - seconds * 1_000

    buffer: [dynamic]u8
    builder:= strings.Builder{
        buf = buffer
    }

    result: string
    
    if hours == 0 {
        result = fmt.sbprintf(&builder, "%02d:%02d.%03d", minutes, seconds, milliseconds)
    } else {
        result = fmt.sbprintfln(
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

clear_term :: proc() {
    if ANSI {
        fmt.print("\x1b[2J\x1b[H")
    } else {
        fmt.println("\n\n\n\n\n\n _______________________________")
    }
    // fmt.println(ansi.CSI + ansi.FG_CYAN + ansi.SGR + "Hellope!" + ansi.CSI + ansi.RESET + ansi.SGR)
}

