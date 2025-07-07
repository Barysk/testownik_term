package tesuteru

import "core:fmt"
import "core:math/rand"
import "core:terminal/ansi"

choose_random_question :: proc(questions: ^[dynamic]Question) -> int {
    if len(questions^) == 0 {
        fmt.println("No questions, congrats..")
        return -1
    }

    index_rand := rand.int_max(len(questions^))

    // print_question(questions, index_rand)
    //
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
            fmt.printfln("  + %i. %s\n", i, answer.text)
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
    ratio := f32(100)
    if testing_data^.correct_answers + testing_data^.incorrect_answers != 0 {
        ratio =
        f32(testing_data^.correct_answers) /
        f32(testing_data^.correct_answers + testing_data^.incorrect_answers) *
        100
    }
    fmt.printfln("| Loaded directory: %s", dir_path^)
    fmt.printfln("| Current file: %s", filename^)
    fmt.printfln("| Qiestions: %d", testing_data^.number_of_questions)
    fmt.printfln("| Completed questions: %d", testing_data^.completed_questions)
    fmt.printfln("| Repeats: %d", question_count^)
    fmt.printfln("| Ratio: %.2f%%\n", ratio)
}

clear_term :: proc() {
    fmt.print("\x1b[2J\x1b[H")
    // fmt.println(ansi.CSI + ansi.FG_CYAN + ansi.SGR + "Hellope!" + ansi.CSI + ansi.RESET + ansi.SGR)
}

