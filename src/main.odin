package tesuteru

import "core:os"
import "core:fmt"
import "core:strings"
import "core:math/rand"
import "core:time"

// TODO
// Planned flags:
// -e <num> additional answers if wrong default 1
// -i <num> initial answer count default 2
// -m <num> max answer count default 3
// -c activates cheat mode - you see the correct answers, good initial learning
//
// Input
// multiple answers are going using , valid answers = { 
// 1,2,3 1, 2, 3
// 1,2 ,3,
// 2
// 3,
// }
//
// Misc:
// show question file names
// show stat [Wrong answers / Correct answers]
// show number of questions that are no longer appear. 'Opanowane' [num]
// show number of questions that are going appear. 'Do opanowania' [num]
// show [time passed]
//
// If I will
// -h <num> use heuristic instead of fully random, good for initial learning num means number of questions in the initial pool
// -s enable save function, saves state after every question
// -S <path/to/save_file.txt> to load your save
// savings are laying down in the directory with testownik questions : saves must by dynamic, updated after every save

CHEATMODE :: false

ADDITIONAL_ANSWERS :: 1
INITIAL_ANSWERS :: 2
MAX_ANSWERS :: 3

main :: proc() {
    args := os.args

    if len(args) < 2 {
        fmt.printfln("Usage: tesutero <path/to/folder>")
        return
    }

    seed := time.time_to_unix(time.now())
    rand.reset(u64(seed))

    dir_path := args[1]
    dir_handle, err := os.open(dir_path)
    if err != nil {
        fmt.println("Failure during attempt to open directory", dir_path)
        fmt.println(err)
        return
    }
    
    defer os.close(dir_handle)
    
    entries, _ := os.read_dir(dir_handle, -1)
    // error handle

    questions: [dynamic]Question

    for entry in entries {
        if !entry.is_dir && strings.has_suffix(entry.name, ".txt") {
            question := parse_question(entry)
            append(&questions, question)
        }
    }

    testing_data := TestingData {
        completed_questions = 0,
        number_of_questions = u32(len(questions)),
        correct_answers = 0,
        incorrect_answers = 0,
    }
    
    clear_term()
    // Loop
    for testing_data.completed_questions < testing_data.number_of_questions {
        show_answers := CHEATMODE

        // update
        current_question := choose_random_question(&questions)
        
        // draw
        print_data(
            &dir_path,
            &questions[current_question].id,
            &questions[current_question].count,
            &testing_data,
        )
        print_question(&questions, &current_question, &show_answers)

        // handle input
        input: [128]byte
        line, _ := os.read(os.stdin, input[:])
        
        // draw correct answers
        show_answers = true
        clear_term()
        print_data(
            &dir_path,
            &questions[current_question].id,
            &questions[current_question].count,
            &testing_data,
        )
        print_question(&questions, &current_question, &show_answers)

        switch check_the_answer(&questions, &input, &current_question) {
            case true:
                correct_answer( &questions, &current_question, &testing_data)
            case false:
                incorrect_answer(&questions, &current_question, &testing_data)
        }

        // wait on input input
        line, _ = os.read(os.stdin, input[:])
        clear_term()
    }
    fmt.println("Congratulation, now go drink")
}

correct_answer :: proc(
    questions: ^[dynamic]Question,
    current_question: ^int,
    testing_data: ^TestingData
) {
    fmt.println("Correct\n")

    questions[current_question^].count -= 1

    if questions[current_question^].count <= 0 {
        questions[current_question^].type = RandomType { is_done = true }
    }

    testing_data^.correct_answers += 1

    i := 0

    for question in questions^ {
        if question.type.(RandomType).is_done == true {
            // fmt.println(question.type)
            ordered_remove(questions, i)
            testing_data.completed_questions += 1
        }
        i += 1
    }
}

incorrect_answer :: proc(
    questions: ^[dynamic]Question,
    current_question: ^int,
    testing_data: ^TestingData
) {
    fmt.println("Wrong\n")

    testing_data^.incorrect_answers += 1
    if questions[current_question^].count < MAX_ANSWERS {
        questions[current_question^].count += ADDITIONAL_ANSWERS
    }
}





